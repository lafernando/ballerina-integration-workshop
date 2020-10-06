import ballerina/http;
import ballerina/system;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerina/auth;
//import ballerina/config;

GeoServiceBlockingClient grpcClient = new("http://localhost:9090");
rabbitmq:Connection mqConn = new ({host: "localhost", port: 5672});
rabbitmq:Channel mqChannel = new (mqConn);

auth:InboundBasicAuthProvider basicAuthProvider = new;
http:BasicAuthHandler basicAuthHandler = new (basicAuthProvider);

listener http:Listener httpEp = new (8080, config = {
    // auth: {
    //     authHandlers: [basicAuthHandler]
    // },
    // secureSocket: {
    //     keyStore: {
    //         path: config:getAsString("b7a.home") +
    //               "/bre/security/ballerinaKeystore.p12",
    //         password: "ballerina"
    //     }
    // }
});

@http:ServiceConfig {
    basePath: "/"
}
service locationService on httpEp {

    // https://developers.google.com/maps/documentation/geolocation/overview
    // https://developers.google.com/maps/documentation/geocoding/overview
    resource function mylocation(http:Caller caller, http:Request request) returns @tainted error? {
        http:Client glClient = new("https://www.googleapis.com");
        http:Client gcClient = new("https://maps.googleapis.com");
        string apiKey = system:getEnv("GC_KEY");
        json payload = { considerIp: true };
        var resp = check glClient->post(string `/geolocation/v1/geolocate?key=${apiKey}`, payload);
        json jr = <@untainted> check resp.getJsonPayload();
        float lat = <float> jr.location.lat;
        float long = <float> jr.location.lng;
        string? address = <@untainted> check lookupLocal(lat, long);
        if address == () {
            resp = check gcClient->get(<@untainted> string `/maps/api/geocode/json?latlng=${lat},${long}&key=${apiKey}`);
            json locationInfo = <@untainted> check resp.getJsonPayload();
            json[] addrs = from var item in <json[]> check locationInfo.results 
                           where item.geometry.location_type == "GEOMETRIC_CENTER"
                           select check item.formatted_address;
            address = <string> addrs[0];
            if address is string {
                check storeLocalMQ(lat, long, "GoogleGeoCode", address);
            }
        }
        check caller->respond(<@untainted> {location: {lat, long}, address});
    }

}

function lookupLocal(float lat, float long) returns @tainted string|error? {
    var result = check grpcClient->lookup({lat, long});
    string address = result[0].address;
    if address == "" {
        io:println(string `Local (grpc) lookup miss: ${lat},${long}`);
        return ();
    } else {
        io:println(string `Local (grpc) lookup hit: ${lat},${long}`);
        return address;
    }
}

function storeLocalGRPC(float lat, float long, string src, string address) returns @tainted error? {
    _ = check grpcClient->store({lat, long, src, address, ref: system:uuid()});
    io:println(string `Local (grpc) lookup store: ${lat},${long}`);
}

function storeLocalMQ(float lat, float long, string src, string address) returns @tainted error? {
    json payload = {lat, long, src, address, ref: system:uuid()};
    check mqChannel->basicPublish(payload, "geo_queue");
    io:println(string `Local (mq) lookup store: ${lat},${long}`);
}

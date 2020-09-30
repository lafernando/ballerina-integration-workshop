import ballerina/http;
import ballerina/system;
import ballerina/io;

@http:ServiceConfig {
    basePath: "/"
}
service locationService on new http:Listener(8080) {

    resource function mylocation(http:Caller caller, http:Request request) returns @tainted error? {
        // https://developers.google.com/maps/documentation/geolocation/overview
        // https://developers.google.com/maps/documentation/geocoding/overview
        http:Client glClient = new("https://www.googleapis.com");
        http:Client gcClient = new("https://maps.googleapis.com");
        string apiKey = system:getEnv("GC_KEY");
        json payload = { considerIp: true };
        var resp = check glClient->post(string `/geolocation/v1/geolocate?key=${apiKey}`, payload);
        json jr = check resp.getJsonPayload();
        float lat = <float> jr.location.lat;
        float long = <float> jr.location.lng;
        resp = check gcClient->get(<@untainted> string `/maps/api/geocode/json?latlng=${lat},${long}&key=${apiKey}`);
        json locationInfo = <@untainted> check resp.getJsonPayload();
        json[] addrs = from var item in <json[]> check locationInfo.results 
                 where item.geometry.location_type == "GEOMETRIC_CENTER"
                 select check item.formatted_address;
        check caller->respond(<@untainted> {location: {lat, long}, address: addrs[0]});
    }

}
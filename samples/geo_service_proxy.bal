import ballerina/http;
import ballerina/log as _;
import ballerina/io;

type Entry record {
    string src;
    string ref;
};

http:Client backendSvcClient = new("http://localhost:8081");

@http:ServiceConfig {
    basePath: "/"
}
service geoServiceProxy on new http:Listener(8082) {

    @http:ResourceConfig {
        path:"/lookup/{lat}/{long}",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request, float lat, float long) returns error? {
        io:println("A");
        var resp = check backendSvcClient->get(<@untainted> string `/lookup/${lat}/${long}`);
        //TODO - check if below is okay - passthrough
        check caller->respond(resp);
    }

    @http:ResourceConfig {
        path:"/store",
        methods: ["POST"],
        body: "entry"
    }
    resource function store(http:Caller caller, http:Request request, Entry entry) returns error? {
        log:printInfo(string `Proxy intercept [store] - Source: ${entry.src} Ref: ${entry?.ref?:"N/A"}`);
        var resp = check backendSvcClient->post("/store", <@untainted> check entry.cloneWithType(json));
        check caller->respond(resp);
        check caller->ok();
    }

}
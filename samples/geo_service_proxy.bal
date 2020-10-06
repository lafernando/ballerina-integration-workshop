import ballerina/http;
//import ballerina/log;

type Entry record {
    string src;
    string ref?;
};

http:Client backendSvcClient = new("http://localhost:8081");

@http:ServiceConfig {
    basePath: "/"
}
service geoServiceProxy on new http:Listener(8082) {

    @http:ResourceConfig {
        path:"/lookup/",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request) returns error? {
        var resp = check backendSvcClient->forward("/lookup/", request);
        check caller->respond(resp);
    }

    @http:ResourceConfig {
        path:"/store",
        methods: ["POST"]
        //body: "entry"
    }
    //resource function store(http:Caller caller, http:Request request, Entry entry) returns error? {
    resource function store(http:Caller caller, http:Request request) returns error? {
        //log:printInfo(string `Proxy intercept [store] - Source: ${entry.src} Ref: ${entry?.ref?:"N/A"}`);
        //var resp = check backendSvcClient->post("/store", <@untainted> check entry.cloneWithType(json));
        var resp = check backendSvcClient->forward("/store", request);
        check caller->respond(resp);
    }

}
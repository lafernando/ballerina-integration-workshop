import ballerina/http;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string? ref;
|};

map<Entry> entries = {};

@http:ServiceConfig {
    basePath: "/"
}
service geoService on new http:Listener(8081) {

    @http:ResourceConfig {
        path:"/lookup/{lat}/{long}",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request, float lat, float long) returns error? {
        Entry? entry = entries[{lat,long}.toString()];
        if entry is Entry {
            check caller->ok({location: {lat: entry.lat, lng: entry.long}});
        } else {
            check caller->notFound();
        }
    }

    @http:ResourceConfig {
        path:"/store",
        methods: ["POST"],
        body: "entry"
    }
    resource function store(http:Caller caller, http:Request request, Entry entry) returns error? {
        entries[{lat: entry.lat, long: entry.long}.toString()] = <@untainted> entry;
        check caller->ok();
    }

}
import ballerina/http;
import ballerina/java.jdbc;

type Entry record {|
    float lat;
    float long;
    string src = "UNKNOWN";
    string address;
    string ref?;
|};

map<Entry> entries = {};

jdbc:Client dbClient = check new ("jdbc:mysql://localhost:3306/GEO_DB?serverTimezone=UTC", "root", "root");

@http:ServiceConfig {
    basePath: "/"
}
service geoService on new http:Listener(8081) {

    @http:ResourceConfig {
        path:"/lookup/{lat}/{long}",
        methods: ["GET"]
    }
    resource function lookup(http:Caller caller, http:Request request, float lat, float long) returns @tainted error? {
        transaction {
            stream<record{}, error> rs = dbClient->query(`SELECT address FROM GEO_ENTRY 
                                                          WHERE lat = ${<@untainted> lat} AND lng = ${<@untainted> long}`);
            record {|record {} value;|}? entry = check rs.next();
            string? address = ();
            if entry is record {|record {} value;|} {
                address = <@untainted> <string> entry.value["address"];
                check caller->ok(address);
            } else {
                check caller->notFound();
            }
            _ = check dbClient->execute(`INSERT INTO GEO_AUDIT (message) VALUES (
                                         ${string `LOOKUP ${<@untainted> lat} ${<@untainted> long} -> ${address?:"N/A"}`})`);
            check commit;
        }
    }

    @http:ResourceConfig {
        path:"/store",
        methods: ["POST"],
        body: "entry"
    }
    resource function store(http:Caller caller, http:Request request, Entry entry) returns error? {
        transaction {
            _ = check dbClient->execute(`INSERT INTO GEO_ENTRY (lat, lng, src, address, ref) 
                                        VALUES (${<@untainted> entry.lat},${<@untainted> entry.long},
                                        ${<@untainted> entry.src}, ${<@untainted> entry.address},
                                        ${<@untainted> entry?.ref})`);
            _ = check dbClient->execute(`INSERT INTO GEO_AUDIT (message) VALUES (${string `STORE ${<@untainted> entry.toJsonString()}`})`);
            check commit;
        }
        check caller->ok();
    }

}
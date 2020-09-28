import ballerina/http;
import ballerina/java.jdbc;

jdbc:Client dbClient = check new ("jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", "root", "root");

service Inventory on new http:Listener(8084) {

    @http:ResourceConfig {
        path: "/search/{query}",
        methods: ["GET"]
    }
    resource function search(http:Caller caller, http:Request request, 
                             string query) returns @tainted error? {
        var rs = dbClient->query("SELECT id, description FROM ECOM_INVENTORY WHERE description LIKE '%" + <@untainted> query + "%'");
        json jrs = check from var inv in rs select inv.toJson();
        check caller->ok(<@untainted> jrs);
    }

}
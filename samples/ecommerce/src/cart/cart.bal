import ballerina/http;
import laf/commons as x;
import ballerina/java.jdbc;

jdbc:Client dbClient = check new ("jdbc:mysql://localhost:3306/ECOM_DB?serverTimezone=UTC", "root", "root");

service ShoppingCart on new http:Listener(8080) {

    @http:ResourceConfig {
        path: "/items/{accountId}",
        body: "item",
        methods: ["POST"]
    }
    resource function addItem(http:Caller caller, http:Request request, 
                              int accountId, x:Item item) returns error? {
        var x = check dbClient->execute(`INSERT INTO ECOM_ITEM (inventory_id, account_id, quantity) 
                                     VALUES (${<@untainted> item.invId},${<@untainted> accountId},
                                     ${<@untainted> item.quantity})`);
        check caller->ok();
    }

    @http:ResourceConfig {
        path: "/items/{accountId}",
        methods: ["GET"]
    }
    resource function getItems(http:Caller caller, http:Request request, 
                               string accountId) returns @tainted error? {
        var rs = dbClient->query(`SELECT inventory_id as invId, quantity FROM ECOM_ITEM WHERE account_id = ${<@untainted> accountId}`);
        json jrs = check from var item in rs select item.toJson();
        check caller->ok(<@untainted> jrs);
    }

    @http:ResourceConfig {
        path: "/items/{accountId}",
        methods: ["DELETE"]
    }
    resource function clearItems(http:Caller caller, http:Request request, 
                                 string accountId) returns error? {
        _ = check dbClient->execute(`DELETE FROM ECOM_ITEM WHERE account_id = ${<@untainted> accountId}`);
        check caller->ok();
    }

}
import ballerina/http;
import ballerina/encoding;
import laf/commons as x;

http:Client cartClient = new("http://localhost:8080/ShoppingCart");
http:Client orderMgtClient = new("http://localhost:8081/OrderMgt");
http:Client billingClient = new("http://localhost:8082/Billing");
http:Client shippingClient = new("http://localhost:8083/Shipping");
http:Client invClient = new("http://localhost:8084/Inventory");

public type Items x:Item[];

service Admin on new http:Listener(8085) {

    @http:ResourceConfig {
        path: "/invsearch/{query}",
        methods: ["GET"]
    }
    resource function search(http:Caller caller, http:Request request, 
                             string query) returns @tainted error? {
        http:Response resp = check invClient->get("/search/" + <@untainted> check encoding:encodeUriComponent(query, "UTF-8"));
        check caller->respond(resp);
    }

    @http:ResourceConfig {
        path: "/cartitems/{accountId}",
        body: "item",
        methods: ["POST"]
    }
    resource function addItem(http:Caller caller, http:Request request, 
                              int accountId, x:Item item) returns error? {
        http:Response resp = check cartClient->post("/items/" + <@untainted> accountId.toString(), 
                                                    <@untainted> check item.cloneWithType(json));
        check caller->respond(resp);
    }

    @http:ResourceConfig {
        path: "/checkout/{accountId}"
    }
    resource function checkout(http:Caller caller, http:Request request, int accountId) returns @tainted error? {
        http:Response resp = check cartClient->get("/items/" + <@untainted> accountId.toString());
        json payload = check resp.getJsonPayload();
        x:Item[] items = check payload.cloneWithType(Items);
        if items.length() == 0 {
            http:Response respx = new;
            respx.statusCode = 400;
            respx.setTextPayload("Empty cart");
            check caller->respond(respx);
            return;
        }
        x:Order orderx = { accountId, items };
        resp = check orderMgtClient->post("/order", <@untainted> check orderx.cloneWithType(json));
        string orderId = check resp.getTextPayload();
        x:Payment payment = { orderId };
        resp = check billingClient->post("/payment", <@untainted> check payment.cloneWithType(json));
        string receiptNumber = check resp.getTextPayload();
        x:Delivery delivery = { orderId };
        resp = check shippingClient->post("/delivery", <@untainted> check delivery.cloneWithType(json));
        string trackingNumber = check resp.getTextPayload();
        _ = check cartClient->delete("/items/" + <@untainted> accountId.toString());
        check caller->ok(<@untainted> { accountId: accountId, orderId: orderId, receiptNumber: receiptNumber, 
                                        trackingNumber: trackingNumber });
    }

}
import ballerina/http;
import ballerina/system;
import ballerina/log;
import laf/commons as x;

map<x:Order> orderMap = {};

service OrderMgt on new http:Listener(8081) {

    @http:ResourceConfig {
        path: "/order/",
        body: "orderx",
        methods: ["POST"]
    }
    resource function createOrder(http:Caller caller, http:Request request, 
                                  x:Order orderx) returns @tainted error? {
        string orderId = system:uuid();
        orderMap[orderId] = <@untainted> orderx;
        check caller->ok(orderId);
        log:printInfo("OrderMgt - OrderId: " + orderId + " AccountId: " + orderx.accountId.toString());
    }

    @http:ResourceConfig {
        path: "/order/{orderId}",
        methods: ["GET"]
    }
    resource function getOrder(http:Caller caller, http:Request request, 
                               string orderId) returns @tainted error? {
        x:Order? orderx = orderMap[orderId];
        if orderx is x:Order {
            check caller->respond(check orderx.cloneWithType(json));
        }
    }

}
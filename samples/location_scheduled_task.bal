import ballerina/task;
import ballerina/http;
import ballerina/log;

listener task:Listener timer = new ({intervalInMillis: 5000, initialDelayInMillis: 0});

service locationLogger on timer {

    resource function onTrigger() returns @tainted error? {
        http:Client locationSvcClient = new http:Client("http://localhost:8080");
        var resp = check locationSvcClient->get("/mylocation");
        log:printInfo(check resp.getJsonPayload());
    }

}
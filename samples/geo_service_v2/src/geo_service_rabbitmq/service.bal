import ballerina/log;
import ballerinax/rabbitmq;

@rabbitmq:ServiceConfig {
    queueConfig: {
        queueName: "geo_queue"
    }
}
service mqService on new rabbitmq:Listener({host: "localhost", port: 5672}) {

    resource function onMessage(rabbitmq:Message message) returns @tainted error? {
        var payload = check message.getTextContent();
        log:printInfo("The message received: " + payload);
    }

}

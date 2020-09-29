import ballerina/http;
import ballerina/io;

public function main() returns @tainted error? {
    http:Client httpClient = new("https://www.google.com");
    http:Response resp = check httpClient->get("/");
    string payload = check resp.getTextPayload();
    io:println(payload);
}

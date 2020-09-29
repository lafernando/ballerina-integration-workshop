import ballerina/http;
import ballerina/io;
import ballerina/system;

public function main() returns @tainted error? {
    // https://maps.googleapis.com/maps/api/geocode/json?latlng=6.9048539,79.8589821&key=YOUR_API_KEY
    // https://developers.google.com/maps/documentation/geocoding/get-api-key    
    http:Client httpClient = new("https://maps.googleapis.com");
    float lat = 6.9048539;
    float long = 79.8589821;
    string apiKey = system:getEnv("GC_KEY");
    var resp = check httpClient->get(string `/maps/api/geocode/json?latlng=${lat},${long}&key=${apiKey}`);
    json jp = check resp.getJsonPayload();
    json[] results = <json[]> jp.results;
    results.forEach(function (json result) {
        io:println(result.formatted_address);
    });
    results = results.filter(function (json result) returns boolean {
        return result.formatted_address.toString().indexOf("College") is int;
    });
    results.forEach(function (json result) {
        io:println("** School: ", result.formatted_address);
    });

    //https://postman-echo.com/post
    httpClient = new("https://postman-echo.com");
    resp = check httpClient->post("/post", "ABCD");
    io:println("** Echoed: ", resp.getJsonPayload());
}

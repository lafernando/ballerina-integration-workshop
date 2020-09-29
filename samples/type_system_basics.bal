import ballerina/io;
import ballerina/lang.'int as intlib;
import ballerina/time;

// closed record
type Person record {|
    string name;
    int birthyear;
|};

// open record
type Student record {
    *Person;
    string college;
};

type AuthorEntry record {
    string author;
    string[] books;
};

// more in-depth info on the type system: https://hackernoon.com/rethinking-programming-network-aware-type-system-8o7x3yh6

public function main() returns error? {
    int i = 10;
    decimal d = 10.25;
    float f = 1.25;
    boolean b = true;

    Student s1 = { name: "Jack", birthyear: 1995, college: "Stanford" };
    // only open records can do this
    s1["graduated"] = "2020-10-10";

    io:println("Student: ", s1);

    string|byte[] input = "XXX";

    if input is string {
        string data = "data:" + input;
    } else {
        int inputLength = input.length();
    }

    int|error result = intlib:fromString("100x");
    if result is int {
        io:println("Number: ", result + 10);
    } else {
        io:println("Error: ", result);
    }

    io:println("Age: ", calculateAge(io:readln("Enter birth year: ")));

    json msg = { author: "J.K. Rowling", books: ["Harry Potter", "Fantastic Beasts"] };
    io:println("Author: ", msg.author);
    io:println("Books: ", msg.books);

    AuthorEntry entry = check msg.cloneWithType(AuthorEntry);
    io:println("Entry: ", entry);
}

// public function calculateAge(string birthYearInput) returns int|error {
//     int|error result = 'int:fromString(birthYearInput);
//     if result is error {
//         return result;
//     } else {
//         return time:getYear(time:currentTime()) - result;
//     }
// }

public function calculateAge(string birthYearInput) returns int|error {
    int result = check intlib:fromString(birthYearInput);
    return time:getYear(time:currentTime()) - result; 
}

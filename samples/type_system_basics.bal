import ballerina/io;
import ballerina/lang.'int as intlib;
import ballerina/time;

type Person record {
    string name;
    int birthyear;
};

type Student record {
    //string name;
    //int birthyear;
    *Person;
    string college;
};

type Author record {
    string name;
    string[] books;
};

// more in-depth info on the structural type system: https://ballerina.io/why-ballerina/network-aware-type-system/

public function main() returns error? {
    int i = 10;
    decimal d = 10.25;
    float f = 1.25;
    boolean b = true;

    Student s1 = { name: "Jack", birthyear: 1995, college: "Stanford" };
    io:println("Student: ", s1);

    // due to the structural type system, s1 can be assigned to p1,
    // since the s1's structure is compatible with p1's,
    // where we can say, a "Student" is a "Person" as well. 
    Person p1 = s1;

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

    json msg = { name: "J.K. Rowling", books: ["Harry Potter", "Fantastic Beasts"] };
    io:println("Name: ", msg.name);
    io:println("Books: ", msg.books);

    Author entry = check msg.cloneWithType(Author);
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

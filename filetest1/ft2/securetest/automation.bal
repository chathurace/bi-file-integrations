import ballerina/log;

public function main() returns error? {
    do {
        log:printInfo("Integration started.");

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

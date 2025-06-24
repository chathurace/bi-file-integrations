import ballerina/log;

public function main() returns error? {
    do {
        log:printInfo("Starting the sample...");
        // stream<byte[] & readonly, io:Error?> filedata = check ftpClient->get("/test/data1.json");
        // json data1 = check jsondata:parseStream(filedata);
        // log:printInfo(data1.toBalString());

    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

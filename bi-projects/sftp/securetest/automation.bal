// import ballerina/io;
// import ballerina/log;
// import ballerina/ftp;

import ballerina/io;
import ballerina/log;

public function main() returns error? {
    stream<byte[] & readonly, io:Error?> fileData = check ftpClient->get("/upload/f3.csv");
    log:printInfo("Fetched file date.");
    //     final ftp:Client|ftp:Error ftpClient = new ({
    //     protocol: "sftp",
    //     host: "localhost",
    //     port: 2222,
    //     auth: {
    //         credentials: {
    //             username: "foo",
    //             password: "pass"
    //         }
    //     }
    // });
    // if (ftpClient is ftp:Error) {
    //     log:printError("Failed to create FTP client", 'error = ftpClient);
    //     return ftpClient;
    // }

    // do {
    //     log:printInfo("Integration started.");
    //     stream<byte[] & readonly, io:Error?> streamByteReadonlyIoError = check ftpClient->get("/upload/f2.csv");

    // } on fail error e {
    //     log:printError("Error occurred", 'error = e);
    //     return e;
    // }
}

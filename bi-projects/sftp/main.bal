import ballerina/data.csv;
import ballerina/ftp;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/log;
import ballerina/sql;

listener ftp:Listener inventoryUpdatesL = new (protocol = ftp:SFTP, path = "/upload", port = 2222, auth = {
    credentials: {
        username: "foo",
        password: "pass"
    }
}, fileNamePattern = "(.*).csv", host = "localhost", pollingInterval = 3);

service ftp:Service on inventoryUpdatesL {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            log:printInfo("File change event received: " + event.toJsonString());

            foreach ftp:FileInfo fileInfo in event.addedFiles {
                do {
                    string[] fileNameParts = regexp:split(re `_`, fileInfo.name);
                    stream<byte[] & readonly, io:Error?> contentStream = check ftpClient->get(fileInfo.pathDecoded);
                    byte[] allBytes = [];
                    check contentStream.forEach(function(byte[] & readonly chunk) {
                        byte[] mutableChunk = chunk.clone();
                        allBytes.push(...mutableChunk);
                    });
                    string inventoryString = check string:fromBytes(allBytes);
                    InventoryEntry[] entry = check csv:parseString(inventoryString, {
                                                                                        customHeadersIfHeadersAbsent: ["pid", "quantity"]
                                                                                    });

                    foreach InventoryEntry ientry in entry {
                        log:printInfo("Product ID: " + ientry.pid + ", Quantity: " + ientry.quantity.toString());
                        sql:ExecutionResult updateResult = check inventoryDB->execute(`INSERT INTO shop_inventory (shopId, pid, quantity)
    VALUES (${fileNameParts[0]}, ${ientry.pid}, ${ientry.quantity})
    ON DUPLICATE KEY UPDATE quantity = ${ientry.quantity};`);
                    }
                    check ftpClient->rename(fileInfo.pathDecoded, string `/processed/${fileInfo.name}`);

                } on fail error err {
                    check ftpClient->rename(fileInfo.pathDecoded, string `/failed/${fileInfo.name}`);
                }
            } on fail error err {
                return error("unhandled error", err);
            }
        }
    }
}

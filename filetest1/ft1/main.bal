import ballerina/crypto;
import ballerina/data.csv;
import ballerina/ftp;
import ballerina/http;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/log;
import ballerina/sql;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener ftp:Listener dataOneL = new (protocol = ftp:FTP, path = "/test", port = 2120, auth = {
    credentials: {
        username: "testuser",
        password: "testpass"
    }
}, fileNamePattern = "(.*).csv", host = "localhost", pollingInterval = 3);

service ftp:Service on dataOneL {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
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
                crypto:PrivateKey cryptoPrivatekey = check getPrivateKey();
                byte[] dcontent = check crypto:decryptRsaEcb(allBytes, cryptoPrivatekey, crypto:OAEPWithSHA1AndMGF1);
                string inventoryString = check string:fromBytes(dcontent);

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

        }
    }
}

function fromStream(stream<byte[] & readonly, io:Error?> dataStream) returns string|error {
    byte[] allBytes = [];
    check dataStream.forEach(function(byte[] & readonly chunk) {
        byte[] mutableChunk = chunk.clone();
        allBytes.push(...mutableChunk);
    });
    return string:fromBytes(allBytes);
}

function getPublicKey() returns crypto:PublicKey|error {
    crypto:PublicKey|error publicKey = crypto:decodeRsaPublicKeyFromCertFile(publicKeyPath);
    if publicKey is error {
        log:printError("Failed to decode public key", 'error = publicKey);
    }
    return publicKey;
}

function getPrivateKey() returns crypto:PrivateKey|error {
    crypto:PrivateKey|error privateKey = crypto:decodeRsaPrivateKeyFromKeyFile(privateKeyPath, "cce123");
    if privateKey is error {
        log:printError("Failed to decode private key", 'error = privateKey);
    }
    return privateKey;
}

service /util on httpDefaultListener {

    resource function post enc(@http:Payload string payload) returns error|json {
        do {
            crypto:PublicKey cryptoPublickey = check getPublicKey();
            byte[] econtent = check crypto:encryptRsaEcb(payload.toBytes(), cryptoPublickey, crypto:OAEPWithSHA1AndMGF1);
            check io:fileWriteBytes(encryptedFilePath, econtent);
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

service ftp:Service on dataOneL {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

import ballerina/crypto;
import ballerina/data.csv;
import ballerina/ftp;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;

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
VALUES ('${ientry.pid}', '${ientry.pid}', ${ientry.quantity})
ON DUPLICATE KEY UPDATE quantity = ${ientry.quantity};`);
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
    string pubkey = "/Users/chathura/work/projects/bi/samples/fs/keys/cert/cert.pem";
    crypto:PublicKey|error publicKey = crypto:decodeRsaPublicKeyFromCertFile(pubkey);
    if publicKey is error {
        log:printError("Failed to decode public key", 'error = publicKey);
    }
    return publicKey;
}

function getPrivateKey() returns crypto:PrivateKey|error {
    string prikey = "/Users/chathura/work/projects/bi/samples/fs/keys/cert/key.pem";
    crypto:PrivateKey|error privateKey = crypto:decodeRsaPrivateKeyFromKeyFile(prikey, "cce123");
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
            check io:fileWriteBytes("/Users/chathura/work/projects/bi/samples/fs/ftp1/cdata/efile", econtent);
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

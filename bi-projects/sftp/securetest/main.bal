// import ballerina/ftp;
// import ballerina/log;

// listener ftp:Listener inventoryUpdatesL = new (protocol = ftp:SFTP, path = "/upload", port = 2222, auth = {
//     credentials: {
//         username: "foo",
//         password: ""
//     },
//     privateKey: {
//         path: "/Users/chathura/work/projects/bi/samples/fs/keys/rsa2/id_rsa"
//     }
// }, host = "localhost", pollingInterval = 3);

// service ftp:Service on inventoryUpdatesL {
//     remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
//         do {
//             log:printInfo("Files changed.");
//         } on fail error err {
//             return error("unhandled error", err);
//         }
//     }
// }

import ballerina/ftp;

final ftp:Client ftpClient = check new ({
    protocol: "sftp",
    host: "localhost",
    port: 2222,
    auth: {
        credentials: {
            username: "foo",
            password: "pass"
        }
    }
});

import ballerina/ftp;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

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

final mysql:Client inventoryDB = check new ("localhost", dbUser, demoPass, "demo1", 3306);

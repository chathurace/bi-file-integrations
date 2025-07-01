import ballerina/ftp;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final ftp:Client ftpClient = check new ({
    protocol: "ftp",
    host: "localhost",
    port: 2120,
    auth: {
        credentials: {
            username: "testuser",
            password: "testpass"
        }
    }
});

final mysql:Client inventoryDB = check new ("localhost", dbUser, demoPass, "demo1", 3306);
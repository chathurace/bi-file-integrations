# File integrations

## Scenario 1

- Retail outlets upload inventory data as CSV files to a FTP server located in the HQ. These files are encrypted.
- WSO2 Integrator listens to this FTP folder.
- When a file is uploaded, WSO2 Integrator reads the file content, decrypts it and update the inventory database with the new data.
- Successfully processed files are written to a FTP folder named `processed`. Failed files are written to the `failed` FTP folder.

### Demo steps

- Start (or get access to) a FTP server. For example, https://hub.docker.com/r/fauria/vsftpd/ can be used to start a container based FTP server locally. Docker compose file for starting this FTP server can be found in `resources/ftp-server/docker-compose.yml`.
- Create folders named `upload`, `processed`, and `failed` in the FTP server.
- Create MySQL database using the script given in `resources/db/mysql-db.sql`.
- Create a key pair for encrypting and descryting file content using the command below:
``ssh-keygen -t rsa -b 4096 -f <output_folder>/id_rsa``
- Develop the integration flow shown in `bi-projects/ftp/main.bal` using BI. Alternatively, it's possible to open and show the BI project `bi-projects/ftp`.
- Upload the `resources/sample-data/data.csv` file to the `upload` FTP folder.
- Show the updated values in the `shop_inventory` database table.

## Scenario 2

Same as scenario 1, except that a SFTP server is used instead of a FTP server. Furthermore, files are not encrypted as SFTP uses encryption implicitly.

### Demo steps

- Start (or get access to) a SFTP server. For example, https://github.com/atmoz/sftp can be used to start a container based SFTP server locally. Docker compose file for starting this SFTP server can be found in `resources/sftp-server/docker-compose.yml`.
- Create folders named `upload`, `processed`, and `failed` in the FTP server.
- Create MySQL database using the script given in `resources/db/mysql-db.sql`.
- Develop the integration flow shown in `bi-projects/sftp/main.bal` using BI. Alternatively, it's possible to open and show the BI project `bi-projects/sftp`.
- Upload the `resources/sample-data/data.csv` file to the `upload` FTP folder.
- Show the updated values in the `shop_inventory` database table.



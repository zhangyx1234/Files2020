mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

mysql -uroot -pcapitek2019 -e "CREATE DATABASE nova_api;"
mysql -uroot -pcapitek2019 -e "CREATE DATABASE nova;"
mysql -uroot -pcapitek2019 -e "CREATE DATABASE nova_cell0;"


mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'capitek2019';"
mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'capitek2019';"


mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'capitek2019';"
mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'capitek2019';"


mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'capitek2019';"
mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'capitek2019';"


mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"



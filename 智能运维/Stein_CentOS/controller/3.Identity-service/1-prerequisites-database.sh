mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

mysql -uroot -pcapitek2019 -e "CREATE DATABASE keystone;"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

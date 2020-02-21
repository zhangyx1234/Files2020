mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

mysql -uroot -pcapitek2019 -e "CREATE DATABASE cinder;"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'capitek2019';"
mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

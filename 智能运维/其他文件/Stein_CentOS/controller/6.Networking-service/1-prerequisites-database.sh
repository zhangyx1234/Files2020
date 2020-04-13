mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

mysql -uroot -pcapitek2019 -e "CREATE DATABASE neutron;"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'capitek2019';"
mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"



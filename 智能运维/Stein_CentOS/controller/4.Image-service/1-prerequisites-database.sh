mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"

mysql -uroot -pcapitek2019 -e "CREATE DATABASE glance;"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'capitek2019';"

mysql -uroot -pcapitek2019 -e "show databases;"
mysql -uroot -pcapitek2019 -e "select Host,User from mysql.user;"



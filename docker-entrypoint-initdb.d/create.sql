CREATE DATABASE pdns character set utf8;
CREATE USER 'imperituroard'@'localhost' IDENTIFIED BY 'imperituroard';
CREATE USER 'imperituroard'@'%' IDENTIFIED BY 'imperituroard';
GRANT ALL ON pdns.* TO 'imperituroard'@'localhost' IDENTIFIED BY 'imperituroard';
GRANT ALL ON pdns.* TO 'imperituroard'@'%' IDENTIFIED BY 'imperituroard';
FLUSH PRIVILEGES;

CREATE DATABASE ppyn_development;
CREATE USER pixiuser@'localhost' IDENTIFIED BY ‘setup#123’; 
GRANT ALL ON ppyn_development.* TO 'pixiuser'@’localhost’ IDENTIFIED BY ‘setup#123’; 
GRANT ALL ON ppyn_development.* TO 'pixiuser'@’%’ IDENTIFIED BY ‘setup#123’; 
FLUSH PRIVILEGES; 

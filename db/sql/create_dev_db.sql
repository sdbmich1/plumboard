CREATE DATABASE ppyn_development;
CREATE USER pixi_user@'localhost' IDENTIFIED BY ‘setup#123’; 
GRANT ALL ON ppyn_development.* to pixi_user@.’localhost’ IDENTIFIED BY ‘setup#123’; 
GRANT ALL ON ppyn_development.* to pixi_user@.’%’ IDENTIFIED BY ‘setup#123’; 
FLUSH PRIVILEGES; 

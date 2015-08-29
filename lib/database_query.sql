DROP DATABASE IF EXISTS kums;

CREATE DATABASE kums;

use kums;

CREATE TABLE users (
	userID CHAR(36) PRIMARY KEY,
	firstName VARCHAR(100),
	password CHAR(128)
);


-- DELIMITER $;

-- CREATE TRIGGER bhavalan BEFORE INSERT ON users
-- FOR EACH ROW
-- BEGIN
-- 	SET NEW.firstName = 'subash';
-- END$

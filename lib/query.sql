DROP DATABASE IF EXISTS qoral_test;

CREATE DATABASE qoral_test;

USE qoral_test;

#DROP TABLE IF EXISTS users;

CREATE TABLE users(
    userId CHAR(36) NOT NULL DEFAULT 0,
    PRIMARY KEY (userId),
    username varchar(50) NOT NULL UNIQUE KEY,
    password CHAR(128),
    passwordSalt BINARY(16),
    passwordUpdated DATETIME,
    email VARCHAR(50) UNIQUE,
    tradeFee FLOAT UNSIGNED NOT NULL DEFAULT 0.1,
    2faEnabled BOOLEAN DEFAULT FALSE,
    2faSeed CHAR(255),
    verifiedStatus TINYINT DEFAULT 0,
    ipAddress VARCHAR(15),
    lastLoginDate DATETIME,
    tradeLock BOOLEAN DEFAULT TRUE,
    withdrawalLock BOOLEAN DEFAULT TRUE,
    authHash CHAR(100),
    tempPassword CHAR(128),
    tempPasswordExpirationAt CHAR(20),
    activationCode VARCHAR(7) DEFAULT NULL,
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL,
    status ENUM('disabled', 'active') DEFAULT 'active'
) ENGINE=InnoDB;

CREATE TABLE verification(
    userId CHAR(36),
    verificationId CHAR(36),
    PRIMARY KEY (userId, verificationId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    address VARCHAR(50),
    address2 VARCHAR(50),
    city VARCHAR(25),
    stateProvince VARCHAR(25),
    postal VARCHAR(15),
    country VARCHAR(38),
    photoType VARCHAR(20),
    photoSubmitDate DATETIME,
    photoExpire DATETIME,
    residencyType VARCHAR(20),
    residencySubmitDate DATETIME,
    residencyExpire DATETIME,
    verifiedStatus TINYINT,
    approvedStatus ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    photoFileLocation VARCHAR(150),
    residencyFileLocation VARCHAR(150),
    contactNumber VARCHAR(20),
    photoImage blob,
    residencyImage blob,
    dateOfBirth DATETIME,
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE candles(
    time BIGINT UNSIGNED PRIMARY KEY,
    open DECIMAL(15,5) UNSIGNED,
    close DECIMAL(15,5) UNSIGNED,
    high DECIMAL(15,5) UNSIGNED,
    low DECIMAL(15,5) UNSIGNED,
    volume DECIMAL(15,5) UNSIGNED,
    pair CHAR(15)
) ENGINE=InnoDB;

CREATE TABLE currencies(
    id SMALLINT AUTO_INCREMENT,
    PRIMARY KEY (id),
    currency VARCHAR(3) UNIQUE,
    longname VARCHAR(15) NOT NULL,
    symbol VARBINARY(4),
    ofType ENUM('crypto', 'fiat') NOT NULL,
    status ENUM('disabled', 'active') DEFAULT 'active'
) ENGINE=InnoDB;

CREATE TABLE currencyPairs(
    id SMALLINT AUTO_INCREMENT,
    currencyOne SMALLINT,
    currencyTwo SMALLINT,
    PRIMARY KEY (id, currencyOne, currencyTwo),
    FOREIGN KEY (currencyOne) REFERENCES currencies (id),
    FOREIGN KEY (currencyTwo) REFERENCES currencies (id),
    status ENUM('disabled', 'active')
) ENGINE=InnoDB;

CREATE TABLE withdrawCryptoAddress(
    userId CHAR(36),
    withdrawCryptoAddressId CHAR(36),
    currencyType SMALLINT,
    PRIMARY KEY (userId, withdrawCryptoAddressId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    address VARCHAR(60) CHARACTER SET BINARY,
    status ENUM('disabled', 'active'),
    createdAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE depositCryptoAddress(
    userId CHAR(36),
    depositCryptoAddressId CHAR(36),
    currencyType SMALLINT,
    PRIMARY KEY (userId, depositCryptoAddressId, currencyType),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    address VARCHAR(60) CHARACTER SET BINARY,
    status ENUM('disabled', 'active'),
    createdAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE withdrawCryptoHistory(
    userId CHAR(36),
    withdrawCryptoHistoryId CHAR(36),
    PRIMARY KEY (userId, withdrawCryptoHistoryId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    withdrawCryptoAddressId CHAR(36) NOT NULL,
    txId VARCHAR(100),
    quantity DECIMAL(15,8) UNSIGNED,
    status ENUM('pending', 'complete'),
    createdAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE depositCryptoHistory(
    userId CHAR(36),
    depositCryptoHistoryId CHAR(36),
    PRIMARY KEY (userId, depositCryptoHistoryId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    depositCryptoAddressId CHAR(36) NOT NULL,
    txId VARCHAR(100),
    quantity DECIMAL(15,5) UNSIGNED,
    status ENUM('pending', 'complete'),
    createdAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE orderBook(
    userId CHAR(36),
    orderBookId  CHAR(36),
    currencyPair SMALLINT,
    currencyType SMALLINT,
    PRIMARY KEY (orderBookId, userId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    FOREIGN KEY (currencyPair) REFERENCES currencyPairs (id),
    price DECIMAL(15,5) UNSIGNED,
    quantity DECIMAL(15,5) UNSIGNED,
    tradeFee FLOAT UNSIGNED NOT NULL,
    orderType ENUM('buy', 'sell', 'hidden', 'stop-loss', 'trailing-stop', 'buy-stop', 'sell-stop'),
    status ENUM( 'closed', 'pending', 'open', 'partial', 'filled'),
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE accounting(
    userId CHAR(36),
    accountingId  CHAR(36),
    currencyType SMALLINT,
    PRIMARY KEY (userId, accountingId, currencyType),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    currencyBalance DECIMAL(14,5) DEFAULT '0',
    tradeFee DECIMAL(4,3) DEFAULT '0.02',
    tradeLock BOOLEAN DEFAULT TRUE,
    withdrawalLock BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE ticket (
    ticketId MEDIUMINT UNSIGNED AUTO_INCREMENT,
    userId CHAR(36) NOT NULL,
    PRIMARY KEY (ticketId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    ticketType ENUM('General', 'Deposits', 'Withdrawals', 'Account'),
    priority ENUM('low', 'medium', 'high'),
    note TEXT NOT NULL,
    status ENUM('closed', 'open', 'pending'),
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE ticketNote (
    ticketNoteId MEDIUMINT UNSIGNED AUTO_INCREMENT,
    ticketId MEDIUMINT UNSIGNED,
    PRIMARY KEY (ticketNoteId),
    FOREIGN KEY (ticketId) REFERENCES ticket (ticketId),
    adminId CHAR(36),
    note TEXT,
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE transactionNontrade(
    userId CHAR(36),
    transactionNontradeId CHAR(36),
    currencyType SMALLINT,
    PRIMARY KEY (userId, transactionNontradeId, currencyType),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    quantity DECIMAL(15,5) UNSIGNED,
    comments VARCHAR(100),
    depositTime DATETIME
) ENGINE=InnoDB;

CREATE TABLE transactionTrade(
    transactionTradeId CHAR(36),
    orderId CHAR(36),
    PRIMARY KEY (orderId, transactionTradeId),
    FOREIGN KEY (orderId) REFERENCES orderBook (orderBookId),
    quantity DECIMAL(15,5) UNSIGNED,
    price DECIMAL(15,5) UNSIGNED,
    status CHAR(10),
    matchUuid CHAR(36),
    fee DECIMAL(13,5),
    matchFee DECIMAL(13,5),
    transactionType ENUM('buy', 'sell'),
    created DATETIME(6),
    updated TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE bankingWithdrawal(
    userId CHAR(36),
    withdrawalId CHAR(36),
    currencyType SMALLINT,
    PRIMARY KEY (userId, withdrawalId, currencyType),
    FOREIGN KEY (userId) REFERENCES users (userId),
    FOREIGN KEY (currencyType) REFERENCES currencies (id),
    bankAddress1 varchar(50),
    bankAddress2 varchar(50),
    bankCity varchar(50),
    bankStateProvince varchar(50),
    bankPostal varchar(50),
    bankCountry varchar(50),
    iban varchar(50),
    swift varchar(50),
    processAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE security(
    userId CHAR(36),
    apiSecret CHAR(36),
    apiKey CHAR(36) UNIQUE,
    PRIMARY KEY (userId, apiKey),
    FOREIGN KEY (userId) REFERENCES users (userId),
    nonce BIGINT DEFAULT '0',
    accountInfoPermission   BOOLEAN DEFAULT FALSE,
    tradePermission BOOLEAN DEFAULT FALSE,
    depositPermission BOOLEAN DEFAULT FALSE,
    withdrawPermission BOOLEAN DEFAULT FALSE,
    balancePermission BOOLEAN DEFAULT FALSE,
    transactionsPermission BOOLEAN DEFAULT FALSE,
    openOrdersPermission BOOLEAN DEFAULT FALSE,
    cancelOrdersPermission BOOLEAN DEFAULT FALSE,
    ipAddressFilter VARCHAR(15),
    status ENUM('disabled', 'active'),
    processAt DATETIME
) ENGINE=InnoDB;

CREATE TABLE notifications(
    userId CHAR(36),
    PRIMARY KEY (userId),
    FOREIGN KEY (userId) REFERENCES users (userId),
    alert BOOLEAN DEFAULT TRUE,
    chat BOOLEAN DEFAULT TRUE,
    email BOOLEAN DEFAULT TRUE,
    updatedAt TIMESTAMP NOT NULL
) ENGINE=InnoDB;

CREATE TABLE siteOptions(
    featureName VARCHAR(25),
    status ENUM('enabled', 'disabled')
) ENGINE=InnoDB;


CREATE TABLE adminPermissions(
    permissionId SMALLINT,
    PRIMARY KEY (permissionId),
    permissionType CHAR(20),
    permissions VARCHAR(10)
);

CREATE TABLE admin(
    adminId CHAR(36) NOT NULL DEFAULT 0,
    permissionId SMALLINT NOT NULL,
    PRIMARY KEY (adminId),
    FOREIGN KEY (permissionId) REFERENCES adminPermissions (permissionId),
    username varchar(50) NOT NULL UNIQUE KEY,
    password CHAR(128),
    passwordSalt BINARY(16),
    passwordUpdated DATETIME,
    email VARCHAR(50) UNIQUE,
    status VARCHAR(10),
    createdAt DATETIME,
    updatedAt TIMESTAMP NOT NULL
);

/* Insert default options */
INSERT INTO siteOptions (featureName, status) VALUES ('limitOrder', 'enabled');
INSERT INTO siteOptions (featureName, status) VALUES ('marketOrder', 'enabled');

/* Insert some default currencies */
INSERT INTO currencies (currency, longname, symbol, ofType) VALUES ('BTC', 'Bitcoin', 'à¸¿', 'crypto');
INSERT INTO currencies (currency, longname, ofType) VALUES ('XRP', 'Ripple', 'crypto');
INSERT INTO currencies (currency, longname, symbol, ofType) VALUES ('USD', 'USD', '$', 'fiat');
INSERT INTO currencies (currency, longname, symbol, ofType) VALUES ('YEN', 'YEN', 'Â¥', 'fiat');
INSERT INTO currencies (currency, longname, symbol, ofType) VALUES ('EUR', 'Euro', 'â‚¬', 'fiat');
INSERT INTO currencies (currency, longname, symbol, ofType) VALUES ('LTC', 'Litecoin', 'Å�', 'crypto');

/* Insert some default pairs */
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (1, 3);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (1, 5);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (1, 4);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (1, 2);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (2, 3);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (2, 4);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (2, 5);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (6, 3);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (6, 4);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (6, 5);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (1, 6);
INSERT INTO currencyPairs(currencyOne, currencyTwo) VALUES (2, 6);

/* Create Trading Pair View */
CREATE VIEW tradingPairs AS
SELECT t.id, t.currencyOne, t.currencyTwo, c1.currency AS 'Bid', c2.currency AS 'Ask' , c2.symbol
FROM currencyPairs AS t
INNER JOIN currencies AS c1 ON c1.id=t.currencyOne
INNER JOIN currencies AS c2 ON c2.id=t.currencyTwo;

/*WHERE t.id = 1; */

CREATE VIEW user_balances AS
SELECT u.userId AS userId,
IFNULL(ac.currencyBalance,0) AS total,
ac.currencyType, ct.currency,
IFNULL(ROUND(SUM(ob.price*ob.quantity),8),0) AS outstanding,
IFNULL(ROUND(ac.currencyBalance-IFNULL(SUM(ob.price*ob.quantity),0),8),0) AS available
FROM users u
inner JOIN accounting ac ON ac.userId = u.userId
left JOIN orderBook ob ON ob.currencyType = ac.currencyType AND ob.orderType='buy' AND ob.status = 'open' AND ac.userId = ob.userId
inner join currencies ct on ac.currencyType = ct.id
group by u.userId, ac.currencyType;

/* Admin Related */

delimiter $
CREATE TRIGGER init_admin BEFORE INSERT ON admin
FOR EACH ROW
BEGIN
    DECLARE u_id CHAR(36);
    DECLARE u_salt BINARY(16);
    DECLARE u_pass CHAR(128) CHARACTER SET BINARY;
    SET u_id = UUID();
    SET u_salt = RANDOM_BYTES(16);
    SET u_pass = NEW.password;
    SET NEW.adminId = u_id;
    SET NEW.passwordSalt = u_salt;
    SET NEW.password = SHA2(CONCAT(u_id, u_pass, u_salt), 512);
END$

CREATE PROCEDURE validate_admin_login(p_username CHAR(36), p_password CHAR(128) CHARACTER SET BINARY)
BEGIN
    DECLARE p_salt BINARY(16);
    DECLARE u_uid CHAR(36);
    SET u_uid = (SELECT adminId FROM admin WHERE username = p_username LIMIT 1);
    SET p_salt = (SELECT passwordSalt FROM admin WHERE username = p_username LIMIT 1);
    IF (SELECT EXISTS ( SELECT adminId FROM admin WHERE username = p_username AND password = find_hash(u_uid, p_password, p_salt) ) ) THEN
        SELECT adminId, email, username FROM admin WHERE username = p_username;
    ELSE
        SELECT adminId FROM admin WHERE username = p_username AND password = p_password;
    END IF;
END$$

$
delimiter ;

/* insert admin authentication levels */
INSERT INTO adminPermissions (permissionId, permissionType, permissions) VALUES ('0', 'disabled', '0-0-0-0');
INSERT INTO adminPermissions (permissionId, permissionType, permissions) VALUES ('1', 'regular', '0-0-0-0');
INSERT INTO adminPermissions (permissionId, permissionType, permissions) VALUES ('2', 'customer service', '0-0-0-0');
INSERT INTO adminPermissions (permissionId, permissionType, permissions) VALUES ('10', 'superuser', '1-1-1-1');

/* insert admin super user */
INSERT INTO admin (username, password, email, permissionId) VALUES ('admin','admin123','admin@admin.com', 10);



delimiter $
CREATE TRIGGER init_users BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    DECLARE u_id CHAR(36);
    DECLARE u_salt BINARY(16);
    DECLARE u_pass CHAR(128) CHARACTER SET BINARY;
    SET u_id = UUID();
    SET u_salt = RANDOM_BYTES(16);
    /* SET u_salt = 'tempSalt'; */
    SET u_pass = NEW.password;
    SET NEW.userId = u_id;
    SET NEW.passwordSalt = u_salt;
    SET NEW.password = SHA2(CONCAT(u_id, u_pass, u_salt), 512);
END$

CREATE TRIGGER users_balance AFTER insert ON users
FOR EACH ROW
BEGIN
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 1, 100, FALSE, FALSE);
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 2, 1000000, FALSE, FALSE);
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 3, 5000, FALSE, FALSE);
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 4, 1000000, FALSE, FALSE);
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 5, 2500, FALSE, FALSE);
    INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (NEW.userId, UUID(), 6, 2500, FALSE, FALSE);
    #INSERT INTO notifications (userId, alert, chat, email) values (NEW.userId, TRUE, TRUE, TRUE);
END$$

$
delimiter ;


/* temp procedures/functions/triggers */
delimiter $

CREATE FUNCTION find_hash(p_id CHAR(36), p_pass CHAR(128), p_salt BINARY(16))
RETURNS CHAR(128)
BEGIN
    RETURN (SELECT SHA2(CONCAT(p_id, p_pass, p_salt), 512) as hashed);
END $

CREATE PROCEDURE transactionNontrade_insert(userId CHAR(36), quantity DECIMAL(15,5) UNSIGNED, currencyType SMALLINT, comments CHAR(100))
BEGIN
        INSERT INTO transactionNontrade (userId, transactionNontradeId, quantity, currencyType, comments, depositTime) VALUES (userId, UUID(), quantity, currencyType, comments, now());
END$

CREATE PROCEDURE create_user(p_username CHAR(36), p_password CHAR(128) CHARACTER SET BINARY, p_email CHAR(50))
BEGIN
    DECLARE err BOOLEAN;
    DECLARE activationCode VARCHAR(10);
    set activationCode = (SELECT LEFT(UUID(), 7));
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE username = p_username or email = p_email) ) THEN
        SET err = TRUE;
    ELSE
        INSERT INTO users (username, password, email, activationCode) VALUES (p_username, p_password, p_email, activationCode);
  SET err = FALSE;
    END IF;
 SELECT err, activationCode;
END $

CREATE PROCEDURE activateUser(p_username CHAR(36), p_activationCode VARCHAR(7))
BEGIN
    DECLARE err BOOLEAN;
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE username = p_username AND activationCode = p_activationCode) ) THEN
        SET err = FALSE;
  UPDATE users SET status = 'active', activationCode = null WHERE username = p_username;
    ELSE
        SET err = TRUE;
    END IF;
 SELECT err;
END $

CREATE PROCEDURE user_twofactor_status_initial(u_id CHAR(36), state BOOLEAN, 2fa_secret CHAR(255))
BEGIN
    DECLARE err BOOLEAN;
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE userId = u_id ) ) THEN
        UPDATE users SET 2faEnabled = state , 2faSeed = 2fa_secret WHERE userId = u_id;
    ELSE
        SET err = TRUE;
    END IF;
END $

CREATE PROCEDURE user_twofactor_status(u_id CHAR(36))
BEGIN
    DECLARE err BOOLEAN;
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE userId = u_id ) ) THEN
        SELECT 2faEnabled, 2faSeed FROM users WHERE userId = u_id;
    ELSE
        SET err = TRUE;
    END IF;
END$

CREATE PROCEDURE user_info(2faSeed_value CHAR(255))
BEGIN
    DECLARE err BOOLEAN;
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE 2faSeed = 2faSeed_value ) ) THEN
        SELECT * FROM users WHERE 2faSeed = 2faSeed_value;
    ELSE
        SET err = TRUE;
    END IF;
END$

CREATE PROCEDURE twofactor_enable(u_id CHAR(36), state BOOLEAN, 2fa_secret CHAR(255))
BEGIN
    DECLARE err BOOLEAN;
    IF ( SELECT EXISTS ( SELECT username FROM users WHERE userId = u_id ) ) THEN
        UPDATE users SET 2faEnabled = state , 2faSeed = 2fa_secret WHERE userId = u_id;
    ELSE
        SET err = TRUE;
    END IF;
END $


CREATE PROCEDURE insert_data(tablename TEXT, field_name TEXT, field_value TEXT)
BEGIN
        SET @insert_data =CONCAT('INSERT INTO ',tablename,'(',field_name,') ','VALUES','(',field_value,')');
    select @insert_data;
    PREPARE exe_insert FROM @insert_data;
    EXECUTE exe_insert;
    DEALLOCATE PREPARE exe_insert;
END $

CREATE PROCEDURE validate_login(p_username CHAR(36), p_password CHAR(128) CHARACTER SET BINARY, p_ipAddress CHAR(15))
BEGIN
    DECLARE p_salt BINARY(16);
    DECLARE u_uid CHAR(36);
    DECLARE secret CHAR(128);

    SET u_uid = (SELECT userId FROM users WHERE username = p_username LIMIT 1);
    SET p_salt = (SELECT passwordSalt FROM users WHERE username = p_username LIMIT 1);
    IF (SELECT EXISTS ( SELECT userId FROM users WHERE username = p_username AND password = find_hash(u_uid, p_password, p_salt) ) ) THEN
        SET secret = SHA2(CONCAT(u_uid, NOW()), 512);
        UPDATE users set authHash = secret, ipAddress = p_ipAddress, lastLoginDate = NOW(), tempPassword = NULL WHERE username = p_username and passwordSalt = p_salt;
        SELECT userId, authHash, email, username, 2faEnabled as twoFactorStatus, 2faSeed as twoFactorSeed, tradeFee as tradeFees FROM users WHERE username = p_username;
        select find_hash(u_uid, p_password, p_salt) ;
    ELSE
        SELECT userId FROM users WHERE username = p_username AND password = p_password;
    END IF;
END$

CREATE PROCEDURE api_access_permission_add(p_columns CHAR(255), p_values CHAR(255))
BEGIN
    SET @insert_data = CONCAT('INSERT INTO security(',p_columns,') ','VALUES','(',p_values,')');
    select @insert_data;
    PREPARE exe_insert FROM @insert_data;
    EXECUTE exe_insert;
    DEALLOCATE PREPARE exe_insert;
END $

CREATE PROCEDURE api_access_permission_remove(p_uid CHAR(36), p_apiKey CHAR(36))
BEGIN
    UPDATE security set status = 0 WHERE apiKey = p_apiKey AND userId = p_uid;
END $

CREATE PROCEDURE api_access_permission(p_uid CHAR(36))
BEGIN

    SELECT apiSecret, apiKey, CONCAT_WS(', ',IF(accountInfoPermission = 0, NULL, CONCAT('Account Info')),IF(tradePermission = 0, NULL, CONCAT('Trade')),IF(depositPermission = 0, NULL, CONCAT('Deposit')),IF(withdrawPermission = 0, NULL, CONCAT('Withdraw')),IF(balancePermission = 0, NULL, CONCAT('Balance')),IF(transactionsPermission = 0, NULL, CONCAT('Transactions')),IF(openOrdersPermission = 0, NULL, CONCAT('Open Orders')),IF(cancelOrdersPermission = 0, NULL, CONCAT('Cancel Orders')) ) As permissions FROM security WHERE userId = p_uid AND status = 1;

END $

CREATE PROCEDURE qoral_trading_pairs()
BEGIN
    SELECT t.id, c1.currency AS 'Bid', c2.currency AS 'Ask' , c2.symbol AS 'Symbol'
    FROM currencyPairs AS t
    INNER JOIN currencies AS c1 ON c1.id=t.currencyOne
    INNER JOIN currencies AS c2 ON c2.id=t.currencyTwo
    order by c1.currency;
END$

CREATE PROCEDURE transactionTrade_insert(p_uid CHAR(36), p_ob_id CHAR(36), p_other_ob_id CHAR(36), finalized_price DECIMAL(15,5) UNSIGNED, finalized_quantity DECIMAL(15,5) UNSIGNED, finalized_status CHAR(36), p_orderType VARCHAR(20))
BEGIN
    INSERT INTO transactionTrade ( transactionTradeId, orderId, quantity, price, status, pair_uuid, fee, transactionType ) VALUES ( UUID(), p_ob_id, finalized_quantity, finalized_price, finalized_status, p_other_ob_id, 0, p_orderType );
END$

CREATE PROCEDURE update_orderBook(p_uid CHAR(36), p_orb_id CHAR(36), finalized_quantity DECIMAL(15,5) UNSIGNED, finalized_status CHAR(36))
BEGIN
    UPDATE orderBook SET quantity = finalized_quantity, status = finalized_status WHERE orderBookId = p_orb_id AND userId = p_uid;
END$

CREATE PROCEDURE populate_balances(p_id CHAR(36))
BEGIN
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 1;
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 2;
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 3;
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 4;
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 5;
    UPDATE accounting SET currencyBalance = 100000000 WHERE userId = p_id AND currencyType = 6;
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 1, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 2, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 3, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 5, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 6, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 7, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 8, 100000000, FALSE, FALSE);
#   INSERT INTO accounting (userId, accountingId, currencyType, currencyBalance, tradeLock, withdrawalLock) values (p_id, UUID(), 9, 100000000, FALSE, FALSE);
END$

CREATE PROCEDURE populate_orderbook(p_id CHAR(36), p_orderType VARCHAR(20))
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE max INT DEFAULT 20;
    DECLARE r_price DECIMAL(15,5) UNSIGNED;
    DECLARE r_amount DECIMAL(15,5) UNSIGNED;
    DECLARE r_orderType TINYINT;
    DECLARE c_type TINYINT;

#   DECLARE userList CURSOR FOR SELECT userId FROM users;

#   OPEN userList;

    START TRANSACTION;
    while i < max DO
#       userLoop =
        SET r_amount = FLOOR(RAND()*(5-1+1))+ROUND(RAND(), 5);

        IF p_orderType = 'buy' THEN
            SET r_price = FLOOR(RAND()*(100-1+600))+RAND();
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 1, 3, ROUND(r_price, 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 2, 5, ROUND((r_price/2), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 3, 4, ROUND((r_price*101.88), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 4, 2, ROUND((r_price/0.0041), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 5, 3, ROUND((r_price/100000), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 6, 4, ROUND((r_price*101.88), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 7, 5, ROUND((r_price/200000), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 8, 3, ROUND((r_price/64), 5), r_amount, "open", 0.1);

        ELSEIF p_orderType = 'sell' THEN
            SET r_price = FLOOR(RAND()*(100-1+600))+RAND();
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 1, 1, ROUND(r_price, 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 2, 1, ROUND((r_price/2), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 3, 1, ROUND((r_price*101.88), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 4, 1, ROUND((r_price/0.0041), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 5, 2, ROUND((r_price/100000), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 6, 2, ROUND((r_price*101.88), 5), r_amount, "open", 0.1);
            INSERT INTO orderBook (userId, orderBookId, orderType, currencyPair, currencyType, price, quantity, status, tradeFee) VALUES (p_id, UUID(), p_orderType, 7, 2, ROUN
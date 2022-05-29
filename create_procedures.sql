USE iwx;
/*****************************************************FUNCTIONS*********************************************************/

DROP FUNCTION IF EXISTS email_exist;
DELIMITER //
CREATE FUNCTION email_exist(
  email_param VARCHAR(255)
)
RETURNS TINYINT
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE email_var VARCHAR(255) DEFAULT NULL;
  
  SELECT customer_email INTO email_var
  FROM iwx.customers
  WHERE customer_email = email_param;
  
  IF email_var IS NOT NULL THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
END //
DELIMITER ;


DROP FUNCTION IF EXISTS get_customer_id_by_email;
DELIMITER //
CREATE FUNCTION get_customer_id_by_email(
  email_param VARCHAR(255)
)
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE customer_id_var INT;
  
  SELECT customer_id INTO customer_id_var
  FROM iwx.customers
  WHERE customer_email = email_param;
  
  RETURN customer_id_var;
END //
DELIMITER ;


DROP FUNCTION IF EXISTS verify_password;
DELIMITER //
CREATE FUNCTION verify_password(
  email_param     VARCHAR(255),
  password_param  VARCHAR(255)
)
RETURNS TINYINT
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE password_var VARCHAR(255);
  
  SELECT customer_password INTO password_var
  FROM iwx.customers
  WHERE customer_email = email_param;
  
  IF password_var = password_param THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
END //
DELIMITER ;

/*******************************************************PROCEDURES*****************************************************************/

DROP PROCEDURE IF EXISTS GET_PRODUCTS;
DELIMITER //
CREATE PROCEDURE GET_PRODUCTS(
  limit_param INT,
  offset_param INT
)
BEGIN
  SELECT product_id        AS id, 
		 product_image_url AS url,
		 product_name      AS 'name',
		 product_price     AS price
  FROM iwx.products
  LIMIT limit_param OFFSET offset_param;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS GET_PRODUCT_BY_ID;
DELIMITER //
CREATE PROCEDURE GET_PRODUCT_BY_ID(
  product_id_param INT
)
BEGIN
  SELECT product_id       AS id, 
		 product_image_url AS url,
		 product_name      AS 'name',
		 product_price     AS price,
         supplier_id
  FROM iwx.products 
  WHERE product_id = product_id_param;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS ADD_CUSTOMER;
DELIMITER //
CREATE PROCEDURE ADD_CUSTOMER (
  user_details JSON
)
BEGIN
  IF email_exist( JSON_UNQUOTE(JSON_EXTRACT(user_details, '$.email'))  ) = TRUE THEN
     SIGNAL SQLSTATE '23000'
       SET MESSAGE_TEXT = 'Email already exist. Sign-in with a different email or login',
           MYSQL_ERRNO  = 1062;
  ELSE
     INSERT INTO iwx.customers (customer_email, customer_password)
     VALUES (JSON_UNQUOTE(JSON_EXTRACT(user_details, '$.email')), 
             JSON_UNQUOTE(JSON_EXTRACT(user_details, '$.password')));
  END IF;
  
  SELECT customer_id AS id, customer_email AS email
  FROM iwx.customers
  WHERE customer_email = JSON_UNQUOTE(JSON_EXTRACT(user_details, '$.email'));
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS VERIFY_CUSTOMER;
DELIMITER //
CREATE PROCEDURE VERIFY_CUSTOMER(
  user_login_details JSON
)
BEGIN
  IF email_exist( JSON_UNQUOTE(JSON_EXTRACT(user_login_details, '$.email')) ) = FALSE THEN
     SIGNAL SQLSTATE '02000'
       SET MESSAGE_TEXT = 'E-mail does not exist',
	       MYSQL_ERRNO  = 1329;
  END IF;
  
  IF verify_password( JSON_UNQUOTE(JSON_EXTRACT(user_login_details, '$.email')), 
                      JSON_UNQUOTE(JSON_EXTRACT(user_login_details, '$.password'))) = FALSE THEN
     SIGNAL SQLSTATE '02000'
       SET MESSAGE_TEXT = 'Password incorrect',
	       MYSQL_ERRNO  = 1329;
  END IF;
 
  SELECT customer_id AS id, customer_email AS email
  FROM iwx.customers
  WHERE customer_email = JSON_UNQUOTE(JSON_EXTRACT(user_login_details, '$.email'));
 
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS ADD_ORDER;
DELIMITER //
CREATE PROCEDURE ADD_ORDER(
  order_param  JSON
)
BEGIN
  DECLARE duplicate_entry_for_key TINYINT DEFAULT FALSE;
  
  START TRANSACTION;
	BEGIN
      DECLARE EXIT HANDLER FOR 1062
         SET duplicate_entry_for_key = TRUE;
        
      INSERT INTO iwx.orders (order_id, customer_id, RRR, cart_items, cart_total)
      VALUES  ( JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.orderId') ), 
			    JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.id') ), 
			    JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.RRR') ), 
                JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.cart_items') ), 
                JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.amount') )
			  );
    
      INSERT INTO iwx.billing_info
      VALUES ( JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.orderId') ), 
               JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.name') ), 
               JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.phone') ),
			   JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.state') ), 
			   JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.lga') ), 
               JSON_UNQUOTE( JSON_EXTRACT(order_param, '$.address') )
			 );    
    END;
    
  IF duplicate_entry_for_key = FALSE THEN
     COMMIT;
  ELSE
    ROLLBACK;
    SIGNAL SQLSTATE '23000'
       SET MESSAGE_TEXT = 'Order already placed.',
           MYSQL_ERRNO  = 1062;
  END IF;
END //
DELIMITER ; 


DROP PROCEDURE IF EXISTS GET_CUSTOMER_ORDERS;
DELIMITER //
CREATE PROCEDURE GET_CUSTOMER_ORDERS(
  customer_id_param INT
)
BEGIN
  SELECT order_id AS orderId,  RRR, order_date AS orderDate
  FROM iwx.orders
  WHERE customer_id = customer_id_param
  ORDER BY order_date DESC;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS GET_SUPPLIER_BY_ID;
DELIMITER //
CREATE PROCEDURE GET_SUPPLIER_BY_ID (
   supplier_id_param INT
)
BEGIN
  SELECT *
  FROM iwx.suppliers
  WHERE supplier_id = supplier_id_param;
END //
DELIMITER ; 

/************************************************************************************************************/

DROP PROCEDURE IF EXISTS GET_STATES;
DELIMITER //
CREATE PROCEDURE GET_STATES()
BEGIN
  SELECT * FROM iwx.states;
END // 
DELIMITER ;


DROP PROCEDURE IF EXISTS GET_LOCAL_GOVERNMENTS;
DELIMITER //
CREATE PROCEDURE GET_LOCAL_GOVERNMENTS(
  state_param VARCHAR(25)
)
BEGIN
  SELECT local_government
  FROM iwx.localities
  WHERE REGEXP_SUBSTR(state, state_param) = state_param;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS  ADD_UNVERIFIED_USER;
DELIMITER //
CREATE PROCEDURE ADD_UNVERIFIED_USER (
  email_param     VARCHAR(255),
  password_param  VARCHAR(255)
)
BEGIN
	INSERT INTO iwx.unverified_users (email, `password`)
	  VALUES (email_param, password_param);
      
	SELECT * FROM iwx.unverified_users
	WHERE email = email_param;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS  GET_UNVERIFIED_USER_BY_ID;
DELIMITER //
CREATE PROCEDURE GET_UNVERIFIED_USER_BY_ID (
  user_id_param INT
)
BEGIN 
  SELECT email, `password`
  FROM   iwx.unverified_users
  WHERE  user_id = user_id_param;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS EMAIL_EXIST;
DELIMITER //
CREATE PROCEDURE EMAIL_EXIST (
  email_param VARCHAR(255)
)
BEGIN
  SELECT email_exist( email_param ) AS email_exist;
END //
DELIMITER ;

/*****************************************************TRIGGERS*************************************************************/

DROP TRIGGER IF EXISTS customers_after_insert;
DELIMITER //
CREATE TRIGGER customers_after_insert
  AFTER INSERT ON iwx.customers
  FOR EACH ROW
BEGIN
  DELETE FROM iwx.unverified_users
  WHERE email = NEW.customer_email;
END //
DELIMITER ;

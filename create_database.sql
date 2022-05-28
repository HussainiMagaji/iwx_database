/* Author:  Hassan Muhammad Magaji
   Date:    2022-04-29
   Version: 2.0.0
   Disclaimer: this piece of software is streactly owned by iwx,
			   no part or whole of this piece should be used or
               replecated by any person, organization or company.
   iwx - importWithXarah, All rights reserved.
*/
/*
DROP DATABASE IF EXISTS iwx;
CREATE DATABASE iwx;
USE iwx;

DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
  supplier_id              INT                             AUTO_INCREMENT,
  supplier_account_number  CHAR(10),
  supplier_first_name      VARCHAR(25)                     NOT NULL,
  supplier_second_name     VARCHAR(25)                     NOT NULL,
  supplier_email           VARCHAR(50)    UNIQUE           NOT NULL,
  supplier_phone_number    CHAR(11)       UNIQUE           NOT NULL,
  CONSTRAINT suppliers_pk PRIMARY KEY (supplier_id, supplier_account_number)
);*/
-- INSERT INTO suppliers /*********************************************************************************************************/
-- VALUES (1, '0123456789', 'Yusuf', "Ja'e", 'yusufjae@gmail.com', '07068464632');

/*
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
  category_id    INT           PRIMARY KEY   AUTO_INCREMENT,
  category_name  VARCHAR(25)   NOT NULL
);*/
-- INSERT INTO categories  /*******************************************************************************************************/
-- VALUES (1, "FASHION");
/*

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  customer_id            INT              PRIMARY KEY  AUTO_INCREMENT,
  customer_email         VARCHAR(50)      UNIQUE,
  customer_password      VARCHAR(25)      NOT NULL
);


DROP TABLE IF EXISTS products;
CREATE TABLE products (
  product_id         INT               PRIMARY KEY   AUTO_INCREMENT,
  product_image_url  VARCHAR(100)      NOT NULL,
  product_category   INT               NOT NULL,
  supplier_id        INT               NOT NULL,
  product_name       VARCHAR(25)       NOT NULL,
  product_price      INT               NOT NULL,
  product_stock      INT               NOT NULL,
  product_size       INT               NOT NULL,
  product_condition  VARCHAR(25)       NOT NULL,
  CONSTRAINT products_fk_suppliers 
	FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id),
  CONSTRAINT products_fk_categories 
	FOREIGN KEY (product_category) REFERENCES categories (category_id)
);
LOAD DATA INFILE '/programData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS  TERMINATED BY ','
		ENCLOSED BY   '"';


DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  order_id          VARCHAR(255)      PRIMARY KEY,
  customer_id       INT               NOT NULL,
  RRR               VARCHAR(255)      UNIQUE        NOT NULL,
  cart_items        JSON              NOT NULL,
  cart_total        DECIMAL(9, 2),
  order_date        DATETIME          DEFAULT NOW(),
  delivery_status   VARCHAR(25)       DEFAULT 'PENDING',
  delivery_date     DATE              DEFAULT NULL,
  CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id)
);

DROP TABLE IF EXISTS billing_info;
CREATE TABLE billing_info (
  order_id                     VARCHAR(255)    UNIQUE     NOT NULL,
  contact_name                 VARCHAR(255)    NOT NULL,
  contact_phone_number         VARCHAR(25)     NOT NULL,
  contact_state                VARCHAR(25)     NOT NULL,
  contact_local_government     VARCHAR(25)     NOT NULL,
  contact_address              VARCHAR(255)    NOT NULL,
  CONSTRAINT billing_fk_orders FOREIGN KEY (order_id)
    REFERENCES orders (order_id)
); 

DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (
  session_id   VARCHAR(128)   PRIMARY KEY,
  expires      INT            UNSIGNED        NOT NULL,
  `data`       MEDIUMTEXT
);


/* A seperate database to reference the current states and local governments in 
   the Federal Republic of Nigeria. */
/*   
   
DROP TABLE IF EXISTS localities;
CREATE TABLE localities (
  serial_number        INT           PRIMARY KEY,
  local_government     VARCHAR(50),
  state                VARCHAR(25)
);

LOAD DATA INFILE '/programData/MySQL/MySQL Server 8.0/Uploads/list_of_local_government_areas_of_nigeria.csv'
INTO TABLE localities
FIELDS  TERMINATED BY ','
		ENCLOSED BY   '"';	
 
 
 DROP VIEW IF EXISTS states;
 CREATE OR REPLACE VIEW states AS 
   SELECT DISTINCT substring(state, 1, length(state) - 1) AS state
   FROM iwx.localities
   ORDER BY state ASC;
*/
DROP TABLE IF EXISTS unverified_users;
CREATE TABLE unverified_users (
  user_id    INT            PRIMARY KEY   AUTO_INCREMENT,
  email      VARCHAR(255)   UNIQUE        NOT NULL,
  `password` VARCHAR(255)   NOT NULL
);
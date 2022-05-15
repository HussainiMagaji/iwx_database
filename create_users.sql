DROP USER IF EXISTS HASSAN;
CREATE USER HASSAN IDENTIFIED BY '51627384';

GRANT ALL PRIVILEGES
ON iwx.*
TO HASSAN
WITH GRANT OPTION;

DROP USER IF EXISTS 'iwx_web_server'@'localhost';
CREATE USER 'iwx_web_server'@'localhost' IDENTIFIED BY 'default';

DROP ROLE IF EXISTS products_and_carts_entry;
CREATE ROLE products_and_carts_entry;

GRANT SELECT -- REVIEW FOR DELETION
ON iwx.products
TO products_and_carts_entry;

GRANT ALL  -- REVIEW FOR DELETION
ON iwx.sessions
TO products_and_carts_entry;

GRANT SELECT, UPDATE, DELETE -- REVIEW FOR DELETION
ON iwx.orders
TO products_and_carts_entry;

GRANT SELECT
ON iwx.localities
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.ADD_CUSTOMER
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.ADD_ORDER
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.GET_CUSTOMER_ORDERS
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.GET_PRODUCTS
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.GET_PRODUCT_BY_ID
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.VERIFY_CUSTOMER
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.GET_STATES
TO products_and_carts_entry;

GRANT EXECUTE
ON PROCEDURE iwx.GET_LOCAL_GOVERNMENTS
TO products_and_carts_entry;

GRANT products_and_carts_entry TO 'iwx_web_server'@'localhost';
SET DEFAULT ROLE products_and_carts_entry TO 'iwx_web_server'@'localhost';
CREATE SCHEMA IF NOT EXISTS enums;

CREATE TYPE enums.cart_status_enum AS ENUM (
	'active', 
	'ordered',
	'cancelled'
);

CREATE TYPE enums.order_status_enum AS ENUM (
	'pending', 
	'processing',
	'shipped',
	'delivered',
	'cancelled',
	'returned'
);

CREATE TABLE customers ( 
	id                   integer  NOT NULL GENERATED ALWAYS AS IDENTITY,
	first_name           varchar(50)  NOT NULL,
	last_name            varchar(50)  NOT NULL,
	street_address       varchar(100)  NOT NULL,
	apt_number           varchar(10),
	city                 varchar(50)  NOT NULL,
	"state"              varchar(2)  NOT NULL,
	zip_code             varchar(10)  NOT NULL,
	password_hashed      text NOT NULL,
	email                varchar(50)  NOT NULL,
	CONSTRAINT pk_customers PRIMARY KEY ( id ),
	CONSTRAINT unq_customers_email UNIQUE ( email ) 
 );

CREATE TABLE products ( 
	id                   integer  NOT NULL GENERATED ALWAYS AS IDENTITY,
	name                 varchar(100)  NOT NULL,
	description          varchar(1000)  NOT NULL,
	unit_price           numeric(7,2)  NOT NULL,
	inventory_units      integer DEFAULT 0 NOT NULL,
	created_date		 timestamptz NOT NULL,
	update_date 		 timestamptz,
	CONSTRAINT pk_products PRIMARY KEY ( id )
 );

--Each customer id can have only one active cart and cart data is deleted when customers close their account
CREATE TABLE carts ( 
	id                   integer  NOT NULL GENERATED ALWAYS AS IDENTITY,
	user_id              integer  NOT NULL,
	cart_status  enums.cart_status_enum NOT NULL,
	cart_created         timestamptz  NOT NULL,
	cart_submit_date	 timestamptz,
	cart_cancel_date	 timestamptz,
	cart_status_updated  timestamptz,
	CONSTRAINT pk_carts_id PRIMARY KEY ( id ),
	CONSTRAINT fk_carts_user_id FOREIGN KEY (user_id) REFERENCES customers(id) ON DELETE CASCADE,
	CONSTRAINT unq_customers_carts_user_id UNIQUE ( user_id ) WHERE cart_status = 'active',
	CONSTRAINT ck_carts_cart_submit_date_cart_status CHECK 
		(cart_status = 'ordered' AND cart_submit_date IS NOT NULL) OR
		(cart_status IN('active', 'cancelled') AND cart_submit_date = IS NULL)
 );

CREATE TABLE carts_items ( 
	cart_id              integer  NOT NULL,
	product_id           integer  NOT NULL,
	quantity             integer  NOT NULL,
	unit_price                numeric(7,2)  NOT NULL,
	CONSTRAINT pk_carts_items PRIMARY KEY (cart_id, product_id),
	CONSTRAINT fk_carts_items_cart_id FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
	CONSTRAINT ck_cart_quantity CHECK (quantity > 0)
 );

CREATE TABLE orders ( 
	id                   integer  NOT NULL GENERATED ALWAYS AS IDENTITY,
	cart_id              integer  NOT NULL,
	order_date           timestamptz  NOT NULL,
	update_date			 timestamptz,
	order_status enums.order_status_enum NOT NULL,
	cancel_order_date      timestamptz,
	total_order_sales    numeric(10,2)  NOT NULL,
	CONSTRAINT pk_orders_id PRIMARY KEY ( id )
 );

CREATE TABLE ordered_items (
	order_id 			 integer NOT NULL,
	product_id           integer  NOT NULL,
	product_name		 varchar(100) NOT NULL, 
	quantity             integer  NOT NULL,
	unit_price           numeric(7,2)  NOT NULL,
	CONSTRAINT pk_ordered_items_cart_id_product_id PRIMARY KEY (order_id, product_id),
	CONSTRAINT fk_ordered_items_order_id FOREIGN KEY (order_id) REFERENCES orders(id)
);

--Indexes



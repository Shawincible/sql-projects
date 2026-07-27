/*
================================================================================
Project     : Zomato Data Analysis
File        : 03_constraints_and_relationships.sql
Author      : Ankit Shaw
Database    : PostgreSQL

Description:
Adds foreign key constraints to establish relationships between orders,
customers, restaurants, deliveries, and riders.

Execution Order:
3. Execute after 02_schema_creation.sql.
================================================================================
*/

-- ================================================================================
-- orders -> customers
-- ================================================================================

ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- ================================================================================
-- orders -> restaurants
-- ================================================================================

ALTER TABLE orders
ADD CONSTRAINT fk_restaurants
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);

-- ================================================================================
-- deliveries -> orders
-- ================================================================================

ALTER TABLE deliveries
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- ================================================================================
-- deliveries -> riders
-- ================================================================================

ALTER TABLE deliveries
ADD CONSTRAINT fk_riders
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);

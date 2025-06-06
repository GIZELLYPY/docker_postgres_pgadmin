---------------------------------------------------------------------
-- Total rentals per film category in 2022
---------------------------------------------------------------------

WITH tb_films_cate AS (select rental_id, rental_date , ct.name
from rental r

INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category c ON i.film_id = c.film_id
INNER JOIN category ct ON  ct.category_id = c.category_id
WHERE r.rental_date >= '2022-01-01' and r.rental_date < '2023-01-01'
)

SELECT tt.name, COUNT(*) as tt_rental
FROM tb_films_cate tt
GROUP BY tt.name

---------------------------------------------------------------------
-- Top 3 rented films per store - RANK() and DENSE_RANK()
---------------------------------------------------------------------
-- ps: Use the HAVING clause or a Common Table Expression (CTE) to filter rows after the window function is calculated.
WITH total_per_store AS (SELECT title, 
COUNT(*) as total_rentals,
i.store_id,
RANK() OVER (PARTITION BY i.store_id ORDER BY COUNT(*) DESC) AS rank_in_store
FROM film f
INNER JOIN inventory i ON i.film_id = f.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY 1,3)
SELECT title, 
total_rentals, 
store_id, 
rank_in_store 
FROM total_per_store 
where rank_in_store <= 3
ORDER BY rank_in_store ASC


-- Top 3 rented films per store - DENSE_RANK()
WITH total_per_store AS (SELECT title, 
COUNT(*) as total_rentals,
i.store_id,
DENSE_RANK() OVER (PARTITION BY i.store_id ORDER BY COUNT(*) DESC) AS rank_in_store
FROM film f
INNER JOIN inventory i ON i.film_id = f.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY 1,3)
SELECT title, 
total_rentals, 
store_id, 
rank_in_store 
FROM total_per_store 
where rank_in_store <= 3
ORDER BY rank_in_store ASC

-- Diference between RANK() and DENSE_RANK()
-- RANK() - Same values can be in the same rank. 
-- However this values are set in the same rank bur the next rank is skipped
-- Example 1,1,3 -> 2 is skiped.

--DENSE_RANK() Similiar RANK, DENSE_RANK also set equals values in the same rank, BUT
-- instead to skipp the rank, reapeat it like: 1,1,2 

---------------------------------------------------------------------
-- Detect if some customer rented more quickly than the last time
---------------------------------------------------------------------
WITH customer_frequency AS (

SELECT customer_id, rental_date,
LAG(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date ASC) AS previous_rentals,
rental_date - LAG(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date) AS days_beteween,
ROW_NUMBER() OVER (PARTITION BY customer_id) AS rank_customer
FROM rental)
SELECT customer_id, rental_date, previous_rentals, days_beteween 
FROM customer_frequency
WHERE rank_customer = 2 
ORDER BY days_beteween ASC

---------------------------------------------------------------------
-- See how long customers waited in AVARAGE , BEFORE their next rental
---------------------------------------------------------------------

WITH waiting_rentals AS (SELECT customer_id, rental_date,
LEAD(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date ASC) AS next_rental,
LEAD(rental_date) OVER (PARTITION BY customer_id ORDER BY rental_date ASC) - rental_date  AS waited
FROM rental)

SELECT customer_id, AVG(waited) as average_waiting
FROM waiting_rentals
GROUP BY customer_id

---------------------------------------------------------------------
-- Retrieving customer information. Retrieves the first name, 
-- last name and email of all active customers.
---------------------------------------------------------------------
SELECT first_name, 
last_name, 
email 
FROM customer
WHERE active = 1

---------------------------------------------------------------------
-- List all films sorted by their rental rate in descending order. 
---------------------------------------------------------------------
SELECT title, rating 
FROM film 
ORDER BY rating DESC 

---------------------------------------------------------------------
-- top 5 most replacement_cost expensive films
---------------------------------------------------------------------
SELECT title, replacement_cost
FROM film 
ORDER BY replacement_cost DESC 
LIMIT 5
 --- OR 
SELECT title, replacement_cost
FROM film 
ORDER BY replacement_cost DESC 
FETCH FIRST 5 ROWS ONLY


---------------------------------------------------------------------
--                           Indexing
-- Indexes improve query performance by allowing faster data retrieval
---------------------------------------------------------------------
CREATE INDEX idx_customer_las_name  ON customer(last_name)

CREATE INDEX idx_film_category_category_id ON film_category(category_id)


select * from pg_indexes where tablename = 'customer' -- show indexes


---------------------------------------------------------------------
--                    Transactions Management
-- Transactions ensure data integrity. In case this transaction updates
-- inventory and rental table in atomic operation, ensuring that either
-- both actions succeed or neither does. 
-- last_update from inventory is a FK in the table rental. So both need 
-- to be updated in the same transaction.
-- If the transaction fails, the database will roll back to the state before
-- the transaction began, ensuring no partial updates are made.
---------------------------------------------------------------------
BEGIN;
	UPDATE inventory SET last_update = NOW() WHERE film_id = 1;
	INSERT INTO rental (rental_date, inventory_id, customer_id, return_date,staff_id) VALUES (NOW(), 1,1,NOW(),1);
COMMIT; 

---------------------------------------------------------------------
--                      DML - Data Manipulation Language
-- DML commands are used to manipulate data in the database.
-- INSERT, UPDATE, DELETE
---------------------------------------------------------------------

--                     DDL - Data Definition Language
-- DDL commands are used to define the structure of the database.
-- CREATE, ALTER, DROP
---------------------------------------------------------------------

--                      DCL - Data Control Language
-- DCL commands are used to control access to the data in the database.
-- GRANT, REVOKE
---------------------------------------------------------------------
--                      TCL - Transaction Control Language
-- TCL commands are used to control transactions in the database.
-- COMMIT, ROLLBACK, SAVEPOINT
---------------------------------------------------------------------
--                      DQL - Data Query Language
-- DQL commands are used to query data from the database.
-- SELECT
---------------------------------------------------------------------

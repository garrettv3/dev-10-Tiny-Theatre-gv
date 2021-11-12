use ramsey_county_ttc;

SELECT *
FROM rcttc_data_temp;

-- Interior sub-query for populating customer table
SELECT DISTINCT customer_first, customer_last, customer_email, customer_phone, customer_address
FROM rcttc_data_temp;

-- Interior sub-query for populating theatre table
SELECT DISTINCT theater, theater_address, theater_phone, theater_email
FROM rcttc_data_temp;

-- Interior sub-query for populating production table
SELECT DISTINCT `show`
FROM rcttc_data_temp;

-- Interior sub-query for populating performance table
SELECT DISTINCT `show`, theater, `date`, ticket_price
FROM rcttc_data_temp;

SELECT DISTINCT `date`, ticket_price -- This query shows that ticket price and date can determine a unique show for the given data
FROM rcttc_data_temp;

-- Interior sub-query for populating seat_performance table
SELECT DISTINCT customer_first, customer_last, seat, `show`, theater, `date`
FROM rcttc_data_temp;

-- ----------------------------------------------------------------------------------------------------
-- Table population queries - INSERTS MUST BE RUN IN ORDER AND ONLY ONCE PER QUERY!!!!

-- Step 1, the customer table
INSERT INTO customer (first_name, last_name, email, phone, address)
	SELECT DISTINCT customer_first, customer_last, customer_email, customer_phone, customer_address
	FROM rcttc_data_temp;
    
SELECT *
FROM customer;
    
-- Step 2, the theatre table    
INSERT INTO theatre (theatre_name, address, phone, email)
	SELECT DISTINCT theater, theater_address, theater_phone, theater_email
	FROM rcttc_data_temp;
    
SELECT *
FROM theatre;

-- Step 3, the show table
INSERT INTO production (title)
	SELECT DISTINCT `show`
	FROM rcttc_data_temp;
    
SELECT *
FROM production;
    
-- Step 4, the individual performance table
INSERT INTO performance (show_id, theatre_id, night, ticket_price)
	SELECT DISTINCT prod.show_id, t.theatre_id, temp.`date`, temp.ticket_price
    FROM rcttc_data_temp temp
    INNER JOIN production prod ON temp.`show` = prod.title
    INNER JOIN theatre t ON temp.theater = t.theatre_name;
    
SELECT *
FROM performance;

-- Step 5, the seating table
INSERT INTO seat_performance (customer_id, performance_id, seat)
SELECT DISTINCT c.customer_id, p.performance_id, temp.seat
FROM rcttc_data_temp temp
INNER JOIN customer c ON temp.customer_email = c.email
INNER JOIN performance p ON temp.`date` = p.night AND temp.ticket_price = p.ticket_price;

SELECT *
FROM seat_performance;

-- Step 6, Drop temporary data import table
drop table if exists rcttc_data_temp;

-- Step 7, fill in missing information
UPDATE theatre
SET capacity = 12
WHERE theatre_id = 2;

UPDATE theatre
SET capacity = 25
WHERE theatre_id = 1;

UPDATE theatre
SET capacity = 16
WHERE theatre_id = 3;

SELECT *
FROM theatre;

-- Step 8, Assessment-mandated data updates
SELECT perf.performance_id, perf.night, prod.title, t.theatre_name, perf.ticket_price
FROM performance perf
INNER JOIN production prod ON perf.show_id = prod.show_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id;

UPDATE performance
SET ticket_price = 22.25
WHERE performance_id = 5;


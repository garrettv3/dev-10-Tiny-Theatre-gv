use ramsey_county_ttc;

-- Step 0, import data to database and call new temporary table "rcttc_data_temp"

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
-- 8a: Raise ticket price of the 2021-03-01 performance of The Sky Lit Up at the Little Fitz
SELECT perf.performance_id, perf.night, prod.title, t.theatre_name, perf.ticket_price
FROM performance perf
INNER JOIN production prod ON perf.show_id = prod.show_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id;

UPDATE performance
SET ticket_price = 22.25
WHERE performance_id = 5;

-- 8b: Shuffle seating in the aforementioned showing of The Sky Lit Up so all customers' reservations are in the same row
SELECT sp.seat, CONCAT(c.first_name, ' ', c.last_name) AS Customer, sp.customer_id, perf.ticket_price
FROM seat_performance sp
INNER JOIN customer c ON sp.customer_id = c.customer_id
INNER JOIN performance perf ON sp.performance_id = perf.performance_id
WHERE sp.performance_id = 5;

-- Move Chiarra Vail to a nonexistent interim seat for the shuffle
UPDATE seat_performance
SET seat = 'D1'
WHERE performance_id = 5
AND customer_id = 39
AND seat = 'C2';

-- Move Cullen Guirau's separated seat into row C with the other one to fill the seat vacated by Chiarra Vail
UPDATE seat_performance
SET seat = 'C2'
WHERE performance_id = 5
AND customer_id = 38
AND seat = 'B4';

-- Move Pooh Bedburrow's separated seat into row B with the rest, filling the seat vacated by Cullen Guirau
UPDATE seat_performance
SET seat = 'B4'
WHERE performance_id = 5
AND customer_id = 37
AND seat = 'A4';

-- Finally, move Chiarra Vail from her nonexistent seat to the one vacated by Pooh Bedburrow to finish the shuffle
UPDATE seat_performance
SET seat = 'A4'
WHERE performance_id = 5
AND customer_id = 39
AND seat = 'D1';

-- 8c: Update Jammie Swindles' phone number to "1-801-EAT-CAKE"
SELECT customer_id, first_name, last_name, phone
FROM customer
WHERE first_name = 'Jammie';

UPDATE customer
SET phone = '1-801-EAT-CAKE'
WHERE customer_id = 48;

-- Step 9, Assessment-Mandated Deletions
-- 9a: Delete all single-ticket reservations at the 10 Pin

-- This query shows that there are 9 single-ticket reservations at the 10 Pin.
SELECT sp.customer_id, sp.performance_id, COUNT(sp.seat)
FROM seat_performance sp
INNER JOIN performance perf ON sp.performance_id = perf.performance_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id
WHERE t.theatre_name = '10 Pin'
GROUP BY sp.customer_id, sp.performance_id
HAVING COUNT(sp.seat) = 1;

DELETE FROM seat_performance
WHERE customer_id = 7
AND performance_id = 1;

DELETE FROM seat_performance
WHERE customer_id = 8
AND performance_id = 2;

DELETE FROM seat_performance
WHERE customer_id = 10
AND performance_id = 2;

DELETE FROM seat_performance
WHERE customer_id = 15
AND performance_id = 2;

DELETE FROM seat_performance
WHERE customer_id = 18
AND performance_id = 3;

DELETE FROM seat_performance
WHERE customer_id = 19
AND performance_id = 3;

DELETE FROM seat_performance
WHERE customer_id = 22
AND performance_id = 3;

DELETE FROM seat_performance
WHERE customer_id = 25
AND performance_id = 3;

DELETE FROM seat_performance
WHERE customer_id = 26
AND performance_id = 4;

-- 9b: Delete Customer Liv Egle of Germany
SELECT *
FROM customer;

DELETE FROM seat_performance
WHERE customer_id = (
SELECT customer_id
FROM customer
WHERE last_name = 'Egle of Germany');

SELECT customer_id
FROM customer
WHERE last_name = 'Egle of Germany';

DELETE FROM customer        -- For some reason, SQL would not let me complete this deletion with a subquery as I did above.
WHERE customer_id = 65;

use ramsey_county_ttc;

-- ----------- Find all performances in the last quarter of 2021 (Oct. 1, 2021 - Dec. 31 2021).

SELECT perf.performance_id, prod.title, t.theatre_name, night, ticket_price
FROM performance perf
INNER JOIN production prod ON perf.show_id = prod.show_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id
WHERE night >= '2021-10-01'
AND night <= '2021-12-31';

-- ----------- List customers without duplication.

SELECT *
FROM customer;

-- ----------- Find all customers without a .com email address.

SELECT *
FROM customer
WHERE email NOT LIKE '%.com';

-- ----------- Find the three cheapest shows.

SELECT *
FROM performance
ORDER BY ticket_price ASC
LIMIT 3;

-- ----------- List customers and the show they're attending with no duplication.

SELECT DISTINCT CONCAT(c.first_name, ' ', c.last_name) AS Customer, perf.night, prod.title
FROM customer c
INNER JOIN seat_performance sp ON c.customer_id = sp.customer_id
INNER JOIN performance perf ON sp.performance_id = perf.performance_id
INNER JOIN production prod ON perf.show_id = prod.show_id;

-- ----------- List customer, show, theater, and seat number in one query.

SELECT DISTINCT CONCAT(c.first_name, ' ', c.last_name) AS Customer, prod.title AS `Show`, 
perf.night AS `Date`, t.theatre_name AS Theater, sp.seat AS SeatNumber
FROM customer c
INNER JOIN seat_performance sp ON c.customer_id = sp.customer_id
INNER JOIN performance perf ON sp.performance_id = perf.performance_id
INNER JOIN production prod ON perf.show_id = prod.show_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id;

-- ----------- Find customers without an address.

SELECT *
FROM customer
WHERE address IS NULL
OR address = '';

-- ----------- Recreate the spreadsheet data with a single query.
-- Obviously, though formatted identically, this data does not contain the info removed in the DML step

SELECT c.first_name AS customer_first, c.last_name AS customer_last, c.email AS customer_email, c.phone AS customer_phone,
c.address AS customer_address, sp.seat, prod.title AS `show`, perf.ticket_price, perf.night AS `date`,
t.theatre_name AS theater, t.address AS theater_address, t.phone AS theater_phone, t.email AS theater_email
FROM customer c
INNER JOIN seat_performance sp ON c.customer_id = sp.customer_id
INNER JOIN performance perf ON sp.performance_id = perf.performance_id
INNER JOIN production prod ON perf.show_id = prod.show_id
INNER JOIN theatre t ON perf.theatre_id = t.theatre_id;

-- ----------- Count total tickets purchased per customer.

SELECT CONCAT(c.first_name, ' ', c.last_name) AS Customer, COUNT(sp.seat) AS Tickets_Purchased
FROM customer c
INNER JOIN seat_performance sp ON c.customer_id = sp.customer_id
GROUP BY sp.customer_id;

-- ----------- Calculate the total revenue per show based on tickets sold.

SELECT prod.title AS `Show`, SUM(perf.ticket_price) AS Total_Revenue
FROM production prod
INNER JOIN performance perf ON prod.show_id = perf.show_id
INNER JOIN seat_performance sp ON perf.performance_id = sp.performance_id
GROUP BY prod.title;

-- ----------- Calculate the total revenue per theater based on tickets sold.

SELECT t.theatre_name AS Theater, SUM(perf.ticket_price) AS Total_Revenue
FROM theatre t
INNER JOIN performance perf ON t.theatre_id = perf.theatre_id
INNER JOIN seat_performance sp ON perf.performance_id = sp.performance_id
GROUP BY perf.theatre_id;

-- ----------- Who is the biggest supporter of RCTTC? Who spent the most in 2021?

SELECT CONCAT(c.first_name, ' ', c.last_name) AS Customer, SUM(p.ticket_price) AS Total_Spent
FROM customer c
INNER JOIN seat_performance sp ON c.customer_id = sp.customer_id
INNER JOIN performance p ON sp.performance_id = p.performance_id
GROUP BY c.customer_id
ORDER BY SUM(p.ticket_price) DESC
LIMIT 1;

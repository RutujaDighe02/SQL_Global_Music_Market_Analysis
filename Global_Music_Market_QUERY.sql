--Q1 Who is the senior most employee based on job title?
SELECT * FROM employee 
ORDER BY levels DESC
LIMIT 1;

--Q2 which countries have the most invoices?
SELECT COUNT(*) AS c, billing_country
FROM invoice 
GROUP BY billing_country
ORDER BY c DESC;

--Q3 What are top 3 values of total invoices 
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

--Q4 Which city has the best customers? we would like to throw a promotional music festival in the city we made the 
--most money. write a query that returns one city that has the highest sum of invoice totlas. returns both the city name and sum of all invoice totals.
SELECT SUM(total) AS total_invoice , billing_city 
FROM invoice
GROUP BY billing_city 
ORDER BY total_invoice DESC

--Q5 Who is the best customer? The customer who has spent the most money will be declared the best customer
-- write a query that returns the person who sepnt the most money.
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(Invoice.total) as total 
FROM customer	
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc
LIMIT 1;

--SET2: Q1 Write query to return the email, first name, last name and genre of all the rock music listeners.
--returns your list ordered alphabeticaaly by email stating with A
SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Q2 Let's invite the artists who have written the most rock music in our dataset. write a query that returns the artist name and total 
--track count of the top 10 rock brands
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS no_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 10;

--Q3 Retuns all the tarck names that have a song length longer than the average song length. return the name and milliseconds for each track.
-- order by the song lenghth with the longest songs listed first.
SELECT track.name, track.milliseconds
FROM track
WHERE milliseconds > (
 SELECT AVG(milliseconds) AS AVG_SONG_LENGTH
 FROM track
)
ORDER BY milliseconds DESC

--SET3: Q1 Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent 
WITH Bestselling_artist_CTE AS (
     SELECT artist.artist_id AS artist_id, artist.name AS Artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	 FROM invoice_line
	 JOIN track on track.track_id = invoice_line.track_id
	 JOIN album on album.album_id = track.album_id
	 JOIN artist on artist.artist_id = album.artist_id
	 GROUP By 1
	 ORDER By total_sales DESC
	 LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t on t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN Bestselling_artist_CTE bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--Q2 We want to find out the most popular music Genre for each country We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top genre. for countries where the max number of purchases is shared return all genres.
WITH popular_music_Genr As
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNO 
	From invoice_line
	JOIN invoice on invoice.invoice_id =  invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY  2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_music_Genr WHERE RowNO<= 1 

--Q3 Write a query that determines the customer that has spent the most on music for each country. write a query that returns the country along with the top customer and how much they spent. FOR countries where the top amount spent is shared,
--provide all customers who spent this amount.
WITH RECURSIVE
 country_customer AS (
 SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS Total
 FROM invoice
 JOIN customer ON customer.customer_id = invoice.customer_id
 GROUP BY 1,2,3,4
 ORDER BY 2,3 DESC),
 
 Country_max AS(
	 SELECT billing_country, MAX(total) AS MAX_spending
	 FROM country_customer
	 GROUP BY billing_country)
 
SELECT cc.billing_country, cc.total, cc.first_name, cc.last_name,
TRIM(Concat(cc.first_name,cc.last_name)) AS Full_name
FROM country_customer cc
JOIN Country_max MS
ON cc.billing_country = MS.billing_country
WHERE cc.total = MS.MAX_spending
ORDER BY 1;
 






























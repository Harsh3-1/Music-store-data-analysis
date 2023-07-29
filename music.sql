-- who is the senior most employee

select top(1) employee_id, first_name,last_name, levels
from employee$
order by levels desc

--which countries have the most invoices?
select *
from invoice$

select billing_country as country,count(invoice_id) as no_of_invoices
from invoice$
group by billing_country
order by no_of_invoices desc

-- which city has the best customers? the city that has the highest sum of invoice totals
select top(1)billing_city as cities, sum(total) as invoice_total
from invoice$
group by billing_city
order by total desc

--who is the best customer? the customer who has spent the most
select *
from customer$

select top(1) c.customer_id, c.first_name,c.last_name,sum(i.total) as invoice_total
from customer$ c
join invoice$ i
on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by invoice_total desc

-- return the email,genre and name of all Rock music listeners
select distinct email,first_name,last_name,genre$.name
from customer$, genre$
where genre$.name = 'Rock'
order by email

select distinct email,first_name, last_name
from customer$
join invoice$ on customer$.customer_id= invoice$.customer_id
join invoice_line$ on invoice$.invoice_id=invoice_line$.invoice_id
where track_id in(
select track_id
from track$
join genre$
on track$.genre_id=genre$.genre_id
where genre$.name like 'Rock' )

order by email;

--return the artists name and total track count of the top 10 rock bands
select *
from artist$

select *
from invoice$

select *
from album$

select *
from genre$

select *
from track$


select top(10)  ar.name, count(ar.artist_id) as no_of_songs
from artist$ ar
join album$ al on ar.artist_id=al.artist_id
join track$ tr on tr.album_id= al.album_id
join genre$ ge on ge.genre_id= tr.genre_id
where ge.name  like 'Rock'
group by ar.name
order by no_of_songs desc

--return all the track names that have song length longer than the average song length

select name, milliseconds
from track$
where milliseconds > (
select avg(milliseconds) as avg_len
from track$
)
order by milliseconds desc;

--Find how much amount was spent by each customer on artists

with CTE as (select artist$.artist_id, artist$.name as artist_name
from invoice_line$ il
join track$ on il.track_id=track$.track_id
join album$ on album$.album_id=track$.album_id
join artist$ on artist$.artist_id= album$.artist_id
group by artist$.artist_id,artist$.name
)

select c.first_name,c.last_name, cte.artist_name,sum(il.quantity*il.unit_price) as amount_spent
from customer$ c
join invoice$ i on c.customer_id=i.customer_id
join invoice_line$ il on il.invoice_id = i.invoice_id
join track$ t on t.track_id = il.track_id
join album$ alb on alb.album_id = t.album_id
join cte on cte.artist_id=alb.artist_id
group by c.first_name,c.last_name, cte.artist_name
order by amount_spent desc

--return each country along  with the top genre, for countries where the max no of purchases is shared return all genres.

with cte2 as (select  count(invoice_line$.quantity) as purchases,c.country,g.name as genre,ROW_NUMBER() over(partition by country order by count(invoice_line$.quantity) desc) as rowno
from customer$ c
join invoice$ on c.customer_id= invoice$.customer_id
join invoice_line$ on invoice$.invoice_id=invoice_line$.invoice_id
join track$ t on t.track_id = invoice_line$.track_id
join genre$ g on g.genre_id = t.genre_id
group by c.country,g.name)

select country,genre,purchases
from cte2
where rowno = 1

--determine the customer that has spent the most on music for each country

with customer_with_country as
(
select billing_country,first_name,last_name, sum(total) as most_spent
from customer$ c
join invoice$ i on c.customer_id=i.customer_id
group by billing_country,country,first_name,last_name
)

select billing_country, max(most_spent) as max_spending
from customer_with_country
group by billing_country
order by 2 desc

SELECT  SUM(DATA_LENGTH) , SUM(INDEX_LENGTH),
CONCAT(  ROUND ((SUM(INDEX_LENGTH) / SUM(DATA_LENGTH)) *100), ' %')  AS PROCENT
FROM INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'sakila';


EXPLAIN ANALYZE
select distinct concat(c.last_name, ' ', c.first_name),
sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and 
r.customer_id = c.customer_id and i.inventory_id = r.inventory_id;

-> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=6497.495..6497.547 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=2.50..2.50 rows=0) (actual time=6497.493..6497.493 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=2618.908..6292.569 rows=642000 loops=1)
            -> Sort: c.customer_id, f.title  (actual time=2618.871..2682.317 rows=642000 loops=1)
                -> Stream results  (cost=21711046.41 rows=16007975) (actual time=0.380..2038.939 rows=642000 loops=1)
                    -> Nested loop inner join  (cost=21711046.41 rows=16007975) (actual time=0.375..1735.370 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=20106246.90 rows=16007975) (actual time=0.371..1537.381 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=18501447.39 rows=16007975) (actual time=0.365..1323.872 rows=642000 loops=1)
                                -> Inner hash join (no condition)  (cost=1581483.80 rows=15813000) (actual time=0.355..55.064 rows=634000 loops=1)
                                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.65 rows=15813) (actual time=0.030..6.643 rows=634 loops=1)
                                        -> Table scan on p  (cost=1.65 rows=15813) (actual time=0.019..4.762 rows=16044 loops=1)
                                    -> Hash
                                        -> Covering index scan on f using idx_title  (cost=112.00 rows=1000) (actual time=0.055..0.244 rows=1000 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.97 rows=1) (actual time=0.001..0.002 rows=1 loops=634000)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)






EXPLAIN ANALYZE
select concat(c.last_name, ' ', c.first_name) as fio,
sum(p.amount)
from payment p, rental r, customer c, inventory i
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and 
r.customer_id = c.customer_id and i.inventory_id = r.inventory_id
group by fio;

-> Table scan on <temporary>  (actual time=8.737..8.781 rows=391 loops=1)
    -> Aggregate using temporary table  (actual time=8.736..8.736 rows=391 loops=1)
        -> Nested loop inner join  (cost=29731.10 rows=16008) (actual time=0.068..8.020 rows=642 loops=1)
            -> Nested loop inner join  (cost=24128.30 rows=16008) (actual time=0.064..7.235 rows=642 loops=1)
                -> Nested loop inner join  (cost=18525.51 rows=16008) (actual time=0.058..6.600 rows=642 loops=1)
                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1605.55 rows=15813) (actual time=0.046..5.189 rows=634 loops=1)
                        -> Table scan on p  (cost=1605.55 rows=15813) (actual time=0.034..3.819 rows=16044 loops=1)
                    -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.97 rows=1) (actual time=0.001..0.002 rows=1 loops=634)
                -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=642)
            -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=642)

SELECT count(INDEX_LENGTH) / (SELECT sum(DATA_LENGTH) from INFORMATION_SCHEMA.TABLES ) *100 
from information_schema.TABLES t




EXPLAIN ANALYZE
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id

-> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=6613.119..6613.169 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=2.50..2.50 rows=0) (actual time=6613.117..6613.117 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=2583.077..6401.481 rows=642000 loops=1)
            -> Sort: c.customer_id, f.title  (actual time=2583.039..2650.034 rows=642000 loops=1)
                -> Stream results  (cost=21711046.41 rows=16007975) (actual time=0.388..2008.596 rows=642000 loops=1)
                    -> Nested loop inner join  (cost=21711046.41 rows=16007975) (actual time=0.383..1712.286 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=20106246.90 rows=16007975) (actual time=0.379..1518.246 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=18501447.39 rows=16007975) (actual time=0.374..1309.361 rows=642000 loops=1)
                                -> Inner hash join (no condition)  (cost=1581483.80 rows=15813000) (actual time=0.363..55.680 rows=634000 loops=1)
                                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.65 rows=15813) (actual time=0.030..6.741 rows=634 loops=1)
                                        -> Table scan on p  (cost=1.65 rows=15813) (actual time=0.019..4.810 rows=16044 loops=1)
                                    -> Hash
                                        -> Covering index scan on f using idx_title  (cost=112.00 rows=1000) (actual time=0.043..0.231 rows=1000 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.97 rows=1) (actual time=0.001..0.002 rows=1 loops=634000)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)

                        
EXPLAIN ANALYZE
select distinct  payment_id , concat(c.last_name, ' ', c.first_name ), payment_date, sum(p.amount) over (partition by c.customer_id ) 
from payment p, rental r, customer c, inventory i
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id

-> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=10.787..10.873 rows=642 loops=1)
    -> Temporary table with deduplication  (cost=2.50..2.50 rows=0) (actual time=10.786..10.786 rows=642 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id )   (actual time=9.201..10.573 rows=642 loops=1)
            -> Sort: c.customer_id  (actual time=9.171..9.226 rows=642 loops=1)
                -> Stream results  (cost=29731.10 rows=16008) (actual time=0.079..8.987 rows=642 loops=1)
                    -> Nested loop inner join  (cost=29731.10 rows=16008) (actual time=0.072..8.604 rows=642 loops=1)
                        -> Nested loop inner join  (cost=24128.30 rows=16008) (actual time=0.068..7.798 rows=642 loops=1)
                            -> Nested loop inner join  (cost=18525.51 rows=16008) (actual time=0.062..7.113 rows=642 loops=1)
                                -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1605.55 rows=15813) (actual time=0.050..5.628 rows=634 loops=1)
                                    -> Table scan on p  (cost=1605.55 rows=15813) (actual time=0.038..4.142 rows=16044 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.97 rows=1) (actual time=0.002..0.002 rows=1 loops=634)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=642)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=642)

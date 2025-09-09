 create database restaurant_orders_db ;
 
 use restaurant_orders_db;
 
 create table order_details (
  order_details_id int,
  order_id int,
  order_date date,
  order_time time,
  item_id int,
  PRIMARY KEY (order_details_id),
  FOREIGN KEY(item_id) REFERENCES menu_items(menu_items_id)
);

create table  menu_items (
  menu_item_id int,
  item_name text,
  category text,
  price double,
  PRIMARY KEY (menu_item_id)
);

 
 select* from menu_items ;
 
 select * from order_details;
 
 select count(*)as Total_items  from menu_items ;
 
 select count(*)as Total_orders from order_details ;
 
 select * from order_details;
 
-- 1. What are the most popular menu items ordered by customers?
 
select m.item_name ,count(o.order_id) as orders_count
from order_details as o 
left join menu_items as m 
on o.item_id = m.menu_item_id 
group by m.item_name 
order by orders_count desc ;
 

-- 2. What are the least popular menu items ordered by customers?
 
select m.item_name ,count(o.order_id) as orders_count
from order_details as o 
left join menu_items as m 
on o.item_id = m.menu_item_id 
group by m.item_name 
order by orders_count asc ;


-- 3. Which menu category generates the highest number of orders?

select m.category ,count(o.order_id) as orders_count
from order_details as o 
left join menu_items as m 
on o.item_id = m.menu_item_id 
group by m.category
order by orders_count desc ;


-- 4. How do prices of menu items influence the number of orders?


select m.item_name,round(avg(m.price),2)as avg_price,count(o.order_id)as orders_count
from order_details as o
left join menu_items as m
on o.item_id = m.menu_item_id 
group by m.item_name
order by orders_count desc;


--  5. Which days of the week are the busiest in terms of orders?

select dayname(order_date)as day_of_week, count(order_id)as orders_count
from order_details
group by day_of_week
order by orders_count  desc;


-- 6. What is the order distribution across different times of the day (e.g.'Morning','Afternoon' )?
select case 
           when extract(hour from o.order_time) between 6 and 11 then'Morning'
           WHEN Extract(hour from o.order_time) between 12 and 17 then 'Afternoon'
        else 'Evening'
       end as time_of_day, count(order_id)as order_count
from order_details o
join menu_items m on o.item_id = m.menu_item_id
group by  time_of_day
order by order_count desc;

-- 7. which are the most profitable items based on the total revenue generated from orders?
with count_of_order as 
( select m.menu_item_id, m.item_name,count(o.item_id)as order_count 
from order_details as o
left join menu_items as m
on o.item_id = m. menu_item_id 
group by m.menu_item_id , m.item_name)

select oc.item_name,oc.order_count, round((oc.order_count * m.price),2)as total_revenue
from count_of_order as oc
join menu_items as m
on oc.menu_item_id = m.menu_item_id
order by total_revenue desc;

-- 8. which are the least profitable items based on the total revenue generated from orders?
with count_of_order as 
( select m.menu_item_id, m.item_name,count(o.item_id)as order_count 
from order_details as o
left join menu_items as m
on o.item_id = m. menu_item_id 
group by m.menu_item_id , m.item_name)

select oc.item_name,oc.order_count, round((oc.order_count * m.price),2)as total_revenue
from count_of_order as oc
join menu_items as m
on oc.menu_item_id = m.menu_item_id
order by total_revenue asc;




-- 9. Which Items are Ordered Together the Most?
select o1.item_id as Item1, o2.item_id as Item2 , count(*)as order_combination
from order_details as o1 
join order_details as o2 
on o1.order_id = o2.order_id 
where o1.item_id > o2.item_id
group by o1.item_id , o2.item_id
order by order_combination desc ;


-- 10  How does the frequency of orders relate to the number of items ordered per transaction (single vs multiple items)?

select order_id, COUNT(item_id) AS item_count
from order_details
group by order_id
having item_count > 1
order by  item_count desc;




-- 11. What is the average number of items ordered in a single transaction?

select distinct
avg(count(item_id))over () as avg_items_per_order
from order_details
group by  order_id;


-- 12. what is the total revenue generated throughout the year?
with ordercount as
(select year(order_date) as order_year ,count(order_id) as orders_count ,item_id
from order_details 
group by order_year, item_id)

select oc.order_year ,round(sum(oc.orders_count*m.price),2)as revenue_for_year
from ordercount as oc
join menu_items as m
on oc.item_id = m. menu_item_id
group by oc.order_year;









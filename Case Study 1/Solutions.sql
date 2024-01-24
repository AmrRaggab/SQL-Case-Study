-- 1. What is the total amount each customer spent at the restaurant?

/*

select s.customer_id , sum(m.price) total_amount from sales s join menu m
on s.product_id = m.product_id
group by s.customer_id

*/


-- 2. How many days has each customer visited the restaurant?

/*
select s.customer_id , count(distinct s.order_date) from sales s
group by s.customer_id

*/


-- 3. What was the first item from the menu purchased by each customer?
/*

with first_purchas as(
	select customer_id , min(order_date) first_order_date from sales
	group by customer_id
)

select f.customer_id , s.product_id
from first_purchas f join sales s
on f.customer_id = s.customer_id and f.first_order_date = s.order_date
join menu m on m.product_id = s.product_id

*/

/*

with first_purchas as(
	select customer_id , min(order_date)  first_order_date from sales
	group by customer_id
)
select distinct f.customer_id  , s.product_id  from first_purchas f join sales s
on s.customer_id = f.customer_id and s.order_date = f.first_order_date

*/



-- 4. What is the most purchased item on the menu 
--and how many times was it purchased by all customers

/*
select top 1 s.product_id , count(s.product_id) num_purchased from sales s
group by s.product_id
order by count(s.product_id) desc
*/



-- 5. Which item was the most popular for each customer?
/*
with most_popular as(
	select s.customer_id , m.product_name , count(s.product_id) as total_purchases
	from sales s join menu m 
	on m.product_id = s.product_id
	group by s.customer_id , m.product_name
)

select customer_id ,  product_name from (
	select customer_id ,  product_name , ROW_NUMBER()over(partition by customer_id order by total_purchases ) as row_num from most_popular
) ranked
where row_num = 1

*/

-- 6. Which item was purchased first by the customer after they became a member?
/*
select s.customer_id , m.product_name , min(s.order_date) first_purchase_date 
from menu m join sales s
join members me on me.customer_id = s.customer_id
on s.product_id = m.product_id 
where s.order_date >= me.join_date
group by s.customer_id , m.product_name
order by customer_id , first_purchase_date
*/

-- 7. Which item was purchased just before the customer became a member?
/*
select s.customer_id,m.product_name , s.order_date from menu m  join sales s
on m.product_id = s.product_id join members me on me.customer_id = s.customer_id
where s.order_date < me.join_date
*/

-- 8. What is the total items and amount spent for each member before they became a member?
/*
select s.customer_id , count(m.product_id) total_items , sum(m.price) amount_spent from menu m join sales s
on m.product_id = s.product_id join members me on me.customer_id = s.customer_id
where s.order_date < me.join_date
group by s.customer_id
*/

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
 --    how many points would each customer have?

 /*
 with PointsPerPurchase as(
 select s.customer_id , m.product_name ,
 sum(case when m.product_name ='sushi' then 2 else 1 end ) as points_per_purchase 
 from sales s join menu m
 on s.product_id = m.product_id
 group by s.customer_id , m.product_name
)
select p.customer_id , sum(points_per_purchase*m.price)
from PointsPerPurchase p join sales s
on p.customer_id = s.customer_id join menu m on m.product_id = s.product_id
group by p.customer_id

*/

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
 -- not just sushi - how many points do customer A and B have at the end of January?

 /*
with Points_Purchase as(
	select s.customer_id , m.product_name , s.order_date ,m.price  ,
	(case when s.order_date >= DATEADD(WEEK,1,me.join_date) then m.price*2 else m.price end) points_multiplier 
	from sales s join menu m 
	on m.product_id = s.product_id join members me on me.customer_id = s.customer_id
)

select p.customer_id , sum(points_multiplier) Total_Points from Points_Purchase p
join sales s on s.customer_id = p.customer_id 
join members m on m.customer_id = p.customer_id
where p.customer_id in('A','B') and p.order_date between '2021-01-07' and '2021-01-31' 
group by p.customer_id
order by Total_Points desc

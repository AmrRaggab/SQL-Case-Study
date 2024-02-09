
------------------------------- A. Pizza Metrics ----------------------------------------


-- 1 -- How many pizzas were ordered?
  --select count(c.pizza_id) from customer_orders c


 -- 2 -- How many unique customer orders were made?
 -- select count(distinct c.customer_id) from customer_orders c

 -- 3 -- How many successful orders were delivered by each runner?
	/* select r.runner_id , count(r.order_id) from runner_orders r
	where r.cancellation = ''
	group by r.runner_id
	order by r.runner_id */
	

-- 4 --How many of each type of pizza was delivered?
	/*
	select c.pizza_id , count(c.pizza_id)
	from customer_orders c join runner_orders r
	on c.order_id = r.order_id
	where r.cancellation = 'None'
	group by c.pizza_id
	*/


-- 5 -- How many Vegetarian and Meatlovers were ordered by each customer?
/*
	select c.customer_id , 
	sum(case when p.pizza_name = 'Vegetarian' then 1 else 0 end) as Vegetarian , 
	sum(case when p.pizza_name = 'Meatlovers' then 1 else 0 end ) as Meatlovers
	from customer_orders c join pizza_names p
	on c.pizza_id = p.pizza_id
	group by c.customer_id
*/


-- 6 -- What was the maximum number of pizzas delivered in a single order?
	/* 
	 select top 1 c.order_id , count(c.order_id) Max_Number
	 from customer_orders c join runner_orders r 
	 on c.order_id = r.order_id	
	 where r.cancellation = 'None'
	 group by c.order_id 
	 order by count(c.order_id) desc
	 */


-- 7 -- For each customer, how many delivered pizzas had at least 1 change 
     -- and how many had no changes?
/*
	with cte as(
		select c.customer_id , c.order_id , 
		( case when c.extras <> 'None' or c.exclusions <> 'None' then 'Change' 
		else 'Not Change' end ) as status
		from customer_orders c
	)
	select c.customer_id , c.status , count(c.status) from cte c join runner_orders r
	on c.order_id = r.order_id
	where r.cancellation = 'None'
	group by c.customer_id , c.status
	order by c.customer_id
*/


-- 8 -- How many pizzas were delivered that had both exclusions and extras?
/*
	select count(c.pizza_id) Num_Pizza
	from customer_orders c right join runner_orders r
	on c.order_id = r.order_id
	where r.cancellation = 'None' and c.exclusions <> 'None' and c.extras <> 'None'
	order by count(c.pizza_id)
*/


-- 9 -- What was the total volume of pizzas ordered for each hour of the day?
/*
	select DATEPART(hour ,c.order_time) as hour_of_day , count(c.order_id) 
	from customer_orders c 
	group by DATEPART(hour ,c.order_time)
*/


-- 10 -- What was the volume of orders for each day of the week?
/*
	select DATENAME(WEEKDAY ,c.order_time) as day_of_week , count(c.order_id) 
	from customer_orders c 
	group by DATENAME(WEEKDAY ,c.order_time)
*/






----------------------------- B. Runner and Customer Experience -----------------------------


-- 1 -- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
/*
	SET DATEFIRST 1;
	select DATEPART(WEEK , r.registration_date) Week, count(r.runner_id) runner_count
	from runners r 
	group by DATEPART(WEEK , r.registration_date)

	*/


-- 2 -- What was the average time in minutes it took for each runner to arrive 
	 -- at the Pizza Runner HQ to pickup the order?
/*
	with table_date as (
		select distinct r.runner_id , r.pickup_time , c.order_time ,
		cast(DATEDIFF(MINUTE , c.order_time ,r.pickup_time) as float) as arrive_time
		from customer_orders c inner join runner_orders r
		on c.order_id = r.order_id
		where r.cancellation = 'None'
		group by r.runner_id , r.pickup_time , c.order_time
	)
	select t.runner_id , avg(t.arrive_time) from table_date t
	group by t.runner_id
*/


-- 3 --Is there any relationship between the number of pizzas 
	 -- and how long the order takes to prepare?
/*
	 with cte as (
		select c.order_id , count(c.order_id) Pizza_order ,
		c.order_time , r.pickup_time , 
		cast(DATEDIFF(MINUTE , c.order_time ,r.pickup_time) as float) as timee
		from customer_orders c join runner_orders r
		on c.order_id = r.order_id
		where r.cancellation = 'None'
		group by c.order_id , c.order_time , r.pickup_time
	 )

	 select Pizza_order , avg(timee) avg_time_per_order
	 , avg(timee/Pizza_order) as avg_time_per_pizza
	 from cte 
	 group by Pizza_order


we can also notice that the average preparation time per pizza is higher 
when you order 1 than when you order multiple.
*/


-- 4 -- What was the average distance travelled for each customer?
 /*
	select c.customer_id , 
	avg(cast(r.distance as float)) as   average_distance
	from customer_orders c join runner_orders r
	on r.order_id = c.order_id
	where r.cancellation = 'None'
	group by c.customer_id
*/


-- 5 -- What was the difference between the longest and shortest delivery times for all orders?

/*
	select max(cast(r.duration as float)) as longest 
	, min(cast(r.duration as float)) as shortest 
	, max(cast(r.duration as float)) - min(cast(r.duration as float)) as dif_longest_shortest
	from runner_orders r
	where r.cancellation = 'None'
*/


-- 6 -- What was the average speed for each runner for each delivery and 
	 -- do you notice any trend for these values?
/*
	 SELECT r.runner_id, 
       r.order_id, 
       ROUND(AVG(cast(distance as float)/cast(duration as float)),2) as avg_time
	FROM runner_orders r
	WHERE r.cancellation = 'None'
	GROUP BY r.runner_id,r.order_id
	ORDER BY r.runner_id;
*/


-- 7 -- What is the successful delivery percentage for each runner? 
/*
	with CTE AS (
        SELECT r.runner_id, r.order_id,
        CASE WHEN r.cancellation = 'None' THEN 1
        ELSE 0 END AS Sucess_delivery
        FROM runner_orders r
        )
		SELECT runner_id,
			   round( 100*sum(sucess_delivery)/count(*),0) as success_perc
		FROM CTE
		group by runner_id
*/




-------------------------------- A. Customer Nodes Exploration -----------------------
-- 1 -- How many unique nodes are there on the Data Bank system?

	-- select count(distinct c.node_id) Number_Nodes from customer_nodes c

-- 2 -- What is the number of nodes per region?
/*

   select r.region_id as ID , r.region_name as Name , count(c.node_id) Total_Nodes
   from customer_nodes c join regions r
   on c.region_id = r.region_id
   group by r.region_id , r.region_name
   order by count(c.node_id) desc

*/

-- 3 -- How many customers are allocated to each region?
/*	
   select r.region_id as ID , r.region_name as Name , count(distinct c.customer_id) Total_cutomers
   from customer_nodes c join regions r
   on c.region_id = r.region_id
   group by r.region_id , r.region_name
   order by count(c.customer_id) desc
*/

-- 4 -- How many days on average are customers reallocated to a different node?
/*
	select avg(DATEDIFF(DAY , c.start_date , c.end_date)) avg_reallocation_days
	from customer_nodes c
	where c.end_date != '9999-12-31' ;

*/

-- 5 -- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

/*

with cte as(
	select r.region_id ID , r.region_name Name , DATEDIFF(DAY , c.start_date , c.end_date) allocation_days
	from customer_nodes c inner join regions r
	on c.region_id = r.region_id
	where c.end_date != '9999-12-31'
)
select distinct c.ID , c.Name ,
PERCENTILE_DISC(0.5) within group (order by c.allocation_days) over(partition by c.ID) as medain ,
PERCENTILE_DISC(0.8) within group (order by c.allocation_days) over(partition by c.ID) as th80_percentile ,
PERCENTILE_DISC(0.95) within group (order by c.allocation_days) over(partition by c.ID) as TH95_percentile 
from cte c

*/

--------------------------------- B. Customer Transactions -------------------------

-- 1 -- What is the unique count and total amount for each transaction type?

/*
  select c.txn_type , count(*) total_transaction , sum(c.txn_amount) total_amount
  from customer_transactions c
  group by c.txn_type
*/

-- 2 -- What is the average total historical deposit counts and amounts for all customers?
/*	 
	with cte as(
		select c.customer_id , 
			count(c.customer_id) as Num_deposit,
			sum(c.txn_amount) as amount_deposit
		from customer_transactions c
		where c.txn_type = 'deposit'
		group by c.customer_id
	)

	select avg(c.Num_deposit) avg_count , avg(c.amount_deposit) avg_amount
	from cte c
*/

-- 3 -- For each month - how many Data Bank customers 
--make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
/*
	with cte as (
		select DATEPART(MONTH , c.txn_date) Month , 
		sum(case when c.txn_type = 'deposit' then 1 else 0 end) Deposit ,
		sum(case when c.txn_type = 'purchase' then 1 else 0 end) purchase ,
		sum(case when c.txn_type = 'withdrawal' then 1 else 0 end) withdrawal 
		from customer_transactions c
		group by DATEPART(MONTH,c.txn_date)
	)
	select Month , count(*) Total_customer
	from cte
	where Deposit > 1 and (purchase = 1 or withdrawal = 1 )
	group by Month
*/

-- 4 -- What is the closing balance for each customer at the end of the month?

/*
	with cte as(
		select c.customer_id , DATEPART(MONTH , c.txn_date) Month ,
		sum(case when c.txn_type = 'deposit' then c.txn_amount else 0 end) Deposit ,
		sum(case when c.txn_type = 'purchase' then - c.txn_amount else 0 end) purchase ,
		sum(case when c.txn_type = 'withdrawal' then - c.txn_amount else 0 end) withdrawal
		from customer_transactions c
		group by c.customer_id , DATEPART(MONTH , c.txn_date)
	)
		select customer_id , Month , (Deposit+purchase+withdrawal) as change_in_balance
		from cte 
		order by customer_id asc
*/


                       -- Data Cleaning --


/*
select c.customer_id , c.order_id , c.pizza_id , 
  case
	when c.exclusions = 'null' or c.exclusions = '' then 'None' 
	else c.exclusions end as exclusions ,
  case 
	when c.extras = 'null' or c.extras = '' or c.extras is null then 'None'
	else c.extras  end as extras ,
	c.order_time
from customer_orders c

*/



/*
select r.order_id , r.runner_id , 
	case 
		when 
			r.pickup_time is null or r.pickup_time = 'null' or r.pickup_time = '' then 'None'
			else r.pickup_time 
		end ,
	case
		when r.distance = 'null' then 'None'
		when r.distance like '%km' then TRIM(r.distance , 'km')
		else r.distance
		end ,
	case 
		when r.duration = 'null' or r.distance is null then 'None'
		when r.distance like '%mins' then TRIM(r.distance ,'%mins')
		when r.distance like '%minutes' then TRIM(r.distance ,'%minutes')
		else r.distance
		end ,
	case
		when r.cancellation = 'null' or r.cancellation = '' then 'None'
		else r.cancellation
		end
from runner_orders r
*/
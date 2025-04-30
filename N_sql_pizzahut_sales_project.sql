SELECT * FROM pizzahut.orders;
select * from pizzahut.orders_details;

SELECT * FROM pizzahut.pizza_types;

/* Pizza Hut Sales report for Financila year 2023-2024 */

-- 1. Retrieve the total number of orders placed.
 select count( distinct order_id) as Total_Pizzas_order from orders_details;
/* select count( distinct order_details_id) as Total_Pizzas_order from orders_details; */

--  2. Calculate the total revenue generated from pizza sales.
	 select sum(p.price * o.quantity) as Total_Revenue_Generated from pizzas as P 
			join orders_details as o
					on p.pizza_id = o.pizza_id;


-- 3. Identify the highest-priced pizza.
select * from pizza_sales;
select * from pizzas;
select * from pizza_types;
select name, price as Highest_priced_Pizza from pizza_types as p 
			join pizzas as o
            on p.pizza_type_id= o.pizza_type_id
					order by 2 desc limit 1;


-- 4.Identify the most common pizza size ordered.
select * from pizzas;
select * from pizza_types;
select * from orders_details;

select name, count(*) as No_of_Pizzas_order  from pizzas as p 
		join pizza_types as o
			on p.pizza_type_id = o.pizza_type_id
             group by 1
					order by 2 desc limit 1;
                    
                    select name, count(distinct o.order_id ) as No_of_Pizzas_order  from pizzas as p 
		join orders_details as o
			on p.pizza_id = o.pizza_id
            join pizza_types as t
            on p.pizza_type_id = t.pizza_type_id
             group by 1
					order by 2 desc ;

-- 5. List the top 5 most ordered pizza types along with their quantities.
select name, count(distinct order_id ) as No_of_Pizzas_order 
				, sum(q.quantity) as Total_Quantity_Sold  from pizzas as p 
		join pizza_types as o
			on p.pizza_type_id = o.pizza_type_id
            join orders_details as q
            on p.pizza_id = q.pizza_id
             group by 1
					order by 2 desc limit 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
	SELECT 
    o.category, SUM(q.quantity) AS Total_Quantity_Sold
FROM
    pizzas AS P
        JOIN
    pizza_types AS o ON p.pizza_type_id = o.pizza_type_id
        JOIN
    orders_details AS q ON p.pizza_id = q.pizza_id
GROUP BY 1
ORDER BY 2 DESC;


-- 7. Determine the distribution of orders by hour of the day.
select hour(order_time) as Orders_by_Hours,count(*) as No_of_orders 
from orders
group by 1;
            

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
select category, name,count(name) as No_of_Pizza_type from pizza_types
group by 1,2;

select category, count(name) as No_of_Pizza_type from pizza_types
group by 1;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
select date(order_date) as Day, avg( order_id) as Average_order_per_day from orders

group by 1;


-- 10. Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_type_id ,o.name, sum(q.quantity * p.price) as Tota_revenue from pizzas as p 
				join pizza_types as o
                on p.pizza_type_id =o.pizza_type_id
						join orders_details as q
								on p.pizza_id = q.pizza_id
group by 1,2 order by 3 desc limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue:

select p.pizza_type_id,round( (round(sum(p.price * q.quantity) ,2) / (select round(sum( p.price * q.quantity),2) as total_sales  from pizzas  as p
		 join orders_details as q on p.pizza_id = q.pizza_id) * 100),2) as Revenue_percentage 
         from pizzas  as p
		 join orders_details as q on p.pizza_id = q.pizza_id
         group by 1;
         
		
  
-- 12. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select o.category, sum(p.price * q.quantity) as Total_Revenue  from pizzas as p 
				join pizza_types as o
                on p.pizza_type_id =o.pizza_type_id
						join orders_details as q
								on p.pizza_id = q.pizza_id
                                group by 1;
                                
                                
                                
                                
                                WITH RevenuePerPizza AS (
    SELECT
        o.category,
        p.pizza_type_id,
        p.pizza_type_name, -- assuming there is a pizza_type_name column, you can adjust this as per your schema
        SUM(p.price * q.quantity) AS total_revenue
    FROM
        pizzas p
    JOIN pizza_types o
        ON p.pizza_type_id = o.pizza_type_id
    JOIN orders_details q
        ON p.pizza_id = q.pizza_id
    GROUP BY
        o.category, p.pizza_type_id, p.pizza_type_name
),
RankedPizzas AS (
    SELECT
        category,
        pizza_type_name,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank
    FROM
        RevenuePerPizza
)
SELECT
    category,
    pizza_type_name,
    total_revenue
FROM
    RankedPizzas
WHERE
    revenue_rank <= 3
ORDER BY
    category,
    revenue_rank
    ;

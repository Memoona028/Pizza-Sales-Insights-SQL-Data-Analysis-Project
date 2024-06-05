create database pizza_sales;
use pizza_sales;
CREATE TABLE orders (
  order_id INT PRIMARY KEY NOT NULL,
  date DATETIME NOT NULL,
  time TIME NOT NULL
);
-- Now we will going to answer some question to gain some important Insights (EDA)--

-- Q-1 :Retrieve the total number of orders placed.--

select count(order_id) from pizza_sales.orders;

/** Q-2: Calculate the total revenue generated from pizza sales
we will join pizzas and orders table to find out **/
use pizza_sales;
select round(sum(order_details.quantity * pizzas.price),2) as Total_Sales
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id

/* Q-3: Identify the highest-priced pizza*/

select distinct pizza_types.name ,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc limit 1 ;

-- Q-4: Identify the most common pizza size ordered.--
select count(order_details.order_details_id) as order_count,pizzas.size
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by order_count desc;

-- Q5: List the top 5 most ordered pizza types along with their quantities.--
select pizza_types.name as name,sum(order_details.quantity) as order_quantity
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.name order by order_quantity desc limit 5 ;
/** Intermediate **/
-- we used sub query
-- Q6: Join the necessary tables to find the total quantity of each pizza category ordered.--
select sum(order_details.quantity) as order_count,pizza_types.category as category
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by category order by order_count desc limit 5 ;

-- Q7: Determine the distribution of orders by hour of the day.--
select hour(time) as Hours, count(order_id) as Orders from orders
group by Hours;
-- Q8: Join relevant tables to find the category-wise distribution of pizzas.--
select category,count(name) as Pizzas_Count from pizza_types
group by category order by Pizzas_Count desc;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.
-- then we have to find average as well so we make this query as sub query
select round(avg(order_quantity),0) as Avg_no_of_pizzas_ordered_per_day from
(select orders.date,sum(order_details.quantity) as order_quantity
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.date) as order_quantity_sum;

-- Q10: Determine the top 3 most ordered pizza types based on revenue.--
select pizza_types.name as  Pizza_types,round(sum(order_details.quantity * pizzas.price),0) as Total_Revenue
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by Pizza_types order by Total_Revenue desc limit 3;

/** Advanced **/
 -- Q11: Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category as  Pizza_Category,round(sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),0) as Total_Revenue
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id)*100 ,2)as Percentage_contribution_of_pizza_type
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by Pizza_Category order by Percentage_contribution_of_pizza_type desc ;
-- we can use cte as well ----------
WITH Total_Revenue_CTE AS (
    SELECT ROUND(SUM(order_details.quantity * pizzas.price), 0) AS Total_Revenue
    from order_details
    join pizzas on pizzas.pizza_id = order_details.pizza_id
),
Category_Sales_CTE AS (
    SELECT pizza_types.category AS Pizza_Category,SUM(order_details.quantity * pizzas.price) AS Category_Sales
    FROM order_details
    JOIN pizzas on pizzas.pizza_id = order_details.pizza_id
    JOIN pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
    group by pizza_types.category
)
SELECT Pizza_Category,ROUND((Category_Sales / Total_Revenue) * 100, 2) AS Percentage_contribution_of_pizza_type
FROM Category_Sales_CTE,Total_Revenue_CTE
ORDER BY Percentage_contribution_of_pizza_type DESC LIMIT 3;

 -- Q12: Analyze the cumulative revenue generated over time.
SELECT
    date,sum(total_revenue) over(order by date) as Cumulative_Revenue from
    (SELECT orders.date,ROUND(SUM(order_details.quantity * pizzas.price), 0) as total_revenue
     FROM order_details
     JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
     join orders
     on order_details.order_id=orders.order_id
GROUP BY orders.date) as Sales;

 
-- Q13:Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select Pizza_name,revenue 
from
(select category,Pizza_name,revenue,rank() over (partition by category  order by revenue desc  )  as rn
 from (
select round(sum(order_details.quantity * pizzas.price),0) as revenue,pizza_types.category as category,pizza_types.name as Pizza_name
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by category,Pizza_name) as sub_q ) as b
where rn<=3;



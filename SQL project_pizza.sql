CREATE DATABASE IF NOT EXISTS pizzahut;

CREATE TABLE orders(
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
PRIMARY KEY(order_id)
);

CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
PRIMARY KEY(order_details_id)
);

-- Retrieve the total number of orders placed 

SELECT DISTINCT(COUNT(order_id)) AS Total_Orders
FROM orders;

-- Calculate the total revenue generated from pizza sales

SELECT
ROUND(SUM(OD.quantity*PZ.price),2) AS Total_Revenue
FROM order_details AS OD
JOIN pizzas AS PZ
ON OD.pizza_id = PZ.pizza_id;

-- Identify the highest-priced pizza

SELECT pizza_types.name, pizzas.pizza_id, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
WHERE price = (SELECT MAX(price) 
FROM pizzas);

-- Identify the most common pizza size ordered

SELECT pizzas.size, COUNT(order_details_id) AS Order_Count
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;

-- List the top 5 most ordered pizza types along with their quantities

SELECT pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT pizza_types.category, SUM(order_details.quantity) AS Total_Quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS Hour, COUNT(order_id) AS Order_Count
FROM orders
GROUP BY Hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT pizza_types.category, COUNT(name) AS name
FROM pizza_types
GROUP BY pizza_types.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(SUM),0) AS Avg_Pizza_Ordered_Per_Day
FROM
(SELECT orders.order_date, SUM(order_details.quantity) as SUM
FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS Order_Quantity; 

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(order_details.quantity*pizzas.price) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category, ROUND(SUM(order_details.quantity*pizzas.price) / (SELECT
ROUND(SUM(OD.quantity*PZ.price),2) AS Total_Revenue
FROM order_details AS OD
JOIN pizzas AS PZ
ON OD.pizza_id = PZ.pizza_id)*100,2) AS Revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue generated over time.

SELECT order_date, Revenue,
SUM(Revenue) OVER( ORDER BY order_date) AS Cummulative_Revenue
FROM
(SELECT orders.order_date, SUM(order_details.quantity*pizzas.price) AS Revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue 
FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS temp) AS temp1
WHERE rn<=3;










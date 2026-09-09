-- Last-Mile Delivery Operations Analytics 

-- SPRINT - 1
-- ==========================================================================
-- DATABASE AND TABLE CREATION
-- ==========================================================================

CREATE DATABASE last_mile_delivery_company;
USE last_mile_delivery_company;

-- ==========================================================================
-- CUSTOMER TABLE
-- ==========================================================================
CREATE TABLE customers(
customer_id VARCHAR(20) PRIMARY KEY,
customer_name VARCHAR(100),
city VARCHAR(50),
delivery_zone_id VARCHAR(10),
preferred_time_slot VARCHAR(30),
customer_type VARCHAR(20),
account_since DATE
);

-- ==========================================================================
-- ORDERS TABLE
-- ==========================================================================
CREATE TABLE orders (
order_id VARCHAR(20) PRIMARY KEY,
customer_id VARCHAR(20),
order_date DATE,
delivery_zone_id VARCHAR(10),
package_weight_kg DECIMAL(5,2),
service_type VARCHAR(20),
priority VARCHAR(10),
total_value DECIMAL(10,2),
FOREIGN KEY (customer_id)
	REFERENCES customers(customer_id)
);

-- ==========================================================================
-- DRIVERS TABLE
-- ==========================================================================
CREATE TABLE drivers(
driver_id VARCHAR(10) PRIMARY KEY,
driver_name VARCHAR(100),
hire_date DATE,
rating DECIMAL(3,2),
employement_type VARCHAR(20),
is_active VARCHAR(3)
);

-- ==========================================================================
-- VEHICLES TABLE
-- ==========================================================================
CREATE TABLE vehicles(
vehicle_id VARCHAR(10) PRIMARY KEY,
vehicle_type VARCHAR(20),
fuel_type VARCHAR(20),
max_payload_kg DECIMAL(7,2),
depot VARCHAR(10),
last_service_date DATE,
is_active VARCHAR(3)
);

-- ==========================================================================
-- DELIVERIES TABLE
-- ==========================================================================
CREATE TABLE deliveries(
delivery_id VARCHAR(20) PRIMARY KEY,
order_id VARCHAR(20),
driver_id VARCHAR(10),
vehicle_id VARCHAR(10),
assigned_date DATE,
actual_delivery_date VARCHAR(20),
status VARCHAR(20),
delivery_attempt TINYINT,
distance_km DECIMAL(6,2),
delivery_duration_min INT,
FOREIGN KEY (order_id)
	REFERENCES orders(order_id),
FOREIGN KEY (driver_id)
    REFERENCES drivers(driver_id),
FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(vehicle_id)
);

SET SQL_SAFE_UPDATES = 0;
UPDATE deliveries SET actual_delivery_date = NULL WHERE actual_delivery_date = '';
SET  SQL_SAFE_UPDATES = 1;
ALTER TABLE deliveries MODIFY COLUMN actual_delivery_date DATE;

-- SPRINT 2
-- ==========================================================================
-- DATABASE SETUP AND DATA VERIFICATION
-- ==========================================================================
describe customers;
select COUNT(*) as total_customers from customers;
select * from customers;

describe orders;
select COUNT(*) as total_orders from orders;
select * from orders;

describe drivers;
select COUNT(*) as total_drivers from drivers;
select * from drivers;

describe vehicles;
select COUNT(*) as total_vehicles from vehicles;
select * from vehicles;

describe deliveries;
select COUNT(*) as total_deliveries from deliveries;
select * from deliveries;

-- SPRINT 3
-- ==========================================================================
-- BASIC ANALYSIS / DATA EXPLORATION
-- ==========================================================================

-- 1. What is the total number of customers?
select count(*) as total_customers from customers;

-- 2. What is the total number of orders?
select count(*) as total_orders from orders;

-- 3. What is the total number of deliveries?
select count(*) as total_deliveries from deliveries;

-- 4. What are the different service types available?
select distinct service_type from orders;

-- 5. How many drivers are currently active?
select count(*) as active_drivers from drivers
where is_active = 'Yes';

-- 6. What are the different vehicle types?
select distinct vehicle_type from vehicles;

-- 7.What is the total order value?
select sum(total_value) as total_order_value from orders;

-- 8. What is the average package weight?
select avg(package_weight_kg) as average_package_weight from orders;

-- SPRINT - 4
-- ==========================================================================
-- SPRINT - 4.1
-- UNDERSTAND DELIVERY DEMAND
-- ==========================================================================

-- 1. Which delivery zones receive the highest number of orders?
select delivery_zone_id,count(*) as total_orders 
from orders
group by delivery_zone_id
order by total_orders desc;

-- 2. Which delivery zones generate the highest total order value?
select delivery_zone_id, round(sum(total_value),2) as total_order_value
from orders
group by delivery_zone_id
order by total_order_value desc;

-- 3. Which service type is most frequently selected by customers?
select service_type,count(*) as total_orders
from orders
group by service_type
order by total_orders desc;

-- 4. Which priority level has the highest number of orders?
select priority,count(*) as total_orders 
from orders
group by priority
order by total_orders desc;

-- 5. Which priority level contributes the highest total order value?
select priority, sum(total_value) as total_order_value
from orders
group by priority
order by total_order_value desc;

-- 6. how does order volume vary by month?
select year(order_date) as order_year, month(order_date) as order_month,
count(*) as total_orders from orders
group by year(order_date),month(order_date)
order by order_year, order_month desc;


-- 7. Which delivery zone has the highest average package weight?
select delivery_zone_id, round(avg(package_weight_kg),2) as average_package_weight 
from orders
group by delivery_zone_id
order by average_package_weight desc;


-- 8. How does order demand differ between the different service types across delivery zones?
select delivery_zone_id,service_type,count(*) as total_orders, round(sum(total_value), 2) 
as total_order_value from orders
group by delivery_zone_id, service_type
order by delivery_zone_id,total_orders desc;

-- ==========================================================================
-- SPRINT 4.2
-- UNDERSTAND CUSTOMER ORDER BEHAVIOUR
-- ==========================================================================

-- 1. Which customers have placed the highest number of orders?
select c.customer_id,c.customer_name, count(o.order_id) as total_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name
order by total_orders desc;

-- 2. Which customers generate the highest total order value?
select c.customer_id,c.customer_name, round(sum(o.total_value),2) as total_order_value
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id,c.customer_name
order by total_order_value desc;

-- 3. Which customer type has more orders per customer?
select c.customer_type,count(o.order_id) as total_orders, count(distinct c.customer_id) as active_customers,
round(count(o.order_id) / count(distinct c.customer_id), 2) as avg_orders_per_customer
from customers c join orders o on c.customer_id = o.customer_id
group by c.customer_type
order by avg_orders_per_customer desc;

-- 4. Which customer type generates the highest total order value?
select c.customer_type, count(o.order_id) as total_orders,
round(sum(o.total_value), 2) as total_order_value
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_type
order by total_order_value desc;

-- 5. Which delivery zones have the highest number of active customers?
select c.delivery_zone_id,count(distinct c.customer_id) as active_customers
from customers c
join orders o on c.customer_id = o.customer_id
group by c.delivery_zone_id
order by active_customers desc;

-- 6. Which delivery zones have the highest average orders per customer?
select delivery_zone_id,count(order_id) / count(distinct customer_id) as avg_orders
from orders
group by delivery_zone_id
order by avg_orders desc;

-- 7. Which customer type has the highest average order value?
select c.customer_type,round(avg(o.total_value), 2) as average_order_value
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_type
order by average_order_value desc;

-- 8. Which preferred time slot is associated with the highest number of customer orders?
select c.preferred_time_slot,count(o.order_id) as total_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.preferred_time_slot
order by total_orders desc;

-- 9. How does customer ordering activity change over time?
select year(o.order_date) as order_year,month(o.order_date) as order_month,
count(distinct o.customer_id) as active_customers,count(o.order_id) as total_orders
from orders o
group by year(o.order_date), month(o.order_date)
order by order_year, order_month;

-- 10. Which customers are highly active and high-value?
select customer_id,count(order_id) as total_orders,round(sum(total_value), 2) as total_value
from orders
group by customer_id
order by total_orders desc, total_value desc;

-- ==========================================================================
-- SPRINT - 4.3
-- EVALUATE DELIVERY PERFORMANCE
-- ==========================================================================

-- 1. What is the delivery status distribution?
select status, count(*) as total_deliveries from deliveries
group by status
order by total_deliveries desc;

-- 2. Which delivery zones have the highest number of deliveries?
select o.delivery_zone_id, count(d.delivery_id) as total_deliveries
from orders o
join deliveries d on o.order_id = d.order_id
group by o.delivery_zone_id
order by total_deliveries desc;

-- 3. Which delivery zones have the most failed deliveries?
select o.delivery_zone_id, count(*) as failed_deliveries
from orders o
join deliveries d on o.order_id = d.order_id
where d.status = 'Failed'
group by o.delivery_zone_id
order by failed_deliveries desc;

-- 4. What is the average delivery duration by status?
select status, round(avg(delivery_duration_min),2) as avg_duration
from deliveries
group by status
order by avg_duration desc;

-- 5. Which delivery zones have the longest average delivery duration?
select o.delivery_zone_id,round(avg(d.delivery_duration_min),2) as avg_duration
from orders o
join deliveries d on o.order_id = d.order_id
group by o.delivery_zone_id
order by avg_duration desc;

-- 6. Which service types have the longest average delivery duration?
select o.service_type,round(avg(d.delivery_duration_min),2) as avg_duration
from orders o
join deliveries d on o.order_id = d.order_id
group by o.service_type
order by avg_duration desc;

-- 7. How does delivery performance vary by priority?
select o.priority, d.status, count(*) as total_deliveries from orders o
join deliveries d on o.order_id = d.order_id
group by o.priority, d.status
order by o.priority, total_deliveries desc;

-- 8. Which delivery statuses require the highest number of attempts?
select status, round(avg(delivery_attempt),2) as avg_attempts from deliveries
group by status
order by avg_attempts desc;

-- 9. How does delivery performance change over time?
select year(assigned_date) as year, month(assigned_date) as month, status, count(*) AS total
from deliveries
group by year, month, status
order by year, month;

-- 10. Which zones show poor delivery performance?
select o.delivery_zone_id,count(*) as total_deliveries,sum(d.status = 'Failed') AS failed_deliveries
from orders o
join deliveries d on o.order_id = d.order_id
group by o.delivery_zone_id
order by failed_deliveries desc;

-- ==========================================================================
-- SPRINT - 4.4
-- UNDERSTAND DRIVER AND VEHICLE PERFORMANCE
-- ==========================================================================


-- 1. Which drivers handled the highest number of deliveries?
select driver_id, count(*) as total_deliveries
from deliveries
group by driver_id
order by total_deliveries desc;

-- 2. Which drivers have the highest average delivery duration?
select driver_id, round(avg(delivery_duration_min),2) as avg_duration
from deliveries
group by driver_id
order by avg_duration desc;

-- 3. Which drivers completed the most successful deliveries?
select driver_id, count(*) as delivered_count from deliveries
where status = 'Delivered'
group by driver_id
order by delivered_count desc;

-- 4. Which drivers have handled failed deliveries?
select driver_id, count(*) as failed_deliveries from deliveries
where status = 'Failed'
group by driver_id
order by failed_deliveries desc;

-- 5. What is the average delivery duration for each vehicle type?
select v.vehicle_type,round(avg(d.delivery_duration_min),2) as avg_duration
from vehicles v
join deliveries d on v.vehicle_id = d.vehicle_id
group by v.vehicle_type
order by avg_duration desc;

-- 6. Which vehicle types are used for the most deliveries?
select v.vehicle_type, count(*) as total_deliveries from vehicles v
join deliveries d on v.vehicle_id = d.vehicle_id
group by v.vehicle_type
order by total_deliveries desc;

-- 7. Which vehicles have handled the most deliveries?
select vehicle_id, count(*) as total_deliveries from deliveries
group by vehicle_id
order by total_deliveries desc;

-- 8. Which vehicle types have the highest average payload capacity?
select vehicle_type,round(avg(max_payload_kg),2) as avg_payload from vehicles
group by vehicle_type
order by avg_payload desc;


-- ==========================================================================
-- SPRINT - 4.5
-- IDENTIFY DELIVERY PROBLEMS
-- ==========================================================================

-- 1. How many deliveries required more than one attempt?
select count(*) as multiple_attempts from deliveries
where delivery_attempt > 1;

-- 2. Which delivery statuses have the most failed or problematic deliveries?
select status,count(*) as total from deliveries where status in ('Failed','Pending','Rescheduled')
group by status
order by total desc;

-- 3. Which zones have the highest number of failed deliveries?
select o.delivery_zone_id,count(*) as failed_deliveries from orders o
join deliveries d on o.order_id = d.order_id
where d.status = 'Failed'
group by o.delivery_zone_id
order by failed_deliveries desc;

-- 4. Which zones have the highest number of multiple-attempt deliveries?
select o.delivery_zone_id, count(*) as multiple_attempts from orders o
join deliveries d on o.order_id = d.order_id
where d.delivery_attempt > 1
group by o.delivery_zone_id
order by multiple_attempts desc;

-- 5. What is the average delivery duration for deliveries requiring multiple attempts?
select round(avg(delivery_duration_min),2) as avg_duration
from deliveries
where delivery_attempt > 1;

-- 6. Which delivery statuses require the highest average number of attempts?
select status,round(avg(delivery_attempt),2) as avg_attempts
from deliveries
group by status
order by avg_attempts desc;

-- 7. Which zones have more failed deliveries than the average failed deliveries per zone?
select o.delivery_zone_id,count(*) as failed_deliveries from orders o
join deliveries d on o.order_id = d.order_id
where d.status = 'Failed'
group by o.delivery_zone_id
having count(*) > 10
order by failed_deliveries desc;

-- 8. How many deliveries are pending or rescheduled?
select status,count(*) as total from deliveries
where status in ('Pending','Rescheduled')
group by status;

-- 9. Which service types have the most failed deliveries?
select o.service_type,count(*) as failed_deliveries from orders o
join deliveries d on o.order_id = d.order_id
where d.status = 'Failed'
group by o.service_type
order by failed_deliveries desc;

-- 10. Which delivery zones show the highest overall problem activity?
select o.delivery_zone_id,count(*) as problem_deliveries from orders o
join deliveries d on o.order_id = d.order_id
where d.status in ('Failed','Pending','Rescheduled') or d.delivery_attempt > 1
group by o.delivery_zone_id
order by problem_deliveries desc;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
																																				--ANALYSIS BY RANDHIR 
            					        -- AIM OF ANALYSIS
-- Sales Performance
--Customer Segmentation
--Profitability
--Shipping & Delivery Efficiency
--Time-based Analysis
--Geographical Analysis
--Order Management & Efficiency							       
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
									-- LET'S KICK OFF THE PROJECT
-- REVIEW THE DATASET
SELECT * from sales LIMIT 5;

--CHECKING FOR NULL VALUES IN ANY OF COLUMN INSIDE THE DATASET
SELECT *FROM sales
	WHERE 
		order_id IS NULL
		OR
		order_date IS NULL
		OR
		order_priority IS NULL
		OR
		order_quantity IS NULL
		OR
		sales IS NULL
		OR
		unit_price IS NULL
		OR
		ship_mode IS NULL
		OR
		shipping_cost IS NULL
		OR
		province IS NULL
		OR
		customer_segment IS NULL
		OR
		product_category IS NULL
		OR
		product_sub_category IS NULL
		OR
		product_container IS NULL
		OR
		ship_date IS NULL
;

-- THERE IS NO MISSING VALUE IN THIS DATASET SO LET'S DIRECT JUMP ONTO ANALYSIS.

		-- Sales Performance
--How have total sales changed over time (by year, quarter, or month)?
--by year
		
SELECT 
		EXTRACT(YEAR from order_date) as YEAR,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY EXTRACT(YEAR from order_date)
	ORDER BY EXTRACT(year from order_date);
	
--by month
SELECT 
		EXTRACT(YEAR from order_date) as YEAR,
		EXTRACT(month from order_date) as MONTH,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY EXTRACT(YEAR from order_date),EXTRACT(month from order_date)
	ORDER BY EXTRACT(YEAR from order_date),EXTRACT(month from order_date);
	
--by quarterly
SELECT 
		EXTRACT(YEAR from order_date) as YEAR,
		EXTRACT(quarter from order_date) as QUARTER,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY EXTRACT(YEAR from order_date) ,EXTRACT(quarter from order_date)
	ORDER BY EXTRACT(YEAR from order_date),EXTRACT(quarter from order_date);
	
-- Sales Growth Rate:
	--What is the sales growth rate over time (monthly, quarterly, or yearly)?
		--yearly
with yearly_sales_growth as 
(
	SELECT 
			EXTRACT(YEAR FROM order_date) as YEAR,
			sum(sales) as TOTAL_SALES
		FROM sales
		GROUP BY EXTRACT(YEAR FROM order_date)
		ORDER BY EXTRACT(YEAR FROM order_date)
)
				SELECT 
						YEAR,TOTAL_SALES,
						LAG(TOTAL_SALES) OVER(ORDER BY YEAR) as PREVIOUS_YEAR_SALES,
						(TOTAL_SALES-LAG(TOTAL_SALES) OVER(ORDER by YEAR))/
						LAG(TOTAL_SALES) OVER(ORDER BY YEAR) * 100 as yearly_sales_growth
					FROM yearly_sales_growth
					ORDER BY YEAR;

--Monthly
with monthly_sales_growth as(
		SELECT 
				EXTRACT(YEAR from order_date) as YEAR,
				EXTRACT(month from order_date) as MONTH,
				sum(sales) as TOTAL_SALES
			FROM sales
			GROUP BY EXTRACT(YEAR from order_date),EXTRACT(month from order_date)
			ORDER BY EXTRACT(YEAR from order_date),EXTRACT(month from order_date)
		)
				SELECT 
						YEAR,
						MONTH,
						TOTAL_SALES,
						LAG(TOTAL_SALES) OVER (ORDER BY year, month) AS previous_month_sales,
					    (TOTAL_SALES - LAG(TOTAL_SALES) OVER (ORDER BY year,month)) /
						LAG(TOTAL_SALES) OVER (ORDER BY year, month) * 100 AS sales_growth_rate
					FROM monthly_sales_growth
					ORDER BY year, month;

--Quaterly
WITH quarterly_sales_growth as 
(
			SELECT 
					EXTRACT(YEAR FROM order_date) as YEAR,
					EXTRACT(QUARTER FROM order_date ) as QUARTER,
					sum(sales) as TOTAL_SALES
				
)
				SELECT 
						YEAR,
						QUARTER,
						TOTAL_SALES,
						LAG(TOTAL_SALES) OVER(ORDER BY YEAR,QUARTER) as previous_quarter_sales,
						(TOTAL_SALES-(LAG(TOTAL_SALES) OVER(ORDER BY YEAR,QUARTER)))/
						LAG(TOTAL_SALES) OVER(ORDER BY YEAR,QUARTER)*100 as sales_growth_rate
					FROM quarterly_sales_growth
					ORDER BY YEAR,QUARTER;

					
--average moving sales over 3 month period
WITH sales_by_month AS
(
		SELECT 
				EXTRACT(YEAR FROM order_date) AS year,
				EXTRACT(MONTH FROM order_date) AS month,
				SUM(sales) AS total_sales
			FROM sales
			GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
			ORDER BY year, month
)
				SELECT 
						year,
						month,
						total_sales,
						AVG(total_sales) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3months
					FROM sales_by_month;

--Which product categories and subcategories generate the most revenue?
	--PRODUCT CATEGORY
SELECT 
		product_category as PRODUCT_CATEGORY,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY product_category
	ORDER BY TOTAL_SALES desc; --Technology genrates heighest revenue

--PRODUCT SUB CATEGORY
SELECT 
		product_sub_category as PRODUCT_SUB_CATEGORY,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY product_sub_category
	ORDER BY TOTAL_SALES desc; -- Office machine followed by Tables produce high revenue in product_sub_category

--Identify the top 10 best-selling products.
with topsales as
(
		SELECT
				product_sub_category,
				sum(sales) as TOTAL_SALES 
			FROM sales
			GROUP BY product_sub_category
)
				SELECT 
						product_sub_category as PRODUCT_SUB_CATEGORY
					FROM topsales
					ORDER BY TOTAL_SALES desc
					LIMIT 10;

--Top 5 best selling product sub category in product category
WITH ranked_sales AS (
		SELECT
				product_category,
				product_sub_category,
				SUM(sales) AS TOTAL_SALES,
				RANK() OVER (PARTITION BY product_category ORDER BY SUM(sales) DESC) AS RANK
			FROM sales
			GROUP BY product_category, product_sub_category
					)
					SELECT
							product_category,
							product_sub_category,
							TOTAL_SALES
						FROM ranked_sales
						WHERE RANK <6
						ORDER BY product_category;

		-- CUSTOMER SEGMENTATION
--Which customer segments (e.g., small business, corporate) contribute the most to total sales?
SELECT 
		customer_segment as CUSTOMER_SEGEMNT ,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY customer_segment
	ORDER BY TOTAL_SALES desc; -- corporate,home office constribute most


--Which customer segments place overall most orders?
SELECT
		customer_segment,
		count(order_id) as orders
	FROM Sales
	GROUP BY customer_segment
	ORDER BY orders desc; -- corporate,home office place most orders

		--* Order Size vs. Customer Segment:
--How does the average order quantity vary across different customer segments?
SELECT 
		customer_segment,
		avg(order_quantity) as AVERAGE_ORDER_QUANTITY
	FROM sales
	GROUP BY customer_segment
	ORDER BY AVERAGE_ORDER_QUANTITY desc; --on average home office,corrporate place most quantity and others are also approxmately place in same number

		-- Profitability
--Product Category Profitability:
--Which product categories are the most profitable (sales minus shipping cost)?
SELECT 
		product_sub_category,
		sum(sales) as TOTAL_SALES,
		sum(shipping_cost) as TOTAL_SHIPPING_COST ,
		(sum(sales)-sum(shipping_cost)) as PROFIT
	FROM sales
	GROUP BY product_sub_category
	ORDER BY PROFIT desc; --office machine and telephone and communication is most profitable sub category

-- Shipping Costs Impact:
--How do shipping costs affect overall profitability by product or region?

with province_profitibilty as (
		SELECT 
				province,
				SUM(sales) AS total_sales,
				SUM(shipping_cost) AS total_shipping_cost,
				(SUM(sales) - SUM(shipping_cost)) AS total_profit,
				(SUM(shipping_cost) / SUM(sales)) * 100 AS shipping_cost_percentage
			FROM sales
			GROUP BY province
			ORDER BY total_profit DESC
								)
					SELECT * FROM province_profitibilty; --newfoundland and nunavut have high shipping cost percenatge which leads to decrade in profitibilty


-- let's investegate which product has heighest shipping rate in newfoundland and nunavut
SELECT 
		province,
		product_sub_category,
		SUM(sales) AS total_sales,
		SUM(shipping_cost) AS total_shipping_cost,
		(SUM(sales) - SUM(shipping_cost)) AS total_profit,
		(SUM(shipping_cost) / SUM(sales)) * 100 AS shipping_cost_percentage
	FROM sales
			WHERE province = 'Newfoundland' OR province = 'Nunavut'
				GROUP BY province,product_sub_category
				ORDER BY shipping_cost_percentage DESC;

-- In Nunavut on tables,binder and accessories has heighest shipping cost percentage
--In Newfoundland on envelopes,scissors,rulers and trimmers has heighest shipping cost
--let's find out why it is so much is due to specific type of product container or shipping mode

SELECT 
		province,
		product_sub_category,
		ship_mode,
		SUM(sales) AS total_sales,
		SUM(shipping_cost) AS total_shipping_cost,
		(SUM(sales) - SUM(shipping_cost)) AS total_profit,
		(SUM(shipping_cost) / SUM(sales)) * 100 AS shipping_cost_percentage
	FROM sales
			WHERE province = 'Newfoundland' OR province = 'Nunavut'
				GROUP BY province,product_sub_category,ship_mode
				ORDER BY shipping_cost_percentage DESC;
				
--The shipping_cost_percentage is too high for tables,binder and accessories,envelopes,scissors,rulers and trimmers because they used Regular air or express air for shipping which cost high
-- let's investigate why they use express air or regluar air by using order priority factor

SELECT 
		province,
		product_sub_category,
		ship_mode,
		order_priority,
		SUM(sales) AS total_sales,
		SUM(shipping_cost) AS total_shipping_cost,
		(SUM(sales) - SUM(shipping_cost)) AS total_profit,
		(SUM(shipping_cost) / SUM(sales)) * 100 AS shipping_cost_percentage
	FROM sales
			WHERE province = 'Newfoundland' OR province = 'Nunavut'
				GROUP BY province,product_sub_category,ship_mode,order_priority
				ORDER BY shipping_cost_percentage DESC;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CONCLUSION :				
-- After investigating the factor we find that in Nunavut tables,binder and accessories are ordered with critical priority but
--In Newfoundland envelopes,scissors,rulers and trimmers need is not much high cause their order priority is low
-- we should find another way to shipp envelopes,scissors,rulers and trimmers in Newfoundland instead of regular air to increase profit.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

		-- Shipping & Delivery Efficiency
-- Shipping Time Analysis:
--What is the average shipping time for each shipping mode (e.g., regular air, express)?

SELECT 
		ship_mode,
		avg(ship_date-order_date) as average_shipping_time 
	FROM sales
	GROUP BY ship_mode;

-- Delayed Deliveries:
--How many orders are delayed (difference between order date and ship date)?
with Delayed_Deliveries as(
		SELECT 
				EXTRACT(DAY FROM (AGE(ship_date, order_date))) as delayed_days
		FROM sales
		                   )
				SELECT 
						delayed_days,
						count(delayed_days) as count_delayed_days 
					FROM Delayed_Deliveries
						WHERE delayed_days>0
						GROUP BY delayed_days
						ORDER BY count_delayed_days desc;
						
--Finding Delayed Deliveries for product_sub_category
with Delayed_Deliveries_For_Product as
		(
			SELECT 
				product_sub_category,
				EXTRACT(DAY FROM (AGE(ship_date,order_date))) as delayed_days
					FROM sales
		)
						SELECT 
							product_sub_category,
							delayed_days,count(delayed_days) as count_delayed_days
								FROM Delayed_Deliveries_For_Product
									WHERE delayed_days>0
									GROUP BY product_sub_category,delayed_days
									ORDER BY product_sub_category desc;
-- Mostly in product_sub_category all products are delivered in or 2 days sometimes products are delivered on same day may be due to critical order priority

--Finding Delayed Deliveries by region
with Delayed_Deliveries_By_Region as
		(
		SELECT 
			province,
			EXTRACT(DAY FROM (AGE(ship_date, order_date))) as delayed_days
		FROM sales
		)
			SELECT 
				province,
				delayed_days,
				count(delayed_days) as count_delayed_days
			FROM Delayed_Deliveries_By_Region
				WHERE delayed_days>0
				GROUP BY province,delayed_days
				ORDER BY province,delayed_days desc;
-- In yukon,quebec,ontario those are the countaries where product  get delayed mostly.

--Finding Delayed Deliveries by Shipping_mode
with Delayed_Deliveries_By_shipping_mode as(
		SELECT 
			ship_mode,
			EXTRACT(DAY FROM (AGE(ship_date, order_date))) as delayed_days
		FROM sales
		)
			SELECT 
				ship_mode,
				delayed_days,
				count(delayed_days) as count_delayed_days
			FROM Delayed_Deliveries_By_shipping_mode
					WHERE delayed_days>0
					GROUP BY ship_mode,delayed_days
					ORDER BY delayed_days desc;
--Regular air is most delayed shipping mode after that Delivery truck and least is express air.

		-- Geographical analysis:
--Sales by Region/Province:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Which provinces or regions contribute the most to overall sales?
SELECT 
		province,
		sum(sales) as TOTAL_SALES,
		avg(sales) as AVG_SALES
	FROM sales
	GROUP BY province
	ORDER BY TOTAL_SALES desc; 
-- Ontario,British Columbia contributes most to overall sales but on average New Brunswick,Northwest Terriotories genrate most of sales
--Overall sales of Ontario and British Columbia is high may be of high number of product quantity purchased from these states.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Shipping Cost by Province:
--Are certain regions more expensive to ship to? How does this affect overall profitability?
SELECT
		province,
		sum(shipping_cost) as SHIPPING_CHARGES
	FROM sales
	GROUP BY province
	ORDER BY SHIPPING_CHARGES DESC; 
--Ontario,British Columbia,Alberta,Quebec these states have highest shipping charges

	-- Regional Product Demand:
--Which regions have the highest demand for specific product categories?
SELECT 
		province,
		product_sub_category,
		count(product_sub_category) as DEMAND,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY province,product_sub_category
	ORDER BY province,count(product_sub_category) desc; 
--In each province the demand of paper,binder and accessories,telephone and communication has highest

		-- Order Management & Efficiency:
-- Order Priority Analysis:
SELECT 
		order_priority,
		EXTRACT(DAY FROM AGE(ship_date,order_date)) as delivery_time,
		count(EXTRACT(DAY FROM AGE(ship_date,order_date))) as NUMBER_OF_TIME_THEY_DELAY
	FROM sales
	GROUP by order_priority,delivery_time
	ORDER BY order_priority,delivery_time desc;
	
--Do high-priority orders get delivered faster? How do sales from high-priority orders compare to regular orders?
with high_priority_orders as
	(
	SELECT
			order_priority,
			EXTRACT(DAY FROM AGE(ship_date,order_date)) as delivery_time,
			count(EXTRACT(DAY FROM AGE(ship_date,order_date))) as NUMBER_OF_TIME_THEY_DELAY,
			sum(sales) as TOTAL_SALES
		FROM sales
		WHERE order_priority in ('Critical','High')
		GROUP by order_priority,delivery_time
		)
			SELECT * 
				FROM high_priority_orders
					ORDER BY delivery_time desc; 
-- Most of times when order priority is critical and high products are placed in 0-3 days but for 1 time they delayed for 25,7,4 days in critical priority


with low_priority_orders as
	(
	SELECT 
			order_priority,
			EXTRACT(DAY FROM AGE(ship_date,order_date)) as delivery_time,
			count(EXTRACT(DAY FROM AGE(ship_date,order_date))) as NUMBER_OF_TIME_THEY_DELAY,
			sum(sales) as TOTAL_SALES_IN_LOW_PRIORITY
		FROM sales
		WHERE order_priority NOT IN ('Critical','High')
		GROUP BY order_priority,delivery_time
	)
	SELECT * 
		FROM low_priority_orders
	ORDER BY order_priority,delivery_time desc; 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CONCLUSION:
--Interesting factor we find that is even after low order priority products are placed on same day as well and
--oftenly it take 0-3 days to place product to destination.In low priority somethimes it take long as well like 7-9 days or once in a while it take 22-27 days
--In medium priority take 19,18,17,15,11 days to placed products to destination these this is happen only one time for each delay
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

		-- Order Quantity Trends:
--What is the average order quantity, and how does it vary by product category or customer segment?
SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		EXTRACT(MONTH FROM order_date) AS month,
		product_category,
		product_sub_category,
		COUNT(order_id) AS TOTAL_ORDERS,
		avg(order_quantity) as AVERAGE_ORDER_QUANTITY,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY product_category,product_sub_category,year,month
	ORDER BY year,month,product_category,AVERAGE_ORDER_QUANTITY desc;
	
--By Customer Segment
SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		EXTRACT(MONTH FROM order_date) AS month,
		customer_segment,
		COUNT(order_id) AS TOTAL_ORDERS,
		avg(order_quantity) as AVERAGE_ORDER_QUANTITY,
		sum(sales) as TOTAL_SALES
	FROM sales
	GROUP BY customer_segment,year,month
	ORDER BY year;
	
																																				--ANALYSIS BY RANDHIR
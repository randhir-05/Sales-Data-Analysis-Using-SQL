--CREATING SALES DATABASE SCHEMA 

-- In this project we try to analyze sales dataset
--having columns like
--Order ID: Unique identifier for each order.
--Order Date: The date the order was placed.
--Order Priority: Priority of the order (e.g., High, Critical,Low).
--Order Quantity: Number of items ordered.
--Sales: The total sales amount.
--Unit Price: Price per unit.
--Ship Mode: The shipping method (e.g., Regular Air, Express Air).
--Shipping Cost: Cost of shipping.
--Province: The region where the order was shipped.
--Customer Segment: Type of customer (e.g., Small Business, Home Office).
--Product Category: The product's general category (e.g., Office Supplies, Technology).
--Product Sub-Category: Specific product classification (e.g.,Paper, Telephones).
--Product Container: The type of container used for shipping.
--Ship Date: The date the order was shipped.


                                   -- AIM OF ANALYSIS
  -- Sales Performance,Customer Segmentation, Profitability,Shipping& Delivery Efficiency,Time-based Analysis,Geographical Analysis,Order Management & Efficiency
DROP TABLE IF EXISTS "sales";

CREATE TABLE "sales" (
    "order_id"	INT,
    "order_date"	DATE,
    "order_priority"	VARCHAR(50),
    "order_quantity"	INT,
    "sales"	FLOAT,
    "unit_price"	FLOAT,
    "ship_mode"	VARCHAR(90),
    "shipping_cost"	FLOAT,
    "province"	VARCHAR(150),
    "customer_segment"	VARCHAR(100),
    "product_category"	VARCHAR(100),
    "product_sub_category"	VARCHAR(100),
    "product_container"	VARCHAR(100),
    "ship_date"	DATE
);

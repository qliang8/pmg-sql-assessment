# Use pmg database
USE pmg_data;

# Exploring store_revenue table
SELECT * 
FROM store_revenue;

# Exploring marketing_data table
SELECT * 
FROM marketing_data;

-- Question #0 (Already done for you as an example) Select the first 2 rows from the marketing data

SELECT * 
FROM marketing_data
LIMIT 2;

-- Question #1 Generate a query to get the sum of the clicks of the marketing data​

# generate sum of the clicks of all the store from marketing data
SELECT SUM(clicks) AS sum_clicks_marketing
FROM marketing_data;

-- Question #2 Generate a query to gather the sum of revenue by geo from the store_revenue table​

# generate sum of the revenue by geo 
SELECT store_location,
	   SUM(revenue) AS revenue_by_geo
FROM store_revenue
GROUP BY store_location;

-- Question #3 Merge these two datasets so we can see impressions, clicks, and revenue together by date and geo. 
-- Please ensure all records from each table are accounted for.​

# merge revenue and marketing tables by date and location. Because there are no FULL OUTER JOIN in MySQL, 
# I UNION two LEFT JOIN and RIGHT JOIN tables to get the complete view of the data. 
# By exproling the merged table, we can see that there are missing markting data of brand_id = 3 
# and missing the revenue data of store at MN. 

SELECT * 
FROM store_revenue s 
LEFT JOIN marketing_data m 
ON s.date = m.date AND SUBSTRING(s.store_location, -2, 2) = m.geo
UNION
SELECT * 
FROM store_revenue s 
RIGHT JOIN marketing_data m 
ON s.date = m.date AND SUBSTRING(s.store_location, -2, 2) = m.geo;

-- Question #4 In your opinion, what is the most efficient store and why?​

# Create a temporary table of merged revenue and marketing data without null values
# excluding the brands that does not involve marketing and the store that does not generate revenue
WITH store_revenue_markt AS(
SELECT s.store_location, s.revenue, m.impressions
FROM store_revenue s 
INNER JOIN marketing_data m 
ON s.date = m.date AND SUBSTRING(s.store_location, -2, 2) = m.geo
)

# generate Revenue per Mille for each store location. The store with most RPM will
# be the most efficient store, because this store earn more with less impressions than other stores.
# In this case store CA has the most RPM, so CA is the most efficient store.
SELECT store_location, 
		SUM(revenue) AS sum_revenue, 
		SUM(impressions) AS sum_impressions,
		ROUND(SUM(revenue)/SUM(impressions) * 1000, 2) AS RPM
FROM store_revenue_markt
GROUP BY store_location
ORDER BY RPM DESC
LIMIT 1;

-- Question #5 (Challenge) Generate a query to rank in order the top 10 revenue producing states​

# generate the sum of the revenue by store location, 
# then rank the store by sum_revenue in decsending orders and limit by 10 records.
SELECT store_location, 
		SUM(revenue) AS sum_revenue, 
        RANK() OVER (ORDER BY SUM(revenue) DESC) AS store_rk
FROM store_revenue
GROUP BY store_location
LIMIT 10;


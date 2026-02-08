
-- Extensive Customer Shopping Behavior Analysis
-- Platform: PostgreSQL



-- SECTION 1: HIGH-LEVEL KPI OVERVIEW


-- 1.1 Total Revenue, Average Order Value (AOV), and Customer Count
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(AVG(review_rating), 2) AS avg_customer_rating
FROM customer_data_final;

-- 1.2 Sales Performance by Product Category
SELECT 
    category,
    COUNT(*) AS total_transactions,
    SUM(purchase_amount) AS total_sales,
    ROUND(AVG(purchase_amount), 2) AS avg_item_price,
    ROUND(AVG(review_rating), 2) AS avg_rating
FROM customer_data_final
GROUP BY category
ORDER BY total_sales DESC;


-- SECTION 2: DEMOGRAPHIC & GEOGRAPHIC INSIGHTS


-- 2.1 Top 5 Locations by Spending
SELECT 
    location,
    COUNT(customer_id) AS customer_count,
    SUM(purchase_amount) AS total_spent
FROM customer_data_final
GROUP BY location
ORDER BY total_spent DESC
LIMIT 5;

-- 2.2 Purchasing Power by Age Group and Gender
SELECT 
    age_group,
    gender,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    SUM(purchase_amount) AS total_spend
FROM customer_data_final
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- SECTION 3: ADVANCED CUSTOMER SEGMENTATION


-- 3.1 Categorizing Customers into Spender Tiers (High/Medium/Low)
-- Using a CTE (Common Table Expression) for cleaner logic
WITH CustomerSegments AS (
    SELECT 
        customer_id,
        purchase_amount,
        CASE 
            WHEN purchase_amount > 80 THEN 'High Spender'
            WHEN purchase_amount BETWEEN 40 AND 80 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS spender_tier
    FROM customer_data_final
)
SELECT 
    spender_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM CustomerSegments
GROUP BY spender_tier
ORDER BY avg_spend DESC;

-- 3.2 Subscription Value Analysis
-- Does having a subscription correlate with higher ratings or spend?
SELECT 
    subscription_status,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount,
    ROUND(AVG(review_rating), 2) AS avg_rating,
    ROUND(AVG(previous_purchases), 1) AS avg_loyalty_score
FROM customer_data_final
GROUP BY subscription_status;

-- SECTION 4: SEASONAL & TREND ANALYSIS (WINDOW FUNCTIONS)


-- 4.1 Ranking Best-Selling Items within Each Season
-- Using Window Function ROW_NUMBER() to find the top item per season
WITH SeasonalRankings AS (
    SELECT 
        season,
        item_purchased,
        SUM(purchase_amount) AS total_sales,
        ROW_NUMBER() OVER(PARTITION BY season ORDER BY SUM(purchase_amount) DESC) as rank
    FROM customer_data_final
    GROUP BY season, item_purchased
)
SELECT * FROM SeasonalRankings 
WHERE rank <= 3; -- Shows Top 3 items for Spring, Summer, Winter, Fall

-- 4.2 Cumulative Revenue Contribution by Location
SELECT 
    location,
    SUM(purchase_amount) as location_revenue,
    SUM(SUM(purchase_amount)) OVER (ORDER BY SUM(purchase_amount) DESC) as running_total_revenue
FROM customer_data_final
GROUP BY location
LIMIT 10;


-- SECTION 5: OPERATIONAL METRICS (SHIPPING & PAYMENTS)


-- 5.1 Payment Method Preferences by Generation (Age Group)
SELECT 
    age_group,
    payment_method,
    COUNT(*) as usage_count
FROM customer_data_final
GROUP BY age_group, payment_method
ORDER BY age_group, usage_count DESC;

-- 5.2 Impact of Discounts on Review Ratings
SELECT 
    discount_applied,
    ROUND(AVG(review_rating), 2) AS avg_rating,
    COUNT(*) AS total_sales
FROM customer_data_final
GROUP BY discount_applied;

-- Q1: Total customers who placed orders & distribution across states
SELECT  
    c.state,  
    COUNT(DISTINCT o.customer_id) AS customers_with_orders 
FROM  
    Customer_t c 
JOIN  
    Order_t o ON c.customer_id = o.customer_id 
GROUP BY  
    c.state 
ORDER BY  
    customers_with_orders DESC;
    

-- Q2: Top 5 vehicle makers preferred by customers
SELECT  
    p.vehicle_maker, 
    COUNT(*) AS total_orders 
FROM  
    order_t o 
JOIN  
    product_t p ON o.product_id = p.product_id 
GROUP BY  
    p.vehicle_maker 
ORDER BY  
    total_orders DESC 
LIMIT 5;


-- Q3: Most preferred vehicle maker in each state
SELECT state, vehicle_maker, customer_count
FROM ( 
    SELECT c.state, p.vehicle_maker, 
        COUNT(DISTINCT c.customer_id) AS customer_count, 
        RANK() OVER (PARTITION BY c.state ORDER BY COUNT(DISTINCT c.customer_id) DESC) AS rnk 
    FROM  
        customer_t c 
    JOIN order_t o ON c.customer_id = o.customer_id 
    JOIN product_t p ON o.product_id = p.product_id 
    GROUP BY c.state, p.vehicle_maker
) AS ranked 
WHERE rnk = 1 
ORDER BY state;


-- Q4: Overall average rating and average rating per quarter
SELECT  
    quarter_number,  
    AVG(
        CASE customer_feedback 
            WHEN 'Very Bad' THEN 1 
            WHEN 'Bad' THEN 2 
            WHEN 'Okay' THEN 3 
            WHEN 'Good' THEN 4 
            WHEN 'Very Good' THEN 5 
        END
    ) AS avg_rating_per_quarter 
FROM  
    order_t 
GROUP BY  
    quarter_number 
ORDER BY  
    quarter_number;


-- Q5: Percentage distribution of feedback per quarter
SELECT  
    quarter_number, 
    ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_very_good, 
    ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_good, 
    ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_okay, 
    ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_bad, 
    ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_very_bad 
FROM  
    order_t 
GROUP BY  
    quarter_number 
ORDER BY  
    quarter_number;


-- Q6: Trend of number of orders by quarter
SELECT  
    quarter_number, 
    COUNT(*) AS total_orders 
FROM  
    order_t 
GROUP BY  
    quarter_number 
ORDER BY  
    quarter_number;


-- Q7: Net revenue & quarter-over-quarter % change
SELECT  
    quarter_number, 
    ROUND(net_revenue, 2) AS net_revenue, 
    ROUND( 
        CASE  
            WHEN LAG(net_revenue) OVER (ORDER BY quarter_number) IS NULL THEN NULL 
            ELSE ((net_revenue - LAG(net_revenue) OVER (ORDER BY quarter_number)) / LAG(net_revenue) OVER (ORDER BY quarter_number)) * 100 
        END, 2
    ) AS qoq_percentage_change 
FROM ( 
    SELECT  
        quarter_number, 
        SUM(quantity * vehicle_price * (1 - discount)) AS net_revenue 
    FROM order_t 
    GROUP BY quarter_number
) AS revenue_summary 
ORDER BY quarter_number;


-- Q8: Trend of net revenue and orders by quarters
SELECT  
    quarter_number, 
    COUNT(*) AS total_orders, 
    ROUND(SUM(quantity * vehicle_price * (1 - discount)), 2) AS net_revenue 
FROM  
    order_t 
GROUP BY  
    quarter_number 
ORDER BY  
    quarter_number;


-- Q9: Average discount offered for different credit card types
SELECT  
    c.credit_card_type, 
    ROUND(AVG(o.discount), 2) AS avg_discount 
FROM  
    customer_t c 
JOIN  
    order_t o ON c.customer_id = o.customer_id 
GROUP BY  
    c.credit_card_type 
ORDER BY  
    avg_discount DESC;


-- Q10: Average time taken to ship orders per quarter
SELECT  
    quarter_number, 
    ROUND(AVG(julianday(ship_date) - julianday(order_date)), 2) AS avg_shipping_time 
FROM  
    order_t 
WHERE  
    ship_date IS NOT NULL AND order_date IS NOT NULL 
GROUP BY  
    quarter_number 
ORDER BY  
    quarter_number;

-- =========================================
-- Insurance Claims Analysis
-- =========================================

-- 1. Claims per policy
SELECT 
    p.policy_id,
    COUNT(c.claim_id) AS total_claims
FROM policies p
LEFT JOIN claims c ON p.policy_id = c.policy_id
GROUP BY p.policy_id
ORDER BY total_claims DESC;


-- 2. Profitability per policy
SELECT 
    p.policy_id,
    p.premium_amount,
    SUM(c.claim_amount) AS total_claims,
    p.premium_amount - SUM(c.claim_amount) AS profit
FROM policies p
LEFT JOIN claims c ON p.policy_id = c.policy_id
GROUP BY p.policy_id, p.premium_amount;


-- 3. Average claim by smoker status
SELECT 
    c.smoker,
    AVG(cl.claim_amount) AS avg_claim
FROM customers c
JOIN policies p ON c.customer_id = p.customer_id
JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY c.smoker;


-- 4. Policies ranked by claim volume
WITH claim_counts AS (
    SELECT 
        p.policy_id AS policy_id,
        COUNT(c.claim_id) AS total_claims
    FROM policies AS p
    LEFT JOIN claims AS c 
        ON p.policy_id = c.policy_id
    GROUP BY p.policy_id
)
SELECT 
    policy_id AS policy_id,
    total_claims AS total_claims,
    RANK() OVER (ORDER BY total_claims DESC) AS claim_rank
FROM claim_counts;


-- 5. Unprofitable customers
WITH customer_profit AS (
    SELECT 
        c.customer_id AS customer_id,
        p.premium_amount AS premium_amount,
        COALESCE(SUM(cl.claim_amount), 0) AS total_claims,
        p.premium_amount - COALESCE(SUM(cl.claim_amount), 0) AS profit
    FROM customers AS c
    JOIN policies AS p 
        ON c.customer_id = p.customer_id
    LEFT JOIN claims AS cl 
        ON p.policy_id = cl.policy_id
    GROUP BY 
        c.customer_id,
        p.premium_amount
)
SELECT 
    customer_id AS customer_id,
    premium_amount AS premium_amount,
    total_claims AS total_claims,
    profit AS profit
FROM customer_profit
WHERE profit < 0
ORDER BY profit ASC;


-- 6. Smokers vs non-smokers claim difference
WITH smoker_stats AS (
    SELECT 
        c.smoker AS smoker,
        AVG(cl.claim_amount) AS avg_claim
    FROM customers AS c
    JOIN policies AS p 
        ON c.customer_id = p.customer_id
    JOIN claims AS cl 
        ON p.policy_id = cl.policy_id
    GROUP BY c.smoker
)
SELECT 
    s1.smoker AS smoker_group,
    s1.avg_claim AS smoker_avg_claim,
    s1.avg_claim - s2.avg_claim AS difference
FROM smoker_stats AS s1
JOIN smoker_stats AS s2 
    ON s1.smoker = 'yes' 
   AND s2.smoker = 'no';


-- 7. Regional risk comparison
SELECT 
    c.region AS region,
    AVG(cl.claim_amount) AS avg_claim,
    AVG(AVG(cl.claim_amount)) OVER () AS overall_avg,
    AVG(cl.claim_amount) - AVG(AVG(cl.claim_amount)) OVER () AS deviation
FROM customers AS c
JOIN policies AS p 
    ON c.customer_id = p.customer_id
JOIN claims AS cl 
    ON p.policy_id = cl.policy_id
GROUP BY c.region;


-- 8. Claim approval percentage
SELECT 
    claim_status AS claim_status,
    COUNT(*) AS total,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage
FROM claims
GROUP BY claim_status;


-- 9. High-risk customers
WITH customer_risk AS (
    SELECT 
        c.customer_id AS customer_id,
        c.age AS age,
        c.smoker AS smoker,
        COUNT(cl.claim_id) AS claim_count,
        SUM(cl.claim_amount) AS total_claims
    FROM customers AS c
    JOIN policies AS p 
        ON c.customer_id = p.customer_id
    JOIN claims AS cl 
        ON p.policy_id = cl.policy_id
    GROUP BY 
        c.customer_id,
        c.age,
        c.smoker
)
SELECT 
    customer_id AS customer_id,
    age AS age,
    smoker AS smoker,
    claim_count AS claim_count,
    total_claims AS total_claims,
    RANK() OVER (ORDER BY total_claims DESC) AS risk_rank
FROM customer_risk;


-- 10. Outlier claims
SELECT 
    cl.claim_id AS claim_id,
    cl.policy_id AS policy_id,
    cl.claim_amount AS claim_amount
FROM claims AS cl
WHERE cl.claim_amount > (
    SELECT 
        AVG(claim_amount) + 2 * STDEV(claim_amount)
    FROM claims
);


-- 11. Running total per policy
SELECT 
    cl.policy_id AS policy_id,
    cl.claim_id AS claim_id,
    cl.claim_amount AS claim_amount,
    SUM(cl.claim_amount) OVER (
        PARTITION BY cl.policy_id 
        ORDER BY cl.claim_id
    ) AS running_total
FROM claims AS cl;


-- 12. Above-average customers
SELECT 
    c.customer_id AS customer_id,
    SUM(cl.claim_amount) AS total_claims
FROM customers AS c
JOIN policies AS p 
    ON c.customer_id = p.customer_id
JOIN claims AS cl 
    ON p.policy_id = cl.policy_id
GROUP BY c.customer_id
HAVING SUM(cl.claim_amount) > (
    SELECT AVG(total_claims)
    FROM (
        SELECT 
            SUM(claim_amount) AS total_claims
        FROM claims
        GROUP BY policy_id
    ) AS sub
);


-- 13. Premium vs claim frequency
WITH metrics AS (
    SELECT 
        p.policy_id AS policy_id,
        p.premium_amount AS premium_amount,
        COUNT(cl.claim_id) AS claim_count
    FROM policies AS p
    LEFT JOIN claims AS cl 
        ON p.policy_id = cl.policy_id
    GROUP BY 
        p.policy_id,
        p.premium_amount
)
SELECT 
    premium_amount AS premium_amount,
    AVG(claim_count) AS avg_claims
FROM metrics
GROUP BY premium_amount
ORDER BY premium_amount;
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
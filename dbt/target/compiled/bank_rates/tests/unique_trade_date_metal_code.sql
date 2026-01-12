SELECT 
    trade_date,
    metal_code,
    COUNT(*) as count
FROM "bank_rates"."staging"."stg_cbr_precious_metals"
GROUP BY trade_date, metal_code
HAVING COUNT(*) > 1
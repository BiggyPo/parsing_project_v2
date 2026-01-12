

SELECT DISTINCT
    metal_code,
    metal_name
FROM "bank_rates"."staging"."stg_cbr_precious_metals"
WHERE metal_code IS NOT NULL
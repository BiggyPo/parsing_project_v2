select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      SELECT 
    trade_date,
    metal_code
FROM "bank_rates"."staging"."stg_cbr_precious_metals"
WHERE trade_date IS NULL 
   OR metal_code IS NULL 
   OR buy_price_rub IS NULL 
   OR sell_price_rub IS NULL
      
    ) dbt_internal_test
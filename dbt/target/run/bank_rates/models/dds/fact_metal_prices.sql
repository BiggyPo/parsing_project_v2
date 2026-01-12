
  
    

  create  table "bank_rates"."dds"."fact_metal_prices__dbt_tmp"
  
  
    as
  
  (
    

SELECT 
    ROW_NUMBER() OVER (ORDER BY trade_date, metal_code) as price_id,
    trade_date,
    metal_code,
    metal_name,
    buy_price_rub,
    sell_price_rub,
    loaded_at,
    CURRENT_TIMESTAMP as dwh_loaded_at
FROM "bank_rates"."staging"."stg_cbr_precious_metals"
WHERE trade_date IS NOT NULL
  AND metal_code IS NOT NULL
  );
  
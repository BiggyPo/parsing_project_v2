{{ config(
    materialized='table',
    schema='dds'
) }}

SELECT 
    ROW_NUMBER() OVER (ORDER BY trade_date, metal_code) as price_id,
    trade_date,
    metal_code,
    metal_name,
    buy_price_rub,
    sell_price_rub,
    loaded_at,
    CURRENT_TIMESTAMP as dwh_loaded_at
FROM {{ ref('stg_cbr_precious_metals') }}
WHERE trade_date IS NOT NULL
  AND metal_code IS NOT NULL

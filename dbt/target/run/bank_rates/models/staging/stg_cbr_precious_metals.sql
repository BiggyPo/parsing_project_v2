
  create view "bank_rates"."staging"."stg_cbr_precious_metals__dbt_tmp"
    
    
  as (
    

WITH ranked_data AS (
    SELECT 
        id,
        record_date::DATE as trade_date,
        metal_code::INTEGER as metal_code,
        buy_price::DECIMAL(10,2) as buy_price_rub,
        sell_price::DECIMAL(10,2) as sell_price_rub,
        from_date::DATE as valid_from,
        to_date::DATE as valid_to,
        load_timestamp::TIMESTAMP as loaded_at,
        -- Выбираем последнюю загрузку для каждого дня и металла
        ROW_NUMBER() OVER (
            PARTITION BY record_date, metal_code 
            ORDER BY load_timestamp DESC
        ) as rn
    FROM raw.cbr_precious_metals
    WHERE record_date IS NOT NULL
      AND metal_code IS NOT NULL
      AND buy_price IS NOT NULL
)
SELECT 
    trade_date,
    metal_code,
    CASE 
        WHEN metal_code = 1 THEN 'Золото'
        WHEN metal_code = 2 THEN 'Серебро'
        WHEN metal_code = 3 THEN 'Платина'
        WHEN metal_code = 4 THEN 'Палладий'
        ELSE 'Неизвестный металл'
    END as metal_name,
    buy_price_rub,
    sell_price_rub,
    valid_from,
    valid_to,
    loaded_at
FROM ranked_data
WHERE rn = 1
  );
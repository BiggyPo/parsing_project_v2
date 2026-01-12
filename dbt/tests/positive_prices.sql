SELECT 
    trade_date,
    metal_code,
    buy_price_rub,
    sell_price_rub
FROM {{ ref('stg_cbr_precious_metals') }}
WHERE buy_price_rub <= 0 OR sell_price_rub <= 0

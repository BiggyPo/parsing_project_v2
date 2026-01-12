-- История цен за последние 30 дней
SELECT 
    trade_date as "Дата",
    metal_name as "Металл",
    ROUND(avg_price_rub, 2) as "Средняя цена, руб/г",
    ROUND(buy_price_change_percent, 2) as "Изменение цены, %"
FROM mart.metal_prices_analytics 
WHERE trade_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY trade_date DESC, metal_name;

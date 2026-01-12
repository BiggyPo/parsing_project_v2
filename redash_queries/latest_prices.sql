-- Последние цены по всем металлам
SELECT 
    metal_name as "Металл",
    TO_CHAR(trade_date, 'DD.MM.YYYY') as "Дата",
    ROUND(buy_price_rub, 2) as "Цена покупки, руб/г",
    ROUND(sell_price_rub, 2) as "Цена продажи, руб/г",
    ROUND(avg_price_rub, 2) as "Средняя цена, руб/г",
    ROUND(buy_price_change_percent, 2) as "Изменение покупки, %",
    ROUND(sell_price_change_percent, 2) as "Изменение продажи, %"
FROM mart.metal_prices_analytics 
WHERE trade_date = (SELECT MAX(trade_date) FROM mart.metal_prices_analytics)
ORDER BY metal_name;

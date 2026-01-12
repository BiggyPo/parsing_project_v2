
  
    

  create  table "bank_rates"."mart"."metal_prices_analytics__dbt_tmp"
  
  
    as
  
  (
    

SELECT 
    f.trade_date,
    f.metal_name,
    f.buy_price_rub,
    f.sell_price_rub,
    ROUND((f.buy_price_rub + f.sell_price_rub) / 2, 2) as avg_price_rub,
    LAG(f.buy_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) as prev_buy_price,
    LAG(f.sell_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) as prev_sell_price,
    CASE 
        WHEN LAG(f.buy_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) IS NOT NULL 
        THEN ROUND((f.buy_price_rub - LAG(f.buy_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date)) / 
                   LAG(f.buy_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) * 100, 2)
        ELSE NULL 
    END as buy_price_change_percent,
    CASE 
        WHEN LAG(f.sell_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) IS NOT NULL 
        THEN ROUND((f.sell_price_rub - LAG(f.sell_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date)) / 
                   LAG(f.sell_price_rub) OVER (PARTITION BY f.metal_name ORDER BY f.trade_date) * 100, 2)
        ELSE NULL 
    END as sell_price_change_percent
FROM "bank_rates"."dds"."fact_metal_prices" f
ORDER BY f.trade_date DESC, f.metal_name
  );
  
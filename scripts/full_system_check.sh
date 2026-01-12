#!/bin/bash

echo "=========================================="
echo "ПОЛНАЯ ПРОВЕРКА СИСТЕМЫ МОНИТОРИНГА МЕТАЛЛОВ"
echo "Время: $(date)"
echo "=========================================="

echo ""
echo "1. СТАТУС КОНТЕЙНЕРОВ DOCKER:"
echo "------------------------------------------"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(postgres|airflow|dbt|redash|nifi)"

echo ""
echo "2. ПРОВЕРКА БАЗЫ ДАННЫХ:"
echo "------------------------------------------"
echo "Схемы и таблицы:"
sudo docker exec postgres_bank psql -U admin -d bank_rates -c "
SELECT 
    schemaname,
    tablename,
    (xpath('/row/c/text()', query_to_xml(format('SELECT COUNT(*) as c FROM %I.%I', schemaname, tablename), false, true, '')))[1]::text::int as row_count
FROM pg_tables 
WHERE schemaname IN ('raw', 'staging', 'dds', 'mart')
ORDER BY schemaname, tablename;" 2>/dev/null || echo "Ошибка подключения к базе"

echo ""
echo "3. ПРОВЕРКА AIRFLOW DAG:"
echo "------------------------------------------"
AIRFLOW_CONTAINER=$(docker ps --filter "name=airflow-webserver" --format "{{.Names}}" | head -1)
if [ ! -z "$AIRFLOW_CONTAINER" ]; then
    echo "DAG статус:"
    sudo docker exec $AIRFLOW_CONTAINER airflow dags list | grep cbr_metals 2>/dev/null || echo "Не удалось получить статус DAG"
else
    echo "Airflow не запущен"
fi

echo ""
echo "4. ПРОВЕРКА ДАННЫХ ЗА ПОСЛЕДНИЕ 7 ДНЕЙ:"
echo "------------------------------------------"
sudo docker exec postgres_bank psql -U admin -d bank_rates -c "
SELECT 
    trade_date,
    COUNT(*) as metals_count,
    MIN(buy_price_rub) as min_price,
    MAX(buy_price_rub) as max_price,
    ROUND(AVG(buy_price_change_percent), 2) as avg_daily_change_percent
FROM mart.metal_prices_analytics 
WHERE trade_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY trade_date
ORDER BY trade_date DESC;" 2>/dev/null || echo "Ошибка получения данных"

echo ""
echo "5. ПРОВЕРКА REDASH:"
echo "------------------------------------------"
if curl -s http://localhost:5000 > /dev/null; then
    echo "✓ Redash доступен по адресу: http://localhost:5000"
    echo "  Логин: admin@example.com"
    echo "  Пароль: password"
else
    echo "✗ Redash недоступен"
fi

echo ""
echo "6. ПРОВЕРКА NiFi:"
echo "------------------------------------------"
if curl -s http://localhost:8080 > /dev/null; then
    echo "✓ NiFi доступен по адресу: http://localhost:8080"
else
    echo "✗ NiFi недоступен"
fi

echo ""
echo "7. РЕКОМЕНДАЦИИ:"
echo "------------------------------------------"
echo "1. Проверьте Redash: http://localhost:5000"
echo "2. Проверьте Airflow: http://localhost:8081"
echo "3. Проверьте NiFi: http://localhost:8080"
echo "4. Для просмотра логов используйте: docker logs <имя_контейнера>"
echo ""
echo "=========================================="
echo "ПРОВЕРКА ЗАВЕРШЕНА"
echo "=========================================="

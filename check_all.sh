#!/bin/bash
echo "=== 1. Docker контейнеры ==="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

echo -e "\n=== 2. Docker сети ==="
docker network ls
docker network inspect dwh-network 2>/dev/null | grep -A20 "Containers"

echo -e "\n=== 3. Базы PostgreSQL ==="
docker exec postgres psql -U admin -d bank_rates -c "\l" 2>/dev/null || echo "Не могу подключиться к PostgreSQL"

echo -e "\n=== 4. Логи Airflow ==="
docker logs airflow_scheduler --tail 20 2>/dev/null | grep -i "error\|dag\|postgres" | head -10

echo -e "\n=== 5. Логи Redash ==="
docker logs redash --tail 20 2>/dev/null | grep -i "error\|database\|postgres" | head -10

echo -e "\n=== 6. Конфигурация .env ==="
grep -E "POSTGRES_|AIRFLOW__DATABASE|REDASH_DATABASE" .env 2>/dev/null || echo "Файл .env не найден"

echo -e "\n=== 7. Доступность сервисов ==="
echo "Airflow: http://localhost:8081"
echo "Redash: http://localhost:5000"
echo "Nifi: http://localhost:8080"

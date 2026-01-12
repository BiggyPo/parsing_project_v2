#!/bin/bash
BACKUP_ROOT="/home/biggypo/bank_rates_monitoring/backups"
DATE=$(date +%Y%m%d_%H%M)

echo "[$DATE] Starting backup..."

# 1. Backup NiFi
mkdir -p $BACKUP_ROOT/nifi/$DATE
docker cp nifi:/opt/nifi/nifi-current/conf/flow.json.gz $BACKUP_ROOT/nifi/$DATE/

# 2. Backup PostgreSQL
docker exec postgres_bank pg_dump -U admin -d bank_rates --format=custom --file=/tmp/db.dump
docker cp postgres_bank:/tmp/db.dump $BACKUP_ROOT/postgres/db_$DATE.dump

# 3. Backup важных конфигов
cp /home/biggypo/bank_rates_monitoring/.env $BACKUP_ROOT/
cp /home/biggypo/bank_rates_monitoring/docker-compose.yml $BACKUP_ROOT/

# 4. Очистка старых бэкапов (храним 7 дней)
find $BACKUP_ROOT/nifi/ -type d -mtime +7 -exec rm -rf {} \;
find $BACKUP_ROOT/postgres/ -name "*.dump" -mtime +7 -delete;

echo "[$DATE] Backup completed to $BACKUP_ROOT"

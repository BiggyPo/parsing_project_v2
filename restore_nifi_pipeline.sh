#!/bin/bash
# Скрипт восстановления NiFi пайплайна через API

NIFI_URL="http://localhost:8080/nifi-api"
ROOT_GROUP_ID=$(curl -s -X GET "${NIFI_URL}/flow/process-groups/root" | jq -r '.processGroupFlow.id')

echo "Root Group ID: $ROOT_GROUP_ID"

# Создаем процессоры
echo "Создаем процессоры..."

# 1. GenerateFlowFile
GENERATE_ID=$(curl -s -X POST "${NIFI_URL}/process-groups/${ROOT_GROUP_ID}/processors" \
  -H "Content-Type: application/json" \
  -d '{
    "revision": {"version": 0},
    "component": {
      "type": "org.apache.nifi.processors.standard.GenerateFlowFile",
      "name": "Запуск по расписанию",
      "position": {"x": 100, "y": 100},
      "config": {
        "properties": {
          "Scheduling Strategy": "CRON_DRIVEN",
          "Run Schedule": "0 0 12 * * ?",
          "Batch Size": "1"
        },
        "schedulingPeriod": "0 sec",
        "schedulingStrategy": "CRON_DRIVEN",
        "concurrentlySchedulableTaskCount": 1
      }
    }
  }' | jq -r '.id')

# 2. UpdateAttribute для дат
UPDATE_DATE_ID=$(curl -s -X POST "${NIFI_URL}/process-groups/${ROOT_GROUP_ID}/processors" \
  -H "Content-Type: application/json" \
  -d '{
    "revision": {"version": 0},
    "component": {
      "type": "org.apache.nifi.processors.attributes.UpdateAttribute",
      "name": "Формируем даты",
      "position": {"x": 300, "y": 100},
      "config": {
        "properties": {
          "date_req1": "${now():format('\''dd.MM.yyyy'\'')}",
          "date_req2": "${now():format('\''dd.MM.yyyy'\'')}"
        },
        "concurrentlySchedulableTaskCount": 1
      }
    }
  }' | jq -r '.id')

echo "Processors created:"
echo "GenerateFlowFile: $GENERATE_ID"
echo "UpdateAttribute: $UPDATE_DATE_ID"

echo "Для завершения настройки откройте NiFi UI: http://localhost:8080/nifi"
echo "И создайте остальные процессоры вручную"

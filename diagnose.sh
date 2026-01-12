#!/bin/bash
echo "=== Docker Containers ==="
docker ps -a

echo -e "\n=== Docker Networks ==="
docker network ls

echo -e "\n=== Docker Compose Files ==="
find . -name "docker-compose*" -exec echo "File: {}" \; -exec cat {} \;

echo -e "\n=== Airflow Logs (last 50 lines) ==="
docker logs airflow-scheduler --tail 50 2>/dev/null

echo -e "\n=== DBT Profiles ==="
find . -name "profiles.yml" -o -name "dbt_project.yml" | xargs -I {} sh -c 'echo "File: {}"; cat {}'

echo -e "\n=== Project Structure ==="
ls -la

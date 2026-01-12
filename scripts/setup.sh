#!/bin/bash

echo "Настройка проекта мониторинга банковских ставок..."

# 1. Обновление системы
echo "1. Обновление системы..."
sudo apt-get update
sudo apt-get upgrade -y

# 2. Установка Docker
echo "2. Установка Docker..."
if ! command -v docker &> /dev/null; then
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
else
    echo "Docker уже установлен"
fi

# 3. Установка Docker Compose
echo "3. Установка Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose уже установлен"
fi

# 4. Настройка firewall
echo "4. Настройка firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 8080/tcp  # NiFi
sudo ufw allow 8081/tcp  # Airflow
sudo ufw allow 5000/tcp  # Redash
sudo ufw allow 5432/tcp  # PostgreSQL
sudo ufw --force enable

# 5. Запуск проекта
echo "5. Запуск Docker Compose..."
cd ~/bank_rates_monitoring
docker-compose down
docker-compose build
docker-compose up -d

# 6. Проверка статуса
echo "6. Проверка статуса контейнеров..."
sleep 10
docker-compose ps

echo "Установка завершена!"
echo ""
echo "Доступ к сервисам:"
echo "- NiFi: http://$(curl -s ifconfig.me):8080/nifi"
echo "- Airflow: http://$(curl -s ifconfig.me):8081 (admin/admin)"
echo "- Redash: http://$(curl -s ifconfig.me):5000"
echo ""
echo "Для остановки проекта выполните: docker-compose down"
echo "Для перезапуска: docker-compose restart"
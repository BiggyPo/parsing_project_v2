FROM python:3.10-slim

WORKDIR /usr/app

# Установка системных зависимостей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Установка dbt и зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копирование проекта dbt
COPY . .

CMD ["sleep", "infinity"]
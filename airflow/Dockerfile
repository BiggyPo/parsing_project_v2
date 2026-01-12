FROM apache/airflow:2.7.3

USER root

# Установка системных зависимостей, включая Docker CLI
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        curl \
        git \
        ca-certificates \
        gnupg \
        lsb-release \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Установка Python зависимостей для Airflow
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        apache-airflow-providers-postgres \
        apache-airflow-providers-http \
        psycopg2-binary \
        pandas
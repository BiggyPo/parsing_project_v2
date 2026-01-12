-- Создание основных баз данных
CREATE DATABASE airflow;
CREATE DATABASE redash;

-- Создание схем в основной базе
\c bank_rates;

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS raw;

-- Таблица для сырых данных из NiFi
CREATE TABLE staging.stg_bank_deposit_rates (
    id SERIAL PRIMARY KEY,
    bank_name VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    rate DECIMAL(5,2) NOT NULL,
    min_amount DECIMAL(15,2) DEFAULT 0,
    term_months INTEGER NOT NULL,
    scraped_date DATE DEFAULT CURRENT_DATE,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_rate CHECK (rate > 0 AND rate < 100),
    CONSTRAINT valid_term CHECK (term_months > 0)
);

-- Индексы для производительности
CREATE INDEX idx_stg_bank ON staging.stg_bank_deposit_rates(bank_name);
CREATE INDEX idx_stg_date ON staging.stg_bank_deposit_rates(scraped_date);

-- Тестовые данные
CREATE TABLE staging.test_rates (
    id SERIAL PRIMARY KEY,
    bank_name VARCHAR(255),
    product_name VARCHAR(255),
    rate DECIMAL(5,2),
    min_amount DECIMAL(15,2),
    term_months INTEGER,
    effective_date DATE
);

-- Вставка тестовых данных
INSERT INTO staging.test_rates (bank_name, product_name, rate, min_amount, term_months, effective_date) VALUES
('Сбербанк', 'Сохраняй', 5.5, 1000, 12, CURRENT_DATE),
('ВТБ', 'Выгодный', 6.2, 50000, 6, CURRENT_DATE),
('Тинькофф', 'Инвест', 7.1, 50000, 12, CURRENT_DATE),
('Альфа-Банк', 'Премьер', 6.8, 10000, 9, CURRENT_DATE),
('Открытие', 'Надежный', 6.0, 5000, 3, CURRENT_DATE),
('Газпромбанк', 'Стандарт', 5.9, 10000, 12, CURRENT_DATE),
('Россельхозбанк', 'Агро', 6.5, 20000, 6, CURRENT_DATE),
('Совкомбанк', 'Максимальный', 8.2, 1000, 12, CURRENT_DATE),
('Райффайзенбанк', 'Оптимальный', 5.7, 30000, 9, CURRENT_DATE),
('МКБ', 'Инвестиционный', 7.5, 50000, 12, CURRENT_DATE);

-- Создание пользователя для мониторинга
CREATE USER monitor WITH PASSWORD 'monitor_pass';
GRANT CONNECT ON DATABASE bank_rates TO monitor;
GRANT USAGE ON SCHEMA staging TO monitor;
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO monitor;
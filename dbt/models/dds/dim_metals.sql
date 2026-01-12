{{ config(
    materialized='table',
    schema='dds'
) }}

SELECT DISTINCT
    metal_code,
    metal_name
FROM {{ ref('stg_cbr_precious_metals') }}
WHERE metal_code IS NOT NULL

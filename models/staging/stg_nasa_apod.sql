-- Modelo de staging: limpieza básica de datos crudos de NASA APOD
-- Renombra columnas, castea tipos y selecciona campos relevantes

WITH source AS (
    SELECT * FROM {{ source('raw', 'nasa_apod') }}
),

renamed AS (
    SELECT
        date                        AS apod_date,
        title                       AS apod_title,
        explanation                 AS apod_explanation,
        url                         AS media_url,
        hdurl                       AS media_url_hd,
        media_type,
        copyright,
        _airbyte_extracted_at       AS loaded_at
    FROM source
)

SELECT * FROM renamed

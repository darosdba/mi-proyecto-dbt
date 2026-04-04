-- Modelo de staging: limpieza básica de datos de REST Countries API
-- Extrae campos escalares del JSON y renombra columnas

WITH source AS (
    SELECT * FROM {{ source('raw', 'paises') }}
),

renamed AS (
    SELECT
        cca3                                AS codigo_pais,
        name->>'common'                     AS nombre_comun,
        name->>'official'                   AS nombre_oficial,
        region,
        subregion,
        population,
        -- La capital es un array JSON, extraemos el primer elemento
        capital->0                          AS capital,
        -- URL de la bandera en PNG
        flags->>'png'                       AS flag_url,
        flags->>'alt'                       AS flag_descripcion,
        _airbyte_extracted_at               AS loaded_at
    FROM source
)

SELECT * FROM renamed

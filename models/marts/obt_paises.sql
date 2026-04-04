{{
    config(
        materialized='table'
    )
}}

-- Mart: One Big Table de países para análisis final
-- Consolida atributos geográficos, demográficos y clasificaciones

WITH paises AS (
    SELECT * FROM {{ ref('int_paises_enriched') }}
),

final AS (
    SELECT
        codigo_pais,
        nombre_comun,
        nombre_oficial,
        region,
        region_es,
        subregion,
        capital,
        population,
        categoria_poblacion,
        flag_url,
        flag_descripcion,
        loaded_at
    FROM paises
)

SELECT * FROM final
ORDER BY region_es, nombre_comun

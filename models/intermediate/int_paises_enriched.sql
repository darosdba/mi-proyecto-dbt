-- Modelo intermedio: enriquece los datos de países con clasificaciones
-- y extrae el idioma principal desde el objeto JSON de languages

WITH paises AS (
    SELECT * FROM {{ ref('stg_paises') }}
),

enriched AS (
    SELECT
        codigo_pais,
        nombre_comun,
        nombre_oficial,
        region,
        subregion,
        population,
        capital,
        flag_url,
        flag_descripcion,

        -- Clasificación por población
        CASE
            WHEN population >= 100000000 THEN 'Muy grande (>100M)'
            WHEN population >= 10000000  THEN 'Grande (10M-100M)'
            WHEN population >= 1000000   THEN 'Mediano (1M-10M)'
            WHEN population >= 100000    THEN 'Pequeño (100K-1M)'
            ELSE 'Micro (<100K)'
        END                             AS categoria_poblacion,

        -- Clasificación por región simplificada
        CASE
            WHEN region = 'Americas' AND subregion LIKE '%South%'    THEN 'Sudamérica'
            WHEN region = 'Americas' AND subregion LIKE '%North%'    THEN 'Norteamérica'
            WHEN region = 'Americas' AND subregion LIKE '%Central%'  THEN 'Centroamérica'
            WHEN region = 'Americas' AND subregion LIKE '%Carib%'    THEN 'Caribe'
            WHEN region = 'Europe'                                   THEN 'Europa'
            WHEN region = 'Africa'                                   THEN 'África'
            WHEN region = 'Asia'                                     THEN 'Asia'
            WHEN region = 'Oceania'                                  THEN 'Oceanía'
            ELSE region
        END                             AS region_es,

        loaded_at

    FROM paises
)

SELECT * FROM enriched

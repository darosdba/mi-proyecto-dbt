-- Singular Test: test_nasa_apod_media_url_no_vacia
--
-- Objetivo: Verificar que ningún registro de NASA APOD tenga una URL de medio
-- vacía (string vacío '') o nula. Un registro sin URL es inutilizable para
-- cualquier análisis o visualización.
--
-- Este test va más allá del not_null genérico: también detecta strings vacíos
-- que pasarían el test not_null pero igualmente serían datos inválidos.
--
-- Un test singular falla si esta query retorna 1 o más filas.

SELECT
    apod_date,
    apod_title,
    media_url
FROM {{ ref('stg_nasa_apod') }}
WHERE media_url IS NULL
   OR TRIM(media_url) = ''

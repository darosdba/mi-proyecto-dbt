-- Singular Test: test_paises_poblacion_no_negativa
--
-- Objetivo: Verificar que ningún país tenga un valor de población negativo.
-- La población siempre debe ser >= 0. Un valor negativo indicaría un error
-- de extracción o carga en la fuente de datos.
--
-- Un test singular falla si esta query retorna 1 o más filas.

SELECT
    codigo_pais,
    nombre_comun,
    population
FROM {{ ref('stg_paises') }}
WHERE population < 0

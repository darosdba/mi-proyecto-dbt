# mi_proyecto_dbt

Proyecto dbt para la Tarea Práctica - Clase 5  
Maestría en Inteligencia Artificial - Introducción a la Ingeniería de Datos  
Alumno: Celso David Cabañas Rolón

---

## Descripción

Pipeline de transformación de datos (la **T** en ELT) utilizando dbt sobre MotherDuck (DuckDB en la nube).  
Los datos crudos fueron cargados previamente con Airbyte desde tres fuentes:

| Source | Tipo | Tabla en MotherDuck |
|--------|------|---------------------|
| PokeAPI | API pública | `main.pokemon` |
| NASA APOD | API con API Key | `main.nasa_apod` |
| REST Countries API | Conector custom (Airbyte Builder) | `main.paises` |

---

## Estructura del Proyecto

```
mi_proyecto_dbt/
├── dbt_project.yml
├── profiles.yml          # en ~/.dbt/profiles.yml
├── models/
│   ├── staging/
│   │   ├── _sources.yml          # Definición de sources crudos
│   │   ├── stg_pokemon.sql       # Staging PokeAPI
│   │   ├── stg_nasa_apod.sql     # Staging NASA APOD
│   │   └── stg_paises.sql        # Staging REST Countries API
│   ├── intermediate/
│   │   ├── int_pokemon_with_types.sql   # Extracción de tipos JSON
│   │   └── int_paises_enriched.sql      # Clasificaciones de países
│   └── marts/
│       ├── obt_pokemon.sql        # OBT Pokemon para análisis
│       └── obt_paises.sql         # OBT Países para análisis geográfico
└── README.md
```

---

## Capas y Materializaciones

| Capa | Materialización | Justificación |
|------|----------------|---------------|
| staging | `view` | Datos crudos, se consultan poco directamente. View evita duplicar storage |
| intermediate | `view` | Transformaciones auxiliares, base para los marts |
| marts | `table` | Se consultan frecuentemente desde dashboards; table mejora performance |

---

## Configuración

### Requisito previo: variable de entorno

```bash
# Mac/Linux
export MOTHERDUCK_TOKEN="tu_token_aqui"

# Windows PowerShell
$env:MOTHERDUCK_TOKEN="tu_token_aqui"
```

### profiles.yml (`~/.dbt/profiles.yml`)

```yaml
mi_proyecto_dbt:
  outputs:
    dev:
      type: duckdb
      path: "md:airbyte_curso"
      extensions:
        - motherduck
      motherduck_token: "{{ env_var('MOTHERDUCK_TOKEN') }}"
  target: dev
```

---

## Cómo se configuró REST Countries API en Airbyte

Se utilizó el **Airbyte Connector Builder** para crear un conector custom:
- URL base: `https://restcountries.com/v3.1/all`
- Parámetros: `fields=name,cca3,region,subregion,languages,capital,population,flags`
- Stream name: `paises` — Primary key: `cca3`
- Connection hacia motherduck-destination con sync Manual, namespace `main`

---

## Comandos

```bash
# Verificar conexión
dbt debug

# Ejecutar todos los modelos
dbt run

# Ejecutar solo staging
dbt run --select staging.*

# Ejecutar un modelo y sus dependencias upstream
dbt run --select +obt_pokemon

# Generar y ver documentación con DAG
dbt docs generate
dbt docs serve
```

---

## Decisiones de Diseño

**¿Por qué OBT y no modelo dimensional?**  
Dado que los datasets son relativamente pequeños (un Pokemon, imágenes APOD, ventas de una empresa), se optó por One Big Table para simplificar las consultas finales. Un modelo estrella (fact + dims) sería preferible a mayor escala.

**¿Cómo se manejan los JSON anidados de PokeAPI y REST Countries?**  
Ambas APIs devuelven estructuras JSON anidadas. En `int_pokemon_with_types.sql` se usan los operadores `->` y `->>` de DuckDB para extraer tipos primario y secundario del array `types`. En `stg_paises.sql` se aplica la misma técnica para extraer `name->>'common'`, `capital->0`, y los campos de `flags`.

**¿Por qué incremental para NASA APOD?**  
La NASA publica una imagen por día. Usar `Incremental | Append Deduped` con `date` como cursor y primary key evita recargar el historial completo en cada sync.

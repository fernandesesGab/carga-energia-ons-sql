-- Índice de sazonalidade por dia da semana: carga média do dia / carga média geral (1,000 = média)
WITH base AS (
    SELECT
        id_subsistema,
        CAST(strftime('%w', data) AS INTEGER)               AS dow,
        carga_mwmed,
        AVG(carga_mwmed) OVER (PARTITION BY id_subsistema)  AS media_geral
    FROM carga_diaria
    WHERE data >= '2025-01-01'   -- janela recente, para não misturar com o crescimento de longo prazo
)
SELECT
    CASE dow WHEN 0 THEN '0 Domingo' WHEN 1 THEN '1 Segunda' WHEN 2 THEN '2 Terça'
             WHEN 3 THEN '3 Quarta'  WHEN 4 THEN '4 Quinta'  WHEN 5 THEN '5 Sexta'
             ELSE '6 Sábado' END                                                      AS dia_semana,
    ROUND(AVG(CASE WHEN id_subsistema = 'SE' THEN carga_mwmed / media_geral END), 3)  AS sudeste_co,
    ROUND(AVG(CASE WHEN id_subsistema = 'S'  THEN carga_mwmed / media_geral END), 3)  AS sul,
    ROUND(AVG(CASE WHEN id_subsistema = 'NE' THEN carga_mwmed / media_geral END), 3)  AS nordeste,
    ROUND(AVG(CASE WHEN id_subsistema = 'N'  THEN carga_mwmed / media_geral END), 3)  AS norte
FROM base
GROUP BY dow
ORDER BY dow;

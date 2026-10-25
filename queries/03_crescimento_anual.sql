-- Carga média anual por subsistema e crescimento em relação ao ano anterior (LAG)
-- O ano corrente é comparado com o mesmo período do ano anterior (acumulado até a última data disponível)
WITH ultimo AS (
    SELECT MAX(data) AS data_max FROM carga_diaria
),
anual AS (
    SELECT
        c.id_subsistema,
        strftime('%Y', c.data)                                                  AS ano,
        AVG(c.carga_mwmed)                                                      AS media_ano,
        AVG(CASE WHEN strftime('%m-%d', c.data) <= strftime('%m-%d', u.data_max)
                 THEN c.carga_mwmed END)                                        AS media_ytd
    FROM carga_diaria AS c
    CROSS JOIN ultimo AS u
    GROUP BY c.id_subsistema, ano
),
comparativo AS (
    SELECT
        a.*,
        a.ano = strftime('%Y', u.data_max)             AS ano_corrente,
        strftime('%d/%m', u.data_max)                  AS ate,
        LAG(a.media_ano) OVER w                        AS media_ano_anterior,
        LAG(a.media_ytd) OVER w                        AS media_ytd_anterior
    FROM anual AS a
    CROSS JOIN ultimo AS u
    WINDOW w AS (PARTITION BY a.id_subsistema ORDER BY a.ano)
)
SELECT
    id_subsistema,
    ano,
    CASE WHEN ano_corrente THEN 'acumulado até ' || ate ELSE 'ano completo' END   AS periodo,
    ROUND(CASE WHEN ano_corrente THEN media_ytd ELSE media_ano END, 0)              AS carga_media_mwmed,
    ROUND(100.0 * (CASE WHEN ano_corrente THEN media_ytd / media_ytd_anterior
                        ELSE media_ano / media_ano_anterior END - 1), 1)           AS crescimento_pct
FROM comparativo
ORDER BY id_subsistema, ano;

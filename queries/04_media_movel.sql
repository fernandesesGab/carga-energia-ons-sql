-- Carga diária do SIN nos últimos 60 dias, com médias móveis de 7 e 30 dias (funções de janela)
WITH sin AS (
    SELECT data, SUM(carga_mwmed) AS carga_sin
    FROM carga_diaria
    GROUP BY data
),
movel AS (
    SELECT
        data,
        carga_sin,
        AVG(carga_sin) OVER (ORDER BY data ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)  AS mm7,
        AVG(carga_sin) OVER (ORDER BY data ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS mm30
    FROM sin
)
SELECT
    data,
    ROUND(carga_sin, 0)                      AS carga_sin_mwmed,
    ROUND(mm7, 0)                            AS media_movel_7d,
    ROUND(mm30, 0)                           AS media_movel_30d,
    ROUND(100.0 * (carga_sin / mm30 - 1), 1) AS desvio_vs_mm30_pct
FROM movel
WHERE data > date((SELECT MAX(data) FROM sin), '-60 days')
ORDER BY data;

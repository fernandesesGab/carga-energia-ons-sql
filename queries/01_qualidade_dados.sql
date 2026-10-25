-- Cobertura e qualidade da base: dias esperados x carregados, lacunas e valores inválidos por subsistema e ano
WITH RECURSIVE calendario (dia) AS (
    SELECT (SELECT MIN(data) FROM carga_diaria)
    UNION ALL
    SELECT date(dia, '+1 day') FROM calendario
    WHERE dia < (SELECT MAX(data) FROM carga_diaria)
),
esperado AS (
    SELECT s.id_subsistema, c.dia
    FROM calendario AS c
    CROSS JOIN subsistemas AS s
)
SELECT
    e.id_subsistema,
    strftime('%Y', e.dia)                                         AS ano,
    COUNT(*)                                                      AS dias_esperados,
    COUNT(c.data)                                                 AS dias_carregados,
    COUNT(*) - COUNT(c.data)                                      AS dias_faltantes,
    SUM(CASE WHEN c.data IS NOT NULL AND (c.carga_mwmed IS NULL OR c.carga_mwmed <= 0)
             THEN 1 ELSE 0 END)                                   AS valores_invalidos
FROM esperado AS e
LEFT JOIN carga_diaria AS c
       ON c.id_subsistema = e.id_subsistema
      AND c.data = e.dia
GROUP BY e.id_subsistema, ano
ORDER BY e.id_subsistema, ano;

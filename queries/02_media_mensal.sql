-- Carga média mensal (MWmed) por subsistema e total do SIN, em formato pivotado
SELECT
    strftime('%Y-%m', data)                                               AS mes,
    ROUND(AVG(CASE WHEN id_subsistema = 'SE' THEN carga_mwmed END), 0)   AS sudeste_co,
    ROUND(AVG(CASE WHEN id_subsistema = 'S'  THEN carga_mwmed END), 0)   AS sul,
    ROUND(AVG(CASE WHEN id_subsistema = 'NE' THEN carga_mwmed END), 0)   AS nordeste,
    ROUND(AVG(CASE WHEN id_subsistema = 'N'  THEN carga_mwmed END), 0)   AS norte,
    ROUND(SUM(carga_mwmed) / COUNT(DISTINCT data), 0)                     AS sin
FROM carga_diaria
GROUP BY mes
ORDER BY mes;

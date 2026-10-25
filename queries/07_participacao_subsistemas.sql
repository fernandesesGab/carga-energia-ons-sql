-- Participação (%) de cada subsistema na carga total do SIN, por ano
SELECT
    strftime('%Y', c.data)                                                         AS ano,
    s.nom_subsistema                                                               AS subsistema,
    ROUND(100.0 * SUM(c.carga_mwmed)
          / SUM(SUM(c.carga_mwmed)) OVER (PARTITION BY strftime('%Y', c.data)), 1)  AS participacao_pct
FROM carga_diaria AS c
JOIN subsistemas AS s ON s.id_subsistema = c.id_subsistema
GROUP BY ano, s.nom_subsistema
ORDER BY ano, participacao_pct DESC;

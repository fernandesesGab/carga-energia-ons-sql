-- Os 3 dias de maior carga de cada subsistema (ROW_NUMBER por partição)
WITH ranking AS (
    SELECT
        s.nom_subsistema,
        c.data,
        c.carga_mwmed,
        ROW_NUMBER() OVER (PARTITION BY c.id_subsistema ORDER BY c.carga_mwmed DESC) AS posicao
    FROM carga_diaria AS c
    JOIN subsistemas AS s ON s.id_subsistema = c.id_subsistema
)
SELECT nom_subsistema AS subsistema, posicao, data, ROUND(carga_mwmed, 0) AS carga_mwmed
FROM ranking
WHERE posicao <= 3
ORDER BY subsistema, posicao;

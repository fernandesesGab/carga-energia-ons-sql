-- Dias atípicos: carga a mais de 3 desvios-padrão da média dos 28 dias anteriores (z-score)
-- Útil para tratar a série antes de treinar modelos de previsão (feriados, eventos, falhas de medição)
WITH estatisticas AS (
    SELECT
        id_subsistema,
        data,
        carga_mwmed,
        AVG(carga_mwmed) OVER w                                                   AS media_28d,
        AVG(carga_mwmed * carga_mwmed) OVER w - POWER(AVG(carga_mwmed) OVER w, 2) AS variancia_28d,
        COUNT(*) OVER w                                                           AS n
    FROM carga_diaria
    WINDOW w AS (PARTITION BY id_subsistema ORDER BY data ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING)
),
z AS (
    SELECT *, (carga_mwmed - media_28d) / SQRT(variancia_28d) AS z_score
    FROM estatisticas
    WHERE n = 28 AND variancia_28d > 0
)
SELECT
    id_subsistema,
    data,
    CASE CAST(strftime('%w', data) AS INTEGER) WHEN 0 THEN 'Dom' WHEN 1 THEN 'Seg' WHEN 2 THEN 'Ter'
         WHEN 3 THEN 'Qua' WHEN 4 THEN 'Qui' WHEN 5 THEN 'Sex' ELSE 'Sáb' END  AS dia_semana,
    ROUND(carga_mwmed, 0)  AS carga_mwmed,
    ROUND(media_28d, 0)    AS media_28d,
    ROUND(z_score, 2)      AS z_score
FROM z
WHERE ABS(z_score) > 3
ORDER BY data, id_subsistema;

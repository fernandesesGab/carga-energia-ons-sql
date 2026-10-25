-- Carga de energia diária por subsistema do SIN (dados abertos do ONS) - SQLite

DROP TABLE IF EXISTS carga_diaria;
DROP TABLE IF EXISTS subsistemas;

CREATE TABLE subsistemas (
    id_subsistema   TEXT PRIMARY KEY,   -- N, NE, S, SE
    nom_subsistema  TEXT NOT NULL
);

CREATE TABLE carga_diaria (
    id_subsistema  TEXT NOT NULL REFERENCES subsistemas (id_subsistema),
    data           TEXT NOT NULL,       -- ISO 8601 (YYYY-MM-DD)
    carga_mwmed    REAL,                -- carga média do dia em MWmed
    PRIMARY KEY (id_subsistema, data)
);

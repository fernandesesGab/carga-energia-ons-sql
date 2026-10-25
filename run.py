"""Cria o banco SQLite a partir dos CSVs do ONS e executa todas as consultas de queries/.

Cada consulta gera uma tabela em Markdown em results/, para leitura direto no GitHub.

Uso: python baixar_dados.py && python run.py
"""

import csv
import sqlite3
from pathlib import Path

RAIZ = Path(__file__).parent
BANCO = RAIZ / "energia.db"


def carregar(con: sqlite3.Connection) -> None:
    con.executescript((RAIZ / "schema.sql").read_text(encoding="utf-8"))
    subsistemas, linhas = {}, []
    for arquivo in sorted((RAIZ / "data").glob("CARGA_ENERGIA_*.csv")):
        with open(arquivo, encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter=";"):
                subsistemas[r["id_subsistema"]] = r["nom_subsistema"]
                valor = r["val_cargaenergiamwmed"].strip()
                linhas.append((r["id_subsistema"], r["din_instante"][:10], float(valor) if valor else None))
    con.executemany("INSERT INTO subsistemas VALUES (?, ?)", subsistemas.items())
    # INSERT OR REPLACE: se o ONS republicar um dia em dois arquivos, fica a versão mais recente
    con.executemany("INSERT OR REPLACE INTO carga_diaria VALUES (?, ?, ?)", linhas)
    con.commit()
    total = con.execute("SELECT COUNT(*), MIN(data), MAX(data) FROM carga_diaria").fetchone()
    print(f"  {len(linhas)} linhas lidas, {total[0]} gravadas ({total[1]} a {total[2]})")


def markdown(colunas: list[str], linhas: list[tuple]) -> str:
    def fmt(v):
        return "" if v is None else str(v)
    saida = ["| " + " | ".join(colunas) + " |", "|" + "---|" * len(colunas)]
    saida += ["| " + " | ".join(fmt(v) for v in linha) + " |" for linha in linhas]
    return "\n".join(saida) + "\n"


def main() -> None:
    BANCO.unlink(missing_ok=True)
    con = sqlite3.connect(BANCO)
    con.execute("PRAGMA foreign_keys = ON")
    print("Carregando dados:")
    carregar(con)

    (RAIZ / "results").mkdir(exist_ok=True)
    print("Executando consultas:")
    for consulta in sorted((RAIZ / "queries").glob("*.sql")):
        sql = consulta.read_text(encoding="utf-8")
        cursor = con.execute(sql)
        colunas = [c[0] for c in cursor.description]
        linhas = cursor.fetchall()
        titulo = sql.splitlines()[0].lstrip("- ").strip()
        destino = RAIZ / "results" / f"{consulta.stem}.md"
        destino.write_text(f"# {titulo}\n\nConsulta: [`queries/{consulta.name}`](../queries/{consulta.name})\n\n"
                           + markdown(colunas, linhas), encoding="utf-8")
        print(f"  {consulta.name}: {len(linhas)} linhas -> results/{destino.name}")
    con.close()


if __name__ == "__main__":
    main()

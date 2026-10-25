"""Baixa a carga de energia diária por subsistema do portal de dados abertos do ONS.

Fonte: https://dados.ons.org.br/dataset/carga-energia (licença CC-BY)

Uso: python baixar_dados.py [ano_inicial] [ano_final]   (padrão: 2021 até o ano atual)
"""

import sys
import urllib.request
from datetime import date
from pathlib import Path

URL = "https://ons-aws-prod-opendata.s3.amazonaws.com/dataset/carga_energia_di/CARGA_ENERGIA_{ano}.csv"
PASTA = Path(__file__).parent / "data"


def main() -> None:
    inicio = int(sys.argv[1]) if len(sys.argv) > 1 else 2021
    fim = int(sys.argv[2]) if len(sys.argv) > 2 else date.today().year
    PASTA.mkdir(exist_ok=True)
    for ano in range(inicio, fim + 1):
        destino = PASTA / f"CARGA_ENERGIA_{ano}.csv"
        urllib.request.urlretrieve(URL.format(ano=ano), destino)
        linhas = sum(1 for _ in open(destino, encoding="utf-8")) - 1
        print(f"{ano}: {linhas} registros -> {destino.name}")


if __name__ == "__main__":
    main()

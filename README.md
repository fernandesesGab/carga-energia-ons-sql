# Carga de Energia do SIN com SQL

Análise exploratória em SQL da **carga de energia diária** dos quatro subsistemas do Sistema Interligado Nacional (Sudeste/Centro-Oeste, Sul, Nordeste e Norte), de janeiro de 2021 a outubro de 2026, com **dados reais e abertos do ONS** (Operador Nacional do Sistema Elétrico).

O foco é preparar e entender uma série temporal antes de modelá-la: cobertura da base, tendência, sazonalidade semanal, picos e dias atípicos. É a etapa que antecede um modelo de previsão de carga (forecasting).

## O que o projeto mostra

- Ingestão de CSVs públicos em um modelo relacional com chave primária composta ([`schema.sql`](schema.sql))
- **CTE recursiva** para gerar o calendário esperado e encontrar dias faltantes (`LEFT JOIN` + `COUNT`)
- **Funções de janela**: `LAG()` para crescimento ano a ano, `AVG() OVER (ROWS BETWEEN ...)` para médias móveis, `ROW_NUMBER()` para ranking por grupo, `SUM() OVER` para participação percentual
- Cláusula `WINDOW` nomeada e **z-score em janela móvel** para detectar dias atípicos
- Pivotagem com `CASE WHEN` e comparação acumulada no ano (YTD) com o mesmo período do ano anterior

## Consultas

| # | Consulta | Pergunta | Resultado |
|---|----------|----------|-----------|
| 1 | [`01_qualidade_dados.sql`](queries/01_qualidade_dados.sql) | A base está completa? Há dias faltantes ou valores inválidos? | [ver](results/01_qualidade_dados.md) |
| 2 | [`02_media_mensal.sql`](queries/02_media_mensal.sql) | Qual a carga média mensal de cada subsistema e do SIN? | [ver](results/02_media_mensal.md) |
| 3 | [`03_crescimento_anual.sql`](queries/03_crescimento_anual.sql) | Quanto a carga cresceu ano a ano? | [ver](results/03_crescimento_anual.md) |
| 4 | [`04_media_movel.sql`](queries/04_media_movel.sql) | Como está a carga recente frente às médias móveis de 7 e 30 dias? | [ver](results/04_media_movel.md) |
| 5 | [`05_sazonalidade_semanal.sql`](queries/05_sazonalidade_semanal.sql) | Qual o efeito do dia da semana na carga? | [ver](results/05_sazonalidade_semanal.md) |
| 6 | [`06_picos_de_carga.sql`](queries/06_picos_de_carga.sql) | Quais foram os dias de maior carga de cada subsistema? | [ver](results/06_picos_de_carga.md) |
| 7 | [`07_participacao_subsistemas.sql`](queries/07_participacao_subsistemas.sql) | Quanto cada subsistema representa do total? | [ver](results/07_participacao_subsistemas.md) |
| 8 | [`08_dias_atipicos.sql`](queries/08_dias_atipicos.sql) | Quais dias fogem do padrão (\|z\| > 3)? | [ver](results/08_dias_atipicos.md) |

## Principais resultados

- **Base completa:** 8.484 registros diários, sem dias faltantes nem valores inválidos de 01/01/2021 a 22/10/2026.
- **Crescimento:** a carga média do SIN passou de cerca de 68,5 mil MWmed (2021) para 79,6 mil MWmed (2025), alta de **16%**. O maior salto foi em 2023-2024.
- **Mudança regional:** o **Norte** é o subsistema que mais cresce (+14,9% em 2023) e sua participação no SIN subiu de 8,7% para 10,8%. O Sudeste/Centro-Oeste ficou estável em 2025-2026 e perdeu participação (de 57,2% para 54,9%).
- **Sazonalidade semanal:** a carga de domingo fica de 6% a 18% abaixo da média, e o efeito é mais forte no Sul (índice 0,815). De terça a sexta a carga fica 2% a 6% acima da média.
- **Picos:** os recordes do Sudeste/Centro-Oeste e do Sul aconteceram no verão de 2025 (fevereiro, ondas de calor). Os do Nordeste e do Norte estão em setembro e outubro de 2026, reflexo do crescimento recente.
- **Dias atípicos:** 37 dias passam de 3 desvios-padrão, **todos quedas de carga**. São principalmente domingos e feriados: Natal, Ano-Novo, Dia do Trabalho, Sexta-feira Santa, domingo de Carnaval e, no Norte, 15/08 (Adesão do Pará). Num modelo de previsão, esses dias devem entrar como variáveis de calendário ou ser tratados antes do treino.

## Como executar

Requer apenas Python 3.10+ (o SQLite já vem embutido).

```bash
python baixar_dados.py   # baixa os CSVs do ONS para data/ (2021 até o ano atual)
python run.py            # cria energia.db, roda as consultas e grava results/*.md
```

## Estrutura

```
baixar_dados.py  download dos dados abertos do ONS
schema.sql       modelo relacional (subsistemas, carga_diaria)
queries/         uma consulta por pergunta de análise
run.py           carrega os CSVs no SQLite e executa as consultas
data/            CSVs originais do ONS
results/         resultado de cada consulta em Markdown
```

## Fonte dos dados

ONS, Dados Abertos: [Carga de Energia Diária](https://dados.ons.org.br/dataset/carga-energia), licença CC-BY. A carga é a média diária em MWmed por subsistema.

---
Autor: Gabriel Fernandes · [LinkedIn](https://www.linkedin.com/in/gabriel-fernandes-72b4341a5)

# 1) Utilizando pacote BatchGetSymbols, baixe os dados da ação MDIA3 no Yahoo Finance para os últimos 30 dias. 
#    Qual o preço ajustado mais baixo no período analisado? 
#    Qual a data com o preço mais baixo?

library(BatchGetSymbols)

my_ticker <- 'MDIA3.SA'
first_date <- Sys.Date() - 30
last_date <- Sys.Date()

df_prices <- BatchGetSymbols(tickers = my_ticker, 
                             first.date = first_date, 
                             last.date = last_date)[[2]]

idx <- which.min(df_prices$price.adjusted)
date_min_price <- df_prices$ref.date[idx]
date_min_price 

min_price <- df_prices$price.adjusted[idx]
min_price

# 2) Caso não o tenha feito, crie um perfil no site do Quandl e baixe dados sobre preços de café arábica no banco de dados do CEPEA 
#    (Centro de Estudos Avançados em Economia Aplicada) para o último mês.

library(Quandl)
library(tidyverse)

my_api <- 'Esv7Ac7zuZzJSCGxynyF'
Quandl.api_key(my_api)

my_series <- 'CEPEA/COFFEE_A'
first_date <- Sys.Date() - 30
last_date <- Sys.Date()

df_coffee <- Quandl(code = my_series, start_date = first_date)

glimpse(df_coffee)

p <- ggplot(df_coffee, aes(x = Date, y = `Cash Price US$`)) + 
  geom_line()

x11(); print(p)

# 3) Utilize pacote GetBCBData para baixar dados do IPCA nos últimos 5 anos. 
#    É possível observar algum período com deflação (inflação negativa) mensal?
library(GetBCBData)

my_code <- c('IPCA' = 433)
first_date <- Sys.Date() - 5*365
last_date <- Sys.Date()

df_ipca <- gbcbd_get_series(my_code, first_date, last_date)

glimpse(df_ipca)

idx <- df_ipca$value < 0
deflation_values <- df_ipca$value[idx]
print(deflation_values)

df_ipca$ref.date[idx]

# 4) Visite o site de sistema de séries temporais do Banco Central do Brasil e escolha uma série para análise de acordo com seus próprios interesses de pesquisa. 
#    Importe a mesma usando pacote GetBCBData.
library(GetBCBData)

my_code <- c('qtd ovos' = 1310)
first_date <- Sys.Date() - 15*365
last_date <- Sys.Date()

df_debt <- gbcbd_get_series(my_code, first_date, last_date)

glimpse(df_debt)

p <- ggplot(df_debt, aes(x = ref.date, y = value)) + 
  geom_line()

x11() ; print(p)

# 5) Utilizando função GetDFPData::gdfpd.get.info.companies, baixe informações sobre as ações negociadas na B3. Quantas empresas estão atualmente disponíveis no banco de dados? 
#   Qual a proporção de empresas ativas? Qual a empresa mais antiga? 
#    Quantas empresas existem para o setor de Utilidade Pública?
library(GetDFPData)

df_info <- gdfpd.get.info.companies(type.data = 'companies')

## numero empresas
length(unique(df_info$name.company))

## empresa mais antiga
idx <- which.min(df_info$date.registration)
df_info$name.company[idx]
df_info$date.registration[idx]

## qtd empresas utilidade pública
table(df_info$main.sector)['Utilidade Pública']

# 6) Com pacote GetDFPData, baixe os demostrativos financeiros mais recentes da Petrobras. 
#    Qual foi o seu lucro líquido no exercício? 
#    Qual foi o pagamento de proventos para o acionista (dividendo ou JSCP) mais recente?
library(GetDFPData)

my_company <- "PETRÓLEO BRASILEIRO  S.A.  - PETROBRAS"
first_date <- '2017-01-01'
last_date <- '2018-01-01'

df_reports <- gdfpd.GetDFPData(name.companies = my_company, 
                               first.date = first_date, 
                               last.date = last_date)

glimpse(df_reports)
## Lucro Líquido
df_dre <- df_reports$fr.income.consolidated[[1]]

idx <- df_dre$acc.number == '3.11'
value_profit <- df_dre$acc.value[idx]
value_profit

## pagamento proventos
df_div <- df_reports$history.dividends[[1]]

idx <- which.max(df_div$date.aproval)
df_div$value[idx]

df_div$date.aproval[idx]


# 7) Com base no pacote GetTDData, baixe dados para títulos do tipo LTN (Letras Financeiras do Tesouro). 
#    Entre todas LTNs, qual o título com maior data de vencimento?
library(GetTDData)

my_asset <- 'LTN'

download.TD.data(asset.codes = my_asset)

df_TD <- read.TD.files(asset.codes = my_asset)

glimpse(df_TD)

idx <- which.max(df_TD$matur.date)
df_TD$asset.code[idx]

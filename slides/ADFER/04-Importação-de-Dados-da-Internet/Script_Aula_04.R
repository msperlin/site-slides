# set symbol and dates
my_symbol <- c('GOLD' = 'LBMA/GOLD')
first_date <- '1950-01-01'
last_date <- Sys.Date()
my_api_key <- readLines('C:/Users/00141390/Insync/marceloperlin@gmail.com/Google Drive/98-pass-and-bash/.quandl_api.txt')

# get data!
df_quandl <- GetQuandlData::get_Quandl_series(
  id_in = my_symbol,
  api_key = my_api_key, 
  first_date = first_date,
  last_date = last_date
)

# check it
dplyr::glimpse(df_quandl)


library(GetQuandlData)
library(tidyverse)

# databse to get info
db_id <- 'RATEINF'
first_date <- '2015-01-01'
last_date <- Sys.Date()

# get info 
df_db <- get_database_info(db_id, my_api_key)

selected_series <- c('Inflation YOY - USA',
                     'Inflation YOY - Canada',
                     'Inflation YOY - Euro Area',
                     'Inflation YOY - Australia')

# filter selected countries
idx <- df_db$name %in% selected_series
df_db <- df_db[idx, ]

my_id <- df_db$quandl_code
names(my_id) <- df_db$name

df_inflation <- get_Quandl_series(
  id_in = my_id, 
  api_key = my_api_key,
  first_date = first_date,
  last_date = last_date
)

glimpse(df_inflation)



# set tickers
my_tickers <- "^BVSP"
first_date <- '2000-01-01'
last_date <- Sys.Date()

df_yf <- yfR::yf_get(tickers = my_tickers,
                     first_date = first_date,
                     last_date = last_date)

dplyr::glimpse(df_yf)


# set tickers
my_tickers <- c('PETR4.SA', 'CIEL3.SA',
                'GGBR4.SA', 'GOAU4.SA')
first_date <- '2015-01-01'
last_date <- Sys.Date()

df_yf <- yfR::yf_get(tickers = my_tickers,
                     first_date = first_date,
                     last_date = last_date)

dplyr::glimpse(df_yf)


# set tickers
df_ibov <- yfR::yf_index_composition("IBOV")

dplyr::glimpse(df_ibov)

table(df_ibov$industry)

df_stocks <- yfR::yf_collection_get("IBOV")


asset_codes <- 'LTN'   # Identifier of assets
maturity <- '010121'  # Maturity date as string (ddmmyy)
first_year <- 2015
last_year <- 2023

# download
df_TD <- GetTDData::td_get(asset_codes, 
                           first_year = first_year,
                           last_year = last_year)

dplyr::glimpse(df_TD)

GetTDData::get_td_names()


library(GetTDData)

# get yield curve
df_yield <- get.yield.curve()

# check result
dplyr::glimpse(df_yield)


library(GetBCBData)
library(dplyr)

# set ids and dates
id_series <- c(perc_default = 21082)
first_date = '2010-01-01'

# get series from bcb
df_cred <- gbcbd_get_series(id = id_series,
                            first.date = first_date,
                            last.date = Sys.Date(), 
                            use.memoise = FALSE)


library(GetDFPData2)

# get info for companies in B3
df_info <- get_info_companies()

# check it
dplyr::glimpse(df_info)



id_companies <- 9512
first_year <- 2010
last_year  <- 2022

# download data
l_dfp <- GetDFPData2::get_dfp_data(
  companies_cvm_codes = id_companies,
  type_docs = '*', # get all docs  
  type_format = 'con', # consolidated
  first_year = first_year,
  last_year = last_year
)

dplyr::glimpse(l_dfp)

BP <- l_dfp$`DF Consolidado - Balanço Patrimonial Ativo`


dre <- l_dfp$`DF Consolidado - Demonstração do Resultado`

id_LL <- "3.11"

LL <- dre |>
  dplyr::filter(CD_CONTA == id_LL) |>
  dplyr::select(DENOM_CIA, DT_REFER, CD_CONTA, VL_CONTA) |>
  dplyr::mutate(VL_CONTA = VL_CONTA*1000)

LL |>
  gt::gt() |>
  gt::tab_header("Lucro da GRENDENE SA") |>
  gt::fmt_currency(VL_CONTA, currency = "BRL")

id_EBITDA <- "3.05"

EBITDA <- dre |>
  dplyr::filter(CD_CONTA == id_EBITDA) |>
  dplyr::select(DENOM_CIA, DT_REFER, CD_CONTA, VL_CONTA) |>
  dplyr::mutate(VL_CONTA = VL_CONTA*1000)

EBITDA |>
  gt::gt() |>
  gt::tab_header("EBITDA da GRENDENE SA") |>
  gt::fmt_currency(VL_CONTA, currency = "BRL")


library(GetFREData)

# set options
id_companies <- 23264
first_year <- 2017
last_year  <- 2018

# download data
l_fre <- get_fre_data(companies_cvm_codes = id_companies,
                      first_year = first_year,
                      last_year = last_year)

dplyr::glimpse(l_fre)


names(l_fre)

df_Stockholders <- l_fre$df_stockholders
l_fre$df_compensation

df_boards <- l_fre$df_board_composition

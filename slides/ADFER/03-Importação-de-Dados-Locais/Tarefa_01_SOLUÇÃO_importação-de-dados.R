library(dplyr)

# Q01
# mudar diretório

setwd( '~')

n_row <- 10000
my_df <- tibble(x = 1:n_row,
             y = runif(n_row))

# csv
my_f <- 'temp.csv'
write_csv(my_df, my_f)
size_csv <- file.size(my_f)/1000000

# rds
my_f <- 'temp.rds'
write_rds(my_df, my_f)
size_rds <- file.size(my_f)/1000000

# xlsx
my_f <- 'temp.xlsx'
writexl::write_xlsx(my_df, my_f)
size_xlsx <- file.size(my_f)/1000000

# fst
my_f <- 'temp.fst'
fst::write_fst(my_df, my_f)
size_fst <- file.size(my_f)/1000000

print(c(size_csv, size_rds, size_xlsx, size_fst))

tab <- tibble(Result = c('csv', 'rds', 'xlsx', 'fst'), 
              Size =  c(size_csv, size_rds, size_xlsx, size_fst))

print(tab)

#Q02

# ....

# Q03
my_f <- afedR3::data_path("CH08_some-stocks-SP500.csv")
df <- readr::read_csv(my_f)

ncol(df)

# Q04
my_url <- "https://dados.cvm.gov.br/dados/CIA_ABERTA/CAD/DADOS/cad_cia_aberta.csv"
df <- readr::read_csv2(my_url)

dplyr::glimpse(df)
nrow(df)

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false

classtools::setup_quarto_slides("templates")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
my_file <- 'C:/Data/MyData.csv'
#
#
#
#
#
my_file <- 'Data/MyData.csv'
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| message: false
afedR3::data_list()
#
#
#
#
#
# get location of file
my_f <- afedR3::data_path('CH11_grunfeld.csv')

# print it
print(my_f)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| eval: false
help("read_csv", package = 'readr')
#
#
#
#| echo: false

knitr::include_graphics("figs/help-readr_read_csv.png")
#
#
#
#
#
#| echo: true
# get location of file
my_f <- afedR3::data_path('CH04_ibovespa.csv')

df <- readr::read_csv(my_f)
print(df)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: true
my_f <- afedR3::data_path('CH04_funky-csv-file.csv')

readr::read_lines(my_f, n_max = 10)
#
#
#
#
#
my_locale <- readr::locale(decimal_mark = ',')

df_not_funky <- readr::read_delim(
  file = my_f, 
  skip = 7, # how many lines do skip
  delim = ';', # column separator
  col_types = readr::cols(), # column types
  locale = my_locale # locale
)

dplyr::glimpse(df_not_funky)
#
#
#
#
#
#
library(readr)

# set number of observations
N <- 100

# create dataframe with random data
my_df <- data.frame(y = runif(N),
                    z = rep('a', N))

# write to file
f_out <- tempfile(fileext = '.csv')
readr::write_csv(x = my_df, file = f_out)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# set file
my_f <- afedR3::data_path("CH04_ibovespa-Excel.xlsx")

# read xlsx into dataframe
my_df <- readxl::read_excel(my_f, sheet = 'Sheet1')

# glimpse contents
dplyr::glimpse(my_df)
#
#
#
#
#
# set number of rows
N <- 50

# create random dataframe
my_df <- data.frame(y = seq(1,N),
                    z = rep('a',N))

# write to xlsx
f_out <- tempfile(fileext = '.xlsx')
writexl::write_xlsx(
  my_df, 
  f_out
)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# set file path
my_file <- afedR3::data_path('CH04_example-rds.rds')

# load content into workspace
my_df <- readr::read_rds(file = my_file)
dplyr::glimpse(my_df)
#
#
#
#
#
# set data and file
df <- data.frame(
  x = 1:100
)

my_file <- fs::file_temp(ext = '.rds')

# save as .rds
readr::write_rds(df, my_file)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: true
my_file <- afedR3::data_path('CH04_example-fst.fst')
my_df <- fst::read_fst(my_file)

dplyr::glimpse(my_df)
#
#
#
#
#
#| echo: true
library(fst)

# create dataframe
N <- 1000
my_file <- tempfile(fileext = '.fst')
my_df <- data.frame(x = runif(N))

# write to fst
write_fst(x = my_df, path = my_file)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# set name of SQLITE file
f_sqlite <- afedR3::data_path('CH04_example-sqlite.SQLite')

# open connection
my_con <- RSQLite::dbConnect(drv = RSQLite::SQLite(), 
                             f_sqlite)

# list tables
RSQLite::dbListTables(my_con)

# read table
my_df <- RSQLite::dbReadTable(conn = my_con,
                              name = 'MyTable1') # name of table in sqlite

# print with str
dplyr::glimpse(my_df)

# disconnect
RSQLite::dbDisconnect(my_con)
#
#
#
#
# open connection
my_con <- RSQLite::dbConnect(drv = RSQLite::SQLite(), 
                             f_sqlite)

# set sql statement
my_SQL_statement <- "select * from myTable2 where G='A'"

# get query
my_df_A <- RSQLite::dbGetQuery(conn = my_con, 
                               statement = my_SQL_statement)

# disconnect from db
RSQLite::dbDisconnect(my_con)

# print with str
print(my_df_A)
#
#
#
#
#
#
#| echo: true
library(RSQLite)

# set number of rows in df
N = 10^6 

# create simulated dataframe
my_large_df_1 <- data.frame(x=runif(N), 
                            G= sample(c('A','B'),
                                      size = N,
                                      replace = TRUE))

my_large_df_2 <- data.frame(x=runif(N), 
                            G = sample(c('A','B'),
                                       size = N,
                                       replace = TRUE))

# set name of SQLITE file
f_sqlite <- tempfile(fileext = '.SQLITE')

# open connection
my_con <- dbConnect(drv = SQLite(), f_sqlite)

# write df to sqlite
dbWriteTable(conn = my_con, name = 'MyTable1', 
             value = my_large_df_1)
dbWriteTable(conn = my_con, name = 'MyTable2', 
             value = my_large_df_2)

# disconnect
dbDisconnect(my_con)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# set file to read
my_f <- afedR3::data_path('CH04_price-and-prejudice.txt')

# read file line by line
my_txt <- read_lines(my_f)

# print 50 characters of first fifteen lines
print(stringr::str_sub(string = my_txt[1:15], 
                       start = 1, 
                       end = 50))
#
#
#
#
#
#
# set file
my_f <- tempfile(fileext = '.txt')

# set some string
my_text <- paste0('Today is ', Sys.Date(), '\n', 
                  'Tomorrow is ', Sys.Date()+1)

# save string to file
readr::write_lines(x = my_text, file = my_f, append = FALSE)
#
#
#
#
print(read_lines(my_f))
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| message: false
#| warning: false
library(fst)
library(readr)
library(arrow)
library(RSQLite)
library(wakefield)
library(dplyr)
library(purrr)

options(scipen = 999)

# create simulated dataset
set.seed(123)
n_row <- 500000

my_df <- as.data.frame(wakefield::r_data_frame(
  n = n_row,
  id,
  age,
  sex,
  income,
  date_stamp,
  valid
))

# benchmark helper function
benchmark_format <- function(name, write_fn, read_fn, ext, df) {
  f_temp <- fs::file_temp(ext = ext)
  on.exit(unlink(f_temp), add = TRUE)
  
  t_write <- system.time(write_fn(df, f_temp))[3]
  t_read  <- system.time(read_fn(f_temp))[3]
  size_mb <- file.size(f_temp) / 1e6
  
  tibble(
    Formato = name,
    `Tempo de Escrita (s)` = t_write,
    `Tempo de Leitura (s)` = t_read,
    `Tamanho em Disco (MB)` = size_mb
  )
}

# list of format specifications
benchmarks <- list(
  list(name = "csv", ext = ".csv",
       write_fn = \(df, f) write_csv(df, f),
       read_fn  = \(f) read_csv(f, show_col_types = FALSE)),
  list(name = "rds", ext = ".rds",
       write_fn = \(df, f) write_rds(df, f),
       read_fn  = \(f) read_rds(f)),
  list(name = "fst", ext = ".fst",
       write_fn = \(df, f) write_fst(df, f),
       read_fn  = \(f) read_fst(f)),
  list(name = "parquet", ext = ".parquet",
       write_fn = \(df, f) write_parquet(df, f),
       read_fn  = \(f) read_parquet(f)),
  list(name = "sqlite", ext = ".sqlite",
       write_fn = \(df, f) {
         con <- dbConnect(SQLite(), f); on.exit(dbDisconnect(con))
         dbWriteTable(con, "my_table", df)
       },
       read_fn = \(f) {
         con <- dbConnect(SQLite(), f); on.exit(dbDisconnect(con))
         dbReadTable(con, "my_table")
       })
)

# run all benchmarks
df_res <- purrr::map_dfr(benchmarks, \(b) {
  benchmark_format(b$name, b$write_fn, b$read_fn, b$ext, my_df)
})
#
#
#
#
#
#
#| echo: false
#| fig-width: 10
#| fig-height: 5
#| fig-align: "center"
library(ggplot2)
library(tidyr)

df_long <- df_res |>
  mutate(Formato = factor(Formato, levels = Formato)) |>
  pivot_longer(cols = -Formato, names_to = 'Métrica', values_to = 'Valor') |>
  mutate(Métrica = factor(Métrica, levels = c(
    'Tempo de Escrita (s)', 'Tempo de Leitura (s)', 'Tamanho em Disco (MB)'
  )))

ggplot(df_long, aes(x = Formato, y = Valor, fill = Formato)) +
  geom_col(show.legend = FALSE, width = 0.6) +
  geom_text(aes(label = round(Valor, 2)), vjust = -0.3, size = 3.5, fontface = 'bold') +
  facet_wrap(~Métrica, scales = 'free_y') +
  scale_fill_brewer(palette = 'Set2') +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  theme_minimal(base_size = 13) +
  theme(
    strip.text = element_text(face = 'bold', size = 12),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = 'bold', hjust = 0.5)
  ) +
  labs(
    title = paste0('Comparação de Desempenho (N = ', format(n_row, big.mark = ','), ' linhas)'),
    x = NULL, y = NULL
  )
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
library(wakefield)

n_row <- 10000
df <- r_data_frame(
  n = n_row,
  id,
  age,
  sex
)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

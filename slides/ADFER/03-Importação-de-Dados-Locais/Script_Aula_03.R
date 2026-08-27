# get location of file
my_f <- afedR3::data_path('CH11_grunfeld.csv')

# print it
print(my_f)

# get location of file
my_f <- afedR3::data_path('CH04_ibovespa.csv')

df <- readr::read_csv(my_f)
print(df)

dplyr::glimpse(df)


my_f <- afedR3::data_path('CH04_funky-csv-file.csv')

readr::read_lines(my_f, n_max = 10)

my_locale <- readr::locale(decimal_mark = ',')

df_not_funky <- readr::read_delim(
  file = my_f, 
  skip = 7, # how many lines do skip
  delim = ';', # column separator
  col_types = readr::cols(), # column types
  locale = my_locale # locale
)

dplyr::glimpse(df_not_funky)

df_wrong <- readr::read_csv(my_f)


library(readr)

# set number of observations
N <- 100

# create dataframe with random data
my_df <- data.frame(y = runif(N),
                    z = rep('a', N))

# write to file
f_out <- fs::file_temp(ext = '.csv')
f_out <- "~/my-csv-file.csv"
readr::write_csv(x = my_df, file = f_out)

# EXCEL

# set file
my_f <- afedR3::data_path("CH04_ibovespa-Excel.xlsx")

# read xlsx into dataframe
my_df <- readxl::read_excel(my_f, sheet = 'Sheet1')

# glimpse contents
dplyr::glimpse(my_df)


library(xlsx)

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

# RDS

# set file path
my_file <- afedR3::data_path('CH04_example-rds.rds')

# load content into workspace
my_df <- readr::read_rds(file = my_file)
dplyr::glimpse(my_df)


# set data and file
df <- data.frame(
  x = 1:100
)

my_file <- fs::file_temp(ext = '.rds')

# save as .rds
readr::write_rds(df, my_file)

# FST

my_file <- afedR3::data_path('CH04_example-fst.fst')
my_df <- fst::read_fst(my_file)

dplyr::glimpse(my_df)


library(fst)

# create dataframe
N <- 1000
my_file <- tempfile(fileext = '.fst')
my_df <- data.frame(x = runif(N))

# write to fst
write_fst(x = my_df, path = my_file)

# TESTING FST/RDS

library(fst)
library(readr)

# set number of rows
N <- 50000

# create random dfs
my_df <- data.frame(y = seq(1,N),
                    z = rep('a',N))

# set files
my_file_1 <- fs::file_temp(ext = ".rds")
my_file_2 <- fs::file_temp(ext = ".fst")

# test write
time_write_rds <- system.time(write_rds(my_df, my_file_1 ))
time_write_fst <- system.time(write_fst(my_df, my_file_2 ))

# test read
time_read_rds <- system.time(readRDS(my_file_1))
time_read_fst <- system.time(read_fst(my_file_2))

# test file size (MB)
file_size_rds <- file.size(my_file_1)/1000000
file_size_fst <- file.size(my_file_2)/1000000

# results
my_formats <- c('.rds', '.fst')
results_read <- c(time_read_rds[3], time_read_fst[3])
results_write<- c(time_write_rds[3], time_write_fst[3])
results_file_size <- c(file_size_rds , file_size_fst)

# print text
my_text <- paste0('\nTime to WRITE dataframe with ',
                  my_formats, ': ',
                  results_write, ' seconds', collapse = '')
message(my_text)


my_text <- paste0('\nTime to READ dataframe with ',
                  my_formats, ': ',
                  results_read, ' seconds', collapse = '')
message(my_text)

my_text <- paste0('\nResulting FILE SIZE for ',
                  my_formats, ': ',
                  results_file_size, ' MBs', collapse = '')
message(my_text)


# SQLITE

# set name of SQLITE file
f_sqlite <- afedR3::data_path('CH04_example-sqlite.SQLite')

# open connection
my_con <- RSQLite::dbConnect(drv = RSQLite::SQLite(), 
                             f_sqlite)

# list tables
RSQLite::dbListTables(my_con)


# read table
my_df <- RSQLite::dbReadTable(
  conn = my_con,
  name = 'MyTable1') # name of table in sqlite

# print with str
dplyr::glimpse(my_df)

RSQLite::dbDisconnect(my_con)

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

my_df_A


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

dbListTables(my_con)

dbListFields(my_con, 'MyTable1')

# DADOS NAO ESTRUTURADOS

# set file to read
my_f <- afedR3::data_path('CH04_price-and-prejudice.txt')

# read file line by line
my_txt <- read_lines(my_f)

# print 50 characters of first fifteen lines
print(stringr::str_sub(string = my_txt[1:15], 
                       start = 1, 
                       end = 50))

# set file
my_f <- tempfile(fileext = '.txt')
my_f <- '~/abc.txt'
# set some string
my_text <- paste0('Today is ', Sys.Date(), '\n', 
                  'Tomorrow is ', Sys.Date()+1, '\n\n',
                  Sys.time())

# save string to file
readr::write_lines(x = my_text, file = my_f, append = FALSE)

# get location of file
my_f <- afedR3::data_path('CH04_ibovespa.csv')

df <- readr::read_csv(my_f)
print(df)

my_f <- afedR3::data_path('CH04_funky-csv-file.csv')

readr::read_lines(my_f, n_max = 100)


my_locale <- readr::locale(decimal_mark = ',')

df_not_funky <- readr::read_delim(
  file = my_f, 
  skip = 7, # how many lines do skip
  delim = ';', # column separator
  col_types = readr::cols(), # column types
  locale = my_locale # locale
)

dplyr::glimpse(df_not_funky)


# set file
my_f <- afedR3::data_path("CH04_ibovespa-Excel.xlsx")
my_f
# read xlsx into dataframe
my_df <- readxl::read_excel(my_f, sheet = 'Sheet1')

# glimpse contents
dplyr::glimpse(my_df)


my_file <- afedR3::data_path('CH04_example-fst.fst')
my_df <- fst::read_fst(my_file)

dplyr::glimpse(my_df)


library(fst)
library(readr)

# set number of rows
N <- 50000000

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


# set file to read
my_f <- afedR3::data_path('CH04_price-and-prejudice.txt')

# read file line by line
my_txt <- read_lines(my_f)

# print 50 characters of first fifteen lines
print(stringr::str_sub(string = my_txt[1:15], 
                       start = 1, 
                       end = 50))


# set tickers
my_tickers <- "^GSPC"
first_date <- '1950-01-01'
last_date <- Sys.Date()

df_yf <- yfR::yf_get(tickers = my_tickers,
                     first_date = first_date,
                     last_date = last_date)

dplyr::glimpse(df_yf)


# set tickers
df_ibov <- yfR::yf_index_composition("IBOV")
df_ibov


asset_codes <- 'LTN'   # Identifier of assets
maturity <- '010121'  # Maturity date as string (ddmmyy)
first_year <- 2015
last_year <- 2024

# download
df_TD <- GetTDData::td_get(asset_codes, 
                           first_year = first_year,
                           last_year = last_year)

dplyr::glimpse(df_TD)


id_companies <- 19615
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


library(GetFREData)

# set options
id_companies <- 23264
first_year <- 2017
last_year  <- 2018

# download data
l_fre <- get_fre_data(companies_cvm_codes = id_companies,
                      first_year = first_year,
                      last_year = last_year)

glimpse(l_fre)

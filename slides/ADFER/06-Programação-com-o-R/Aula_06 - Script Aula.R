setwd('~/ADFER-Classes/Aula 07 - Programação com o R/')

# função
my_fct <- function(arg1 = 0, arg2 = 0) {
  
  message('arg1 = ', arg1, ' | arg2 = ', arg2)
  
  out <- arg1 + arg2
  
  l_out <- list(
    out1 = arg1 + arg2,
    out2 = arg1 - arg2
  )
  
  return(l_out)
}

out_fct <- my_fct(arg1 = 10, arg2 = 10)

out_fct <- my_fct()
out_fct <- my_fct(arg1 = 10)

# execuções repetidas (menos inteligente)
x1 <- 2 + 10
x2 <- 5 + 10
x3 <- 10 + 10

# execuções repetidas (mais inteligente)
x1 <- my_fct(2)
x2 <- my_fct(5)
x3 <- my_fct(10)

# Loops

# printing from 1 to 4 (not smart)
print(1)
print(2)
print(3)
print(4)
print(5)

# printing from 1 to 4 (not smart)
N <- 5000

for (i in 1:N) {
  print(i)
}

# saving files to folder
n_files <- 500

my_dir <- 'temp_data'
dir.create(my_dir)

for (i_file in 1:n_files) {
  
  message('Writing file ', i_file)
  temp_df <- dplyr::tibble(
    x = runif(100),
    y = runif(100)
  )
  
  f_out <- file.path(my_dir,
                     paste0('file_', i_file, '.csv'))
  
  readr::write_csv(temp_df, f_out)
  
}

# reading files 
l_df <- list()
my_c <- 1
f_to_read <- fs::dir_ls(my_dir, glob = '*.csv')
  
for (i_file in f_to_read) {
  
  message('Reading ', i_file)
  df_temp <- readr::read_csv(i_file,
                             show_col_types = FALSE)
  
  l_df[[my_c]] <- df_temp
  
  my_c <- my_c + 1
  
}
  
df_final <- dplyr::bind_rows(
  l_df
)  

dplyr::glimpse(df_final)  


# execuções condicionais
my_x <- 1:10
my_thresh <- 5

for (i in my_x){
  if (i > my_thresh){
    cat('\nValue of i', i, '- Higher than ', my_thresh)
  } else {
    cat('\nValue of i', i, '- Lower or equal than ', my_thresh)
  }
}

my_x <- 1:10
my_y <- 1:15
my_thresh <- 5

for (i_x in my_x){
  for (i_y in my_y) {
    message('x = ', i_x, ' | y = ', i_y)
    
    if (i_x < my_thresh) {
      message('\t  i_ < my_thresh')
    }
    
    if (i_y < my_thresh) {
      message('\t  i_y < my_thresh')
    }
    
    if ( (i_y < my_thresh)&(i_x < my_thresh) ) {
      message('\t  i_y & i_x < my_thresh')
    }
    
  }
  
}

# Exemplo prático com dados da bolsa

#devtools::install_github('msperlin/yfR')
df_yf <- yfR::yf_get_collection(collection = 'IBOV', 
                                first_date = '2005-01-01',
                                last_date  = Sys.Date())

dplyr::glimpse(df_yf)

unique_tickers <- unique(
  df_yf$ticker
)

unique_tickers

# operation split-apply-combine with loops
df_results <- dplyr::tibble()
for (i_ticker in unique_tickers) {
  
  message('Processing ', i_ticker)
  
  # 1) split
  df_filtered <- df_yf |>
    dplyr::filter(ticker == i_ticker) |>
    na.omit()
  
  message('\t* got ', nrow(df_filtered), ' rows')
  
  # 2) apply
  mean_ret <- mean(df_filtered$ret_adjusted_prices)
  sd_ret <- sd(df_filtered$ret_adjusted_prices)
  mean_volume <- mean(df_filtered$volume)
  final_price <- dplyr::last(df_filtered$price_adjusted)
  
  # 3) combine
  df_results <- dplyr::bind_rows(
    df_results,
    dplyr::tibble(
      ticker = i_ticker,
      mean_ret,
      sd_ret,
      mean_volume,
      final_price
    )
  )
  
}

View(df_results)

plot(x = df_results$sd_ret,
     y = df_results$mean_ret)

# using apply funtions to solve the problem

# 1) split 
l_split <- split(x = df_yf,
                 f = df_yf$ticker)

# 2) apply
parse_fct <- function(df_in) {
  
  df_in <- df_in |>
    na.omit()
  
  tib_out <- dplyr::tibble(
    ticker = unique(df_in$ticker),
    mean_ret =  mean(df_in$ret_adjusted_prices),
    sd_ret =  sd(df_in$ret_adjusted_prices),
    mean_volume = mean(df_in$volume),
    final_price = dplyr::last(df_in$price_adjusted)
  )
  
  return(tib_out)
}

l_results <- lapply(l_split, parse_fct)

# 3) combine
df_results <- dplyr::bind_rows(
  l_results
)

View(df_results)

# using dplyr function to solve the problem

# pipes 1: %>% --  pode usar . 
# pipe 2 (junho 2021, R ver > 4.1): |>

# example 1: descriptive table

df_results <- df_yf |>
  na.omit() |>
  dplyr::group_by(ticker) |>
  dplyr::summarise(
    ticker = unique(ticker),
    mean_ret =  mean(ret_adjusted_prices),
    sd_ret =  sd(ret_adjusted_prices),
    mean_volume = mean(volume),
    final_price = dplyr::last(price_adjusted)
  ) 

View(df_results)

# example 2: daily to annual
df_annual <- df_yf |>
  dplyr::mutate(year = format(ref_date, '%Y')) |>
  dplyr::group_by(ticker, year) |>
  dplyr::summarise(
    price = dplyr::last(price_adjusted)
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(
    ret = BatchGetSymbols::calc.ret(
    price,
    ticker
  ))

View(df_annual)

df_MV <- df_annual |>
  na.omit() |>
  dplyr::group_by(ticker) |>
  dplyr::summarise(
    mean_ret = mean(ret),
    sd_ret = sd(ret),
    n_obs = dplyr::n()
  ) |>
  dplyr::ungroup() |>
  dplyr::filter(
    n_obs >= 15
  )

View(df_MV)

plot(x = df_MV$sd_ret,
     y = df_MV$mean_ret)


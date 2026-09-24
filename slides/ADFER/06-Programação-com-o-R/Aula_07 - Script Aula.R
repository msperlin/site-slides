my_fct <- function(arg1 = 1, arg2 = 'abc'){
  
  length_arg1 <- length(arg1)
  length_arg2 <- length(arg2)
  
  msg1 <- paste0('Number of elements in arg1: ', length_arg1)
  message(msg1)
  
  message(paste0('arg1 = ', arg1))
  
  msg2 <- paste0('Number of elements in arg2: ', length_arg2)
  message(msg2)
  message(paste0('arg2 = ', arg2))
  
  out <- c(length_arg1, length_arg2)
  return(out)
  
}

out1 <- my_fct(arg1 = 2, arg2 = 'bcd')
print(out1)

my_fct()


# set seq
my_seq <- seq(-5,5)

# do loop
for (i in my_seq) {
  message(paste('The value of i is',i))
}

# set matrix
my_mat <- matrix(1:9, nrow = 3)

# loop all values of matrix
for (i in seq(1, nrow(my_mat))){
  for (j in seq(1, ncol(my_mat))){
    message(paste0('Element [', i, ', ', j, '] = ', my_mat[i, j]))
  }
}


get_cum_ret <- function(ticker){
  
  first_date <- "2010-01-01"
  last_date <- Sys.Date()
  
  df_yf <- yfR::yf_get(ticker, first_date, last_date)
  
  first_price <- dplyr::first(df_yf$price_adjusted)
  last_price <- dplyr::last(df_yf$price_adjusted)
  cum_ret <- last_price/first_price - 1
  
  return(cum_ret)
  
}

ticker_vec <- c("PETR4.SA", "GRND3.SA", 
                "WEGE3.SA", "AMER3.SA", "^BVSP",
                "^GSPC", "META", "VALE3.SA")

cum_ret_vec <- numeric()
for (i_ticker in seq_along(ticker_vec) ) {
  
  this_ticker <- ticker_vec[i_ticker]
  this_cum_ret <- get_cum_ret(this_ticker)
  
  cum_ret_vec[this_ticker] <- this_cum_ret
}

cum_ret_vec

f_data <- afedR3::data_path("CH08_some-stocks-SP500.csv")
df_stocks <- readr::read_csv(f_data)

dplyr::glimpse(df_stocks)

ticker_vec <- unique(df_stocks$ticker)

cum_ret_vec <- numeric()
for (i_ticker in seq_along(ticker_vec) ) {
  
  this_ticker <- ticker_vec[i_ticker]
  this_cum_ret <- get_cum_ret(this_ticker)
  
  cum_ret_vec[this_ticker] <- this_cum_ret
}

cum_ret_vec


library(dplyr)

# read data
my_f <- afedR3::data_path('CH08_some-stocks-SP500.csv')
my_df <- readr::read_csv(my_f)

# find unique tickers in column ticker
unique_tickers <- unique(my_df$ticker)

# create empty df
tab_out <- tibble()

# loop tickers
for (i_ticker in unique_tickers){
  
  # create temp df with ticker i_ticker
  temp_df <- my_df |>
    filter(ticker == i_ticker)
  
  temp_last_price <- dplyr::last(temp_df$price_adjusted)
  temp_last_date <- dplyr::last(temp_df$ref_date)
  
  tibble_temp <- tibble(ticker = i_ticker,
                        mean_price = temp_last_price,
                        last_date = temp_last_date)
  
  tab_out <- bind_rows(tab_out,
                       tibble_temp)
  
}

tab_out


my_x <- 1:10
my_thresh <- 5

for (i in my_x){
  if (i > my_thresh){
    message('Value of i is ', i, ' - Higher than ', my_thresh)
  } else {
    message('Value of i is ', i, ' - Lower or equal than ', my_thresh)
  }
}


my_x <- 1:10
my_thresh <- 5

for (i in my_x){
  if (i > my_thresh){
    message('Value of i is ', i, ' - Higher than ', my_thresh)
  } else if (i == my_thresh) {
    message('Value of i ', i, ' - equal to ', my_thresh)
  } else {
    message('Value of i ', i, ' - lower than ', my_thresh)
  }
}

x <- c("A", "B")
y <- c("C", "D", "E")

tidyr::expand_grid(x, y)


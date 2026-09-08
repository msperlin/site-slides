df <- tibble::tibble(
  x = 1:10,
  y = sample(letters, 10)
)

dplyr::glimpse(df)


# set tickers
ticker <- c(rep('ABEV3',4),
            rep('BBAS3', 4),
            rep('BBDC3', 4))

# set dates
ref_date <- as.Date(rep(c('2010-01-01', '2010-01-04',
                          '2010-01-05', '2010-01-06'),
                        3) )

# set prices
price <- c(736.67, 764.14, 768.63, 776.47,
           59.4  , 59.8  , 59.2  , 59.28,
           29.81 , 30.82 , 30.38 , 30.20)

# create tibble/dataframe
my_df <- dplyr::tibble(
  ticker, 
  ref_date, 
  price
)

# print it
print(my_df)


# isolate columns of df
my_ticker <- my_df$ticker
my_prices <- my_df[['price']]

first_price <- my_df$price[1]
my_df$price[1:10]

my_df[1:10, 1:2]

# exemplo pipeline
df <- tibble::tibble(
  x = 1:10,
  y = runif(10)
)

fct1 <- function(df_in) {
  df_in$col1 <- 1
  return(df_in)
}

fct2 <- function(df_in) {
  df_in$col2 <- 2
  return(df_in)
}

fct3 <- function(df_in) {
  df_in$col3 <- 3
  return(df_in)
}

df_3 <- df |>
  fct1() |>
  fct2() |>
  fct3()

dplyr::glimpse(df_3)

# filtrando
library(dplyr)
# filter df for single stock and date
my_df_temp <- my_df |>
  filter(ticker == 'ABEV3',
         ref_date != as.Date('2010-01-05')) |>
  glimpse()

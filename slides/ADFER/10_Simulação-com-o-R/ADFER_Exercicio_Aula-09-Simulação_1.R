C <- 0.000
my_sd = 0.015
my_var <- my_sd^2
nT <- 100

R <- numeric(nT)
P <- numeric(nT)
P[1] <- 100

for (t in seq(2, nT)) {
  cli::cli_alert_info("simulating price {t}")
  R[t] <- C + rnorm(1, 0, my_sd)
  P[t] <- P[t-1]*exp(R[t])
  
}

P
x11(); plot(P)

## Exercise 02
create_rnd_walk <- function(
    i_sim,
    nT, C, P_0, my_sd
    ) {
  
  R <- numeric(nT)
  P <- numeric(nT)
  P[1] <- P_0
  
  for (t in seq(2, nT)) {
    #cli::cli_alert_info("simulation {i_sim}, price {t}")
    R[t] <- C + rnorm(1, 0, my_sd)
    P[t] <- P[t-1]*exp(R[t])
    
  }
  
  df_out <- tibble::tibble(
    i_sim = i_sim,
    t = 1:nT,
    P = P
  )
  
  return(df_out)
}

C <- 0.000
my_sd = 0.015
my_var <- my_sd^2
nT <- 100
P_0 <- 100

df <- create_rnd_walk(1, nT,
                      C, P_0, my_sd)

n_sim <- 1000

df_sim <- purrr::map_df(
  1:n_sim,
  create_rnd_walk,
  nT = nT,
  C = C,
  P_0 = P_0,
  my_sd = my_sd
)

library(ggplot2)

p <- ggplot(df_sim, 
            aes(x = t,
                y = P,
                group = i_sim)) + 
  geom_line()

x11() ; p 

prices_at_T <- df_sim |>
  dplyr::filter(t == 100)

p <- ggplot(prices_at_T, aes(x = P)) + 
  geom_histogram()

x11() ; p

library(tidyverse)

N <- 100000

# Normal variable
X <- rnorm(n = N, mean = 10, sd = 10)

glimpse(X)

print(ggplot(data.frame(X), aes(x = X)) + 
        geom_histogram() + labs(main = 'Normal Distribution'))


# Gamma variable
X <- rgamma(n = N, shape = 100)
print(ggplot(data.frame(X), aes(x = X)) + 
        geom_histogram() + labs(main = 'Gamma'))

# Uniform variable
X <- runif(n = N)
print(ggplot(data.frame(X), aes(x = X)) + 
        geom_histogram() + labs(main = 'Uniform'))

# beta variable
X <- rbeta(n = N, shape1 = 1.5, shape2 = 2.5)
print(ggplot(data.frame(X), aes(x = X)) + 
        geom_histogram() + labs(main = 'Uniform'))

# exercise 01: Modelo RW ----
C <- 0.005
var <- 0.015^2
sd <- sqrt(var)
P_0 <- 100
nT <- 100

P <- numeric(nT)
P[1] <- P_0

for (t in seq(2, nT)) {
  
  message('Simulating price for time ', t)
  R <- C + rnorm(n = 1, mean = 0, sd = sd)
  P[t] <- P[t-1]*exp(R)
  
}

plot(P)

# exercise 02: Modelo RW ----
n_sim <- 1000
nT <- 100

C <- 0.001
var <- 0.015^2
sd <- sqrt(var)
P_0 <- 100


df_prices <- tibble()
for (i_sim in seq(1, n_sim)) {
  
  message('Simulation ', i_sim)
  
  P <- numeric(nT)
  P[1] <- P_0
  for (i_t in seq(2, nT)) {
    
    R <- C + rnorm(n = 1, mean = 0, sd = sd)
    P[i_t] <- P[i_t-1]*exp(R)
    
  }
  
  df_prices <- bind_rows(
    df_prices,
    tibble(sim = i_sim,
           i_t = c(1, seq(2, nT)),
           P)
  )
  
}

glimpse(df_prices)

p <- ggplot(df_prices, 
            aes(x = i_t, 
                y = P,
                group = factor(sim))) + 
  geom_line(size = 0.1)

p

# exerc 03: pricing options ----
set.seed(10)

n_sim <- 1000
nT <- 100
K <- 110
r <- 0.05

C <- 0
var <- 0.015^2
sd <- sqrt(var)
P_0 <- 100

df_prices <- tibble()
for (i_sim in seq(1, n_sim)) {
  
  message('Simulation ', i_sim)
  
  P <- numeric(nT)
  P[1] <- P_0
  for (i_t in seq(2, nT)) {
    
    R <- C + rnorm(n = 1, mean = 0, sd = sd)
    P[i_t] <- P[i_t-1]*exp(R)
    
  }
  
  df_prices <- bind_rows(
    df_prices,
    tibble(sim = i_sim,
           i_t = c(1, seq(2, nT)),
           P)
  )
  
}

glimpse(df_prices)

df_payoff <- df_prices |>
  filter(i_t == nT) |>
  mutate(K = K,
         payoff = if_else(P >K, P - K, 0))

df_payoff

# resposta 1
price_call <- mean(df_payoff$payoff)/(1+r)
price_call

# resposta 2
K <- 90
set.seed(15)
df_prices <- tibble()
for (i_sim in seq(1, n_sim)) {
  
  message('Simulation ', i_sim)
  
  P <- numeric(nT)
  P[1] <- P_0
  for (i_t in seq(2, nT)) {
    
    R <- C + rnorm(n = 1, mean = 0, sd = sd)
    P[i_t] <- P[i_t-1]*exp(R)
    
  }
  
  df_prices <- bind_rows(
    df_prices,
    tibble(sim = i_sim,
           i_t = c(1, seq(2, nT)),
           P)
  )
  
}

df_payoff <- df_prices |>
  filter(i_t == nT) |>
  mutate(K = K,
         payoff = if_else(P < K, K - P, 0))

df_payoff

price_put <- mean(df_payoff$payoff)/(1+r)
price_put

# Simulating Ibovespa ----
df_ibov <- BatchGetSymbols::BatchGetSymbols('^BVSP',
                                            first.date = Sys.Date() - 365*3,
                                            last.date = Sys.Date())[[2]] |>
  na.omit()

glimpse(df_ibov)                                              

set.seed(10)

n_sim <- 1000
nT <- 100

C <- mean(df_ibov$ret.adjusted.prices)
var <- var(df_ibov$ret.adjusted.prices)
sd <- sqrt(var)
P_0 <- last(df_ibov$price.adjusted)

df_prices <- tibble()
for (i_sim in seq(1, n_sim)) {
  
  message('Simulation ', i_sim)
  
  P <- numeric(nT)
  P[1] <- P_0
  for (i_t in seq(2, nT)) {
    
    R <- C + rnorm(n = 1, mean = 0, sd = sd)
    P[i_t] <- P[i_t-1]*exp(R)
    
  }
  
  df_prices <- bind_rows(
    df_prices,
    tibble(sim = i_sim,
           i_t = c(1, seq(2, nT)),
           P)
  )
  
}

glimpse(df_prices)

p_ibov <- ggplot(df_prices, 
                 aes(x = i_t,
                     y = P,
                     group = sim)) +
  geom_line()

p_ibov

# Realizando uma amostragem (sampling) no R
library(ggplot2)
library(dplyr)

graphics.off()

setwd('C:/Dropbox/E.A. UFRGS/Material Aula/2016-1/ADP 313 - Quant Met/Aulas/Aula 9 - Tópicos Avançados no R II (Simulação)/Exercícios')

set.seed(10)

N.Sim = 10000
n.T <- 100

df <- read.csv('Ibov_PETR4.csv')

df <- filter(df, ticker == '^BVSP')

P <- df$price
R <- log(P/lag(P))

C <- mean(R, na.rm = T)
sigma <- sd(R, na.rm = T)

P.0 <- P[length(P)]
my.sd <- sigma
my.C <- C

my.P <- matrix(data = 0, nrow = n.T, ncol = N.Sim)
my.R <- matrix(data = 0, nrow = n.T, ncol = N.Sim)
my.P[1,] <- P.0
for (i.sim in seq(N.Sim)){
  for (i.t in seq(2,n.T)){
    
    my.R[i.t,i.sim] <- my.C + rnorm(n = 1,mean = 0, sd = my.sd)
    my.P[i.t,i.sim] <- my.P[i.t-1,i.sim]*exp(my.R[i.t, i.sim])
    
  }
}

x11()
matplot(my.P, type = 'l')
    
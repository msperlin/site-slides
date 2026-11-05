# Realizando uma amostragem (sampling) no R
library(ggplot2)
library(dplyr)

rm(list=ls())
graphics.off()

setwd('C:/Dropbox/E.A. UFRGS/Material Aula/2016-1/ADP 313 - Quant Met/Aulas/Aula 9 - Tópicos Avançados no R II (Simulação)/Exercícios')

set.seed(10)

N.Sim = 1000

df <- read.csv('SP500Stocks.csv')

P.mat <- as.matrix(df[,3:ncol(df)])
R.mat <- P.mat/lag(P.mat) -1 

R.mat[is.na(R.mat)] <- 0

n.assets <- ncol(R.mat)

rnd.P <- matrix(nrow = nrow(P.mat), ncol = N.Sim)
for (i.sim in seq(N.Sim)){
  
  rnd.vec <- runif(n.assets)
  rnd.w <- rnd.vec/sum(rnd.vec)
  
  # returns of the portfolio
  R.port <- R.mat %*% rnd.w 
  
  # save cumulative value of portfolio
  rnd.P[, i.sim] <- cumprod(1+R.port)

  
  
}

x11()
matplot(rnd.P, type = 'l')

x11()
matplot(cumsum(R.mat[,1]), type = 'l')
    
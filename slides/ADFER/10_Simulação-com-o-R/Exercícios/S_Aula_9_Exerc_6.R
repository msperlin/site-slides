# Realizando uma amostragem (sampling) no R
library(ggplot2)
library(dplyr)
library(tidyr)

rm(list = ls())

graphics.off()

setwd('C:/Dropbox/E.A. UFRGS/Material Aula/2016-1/ADP 313 - Quant Met/Aulas/Aula 9 - Tópicos Avançados no R II (Simulação)/Exercícios')

set.seed(10)

N.Sim = 10000

df <- read.csv('Ibov_PETR4.csv')

df.petr4 <- filter(df, ticker == 'PETR4.SA')
df.ibov <- filter(df, ticker == '^BVSP')

P.petr4 <- df.petr4$price
refdate.petr4 <- as.Date(df.petr4$date)

P.ibov <- df.ibov$price
refdate.ibov <- as.Date(df.ibov$date)

# find matching dates (could also use wide version of df for easier matching of dates)

idx <- match(refdate.petr4, refdate.ibov )

P.ibov <- P.ibov[idx]

# returns
R.petr4 <- log(P.petr4/lag(P.petr4))
R.ibov <- log(P.ibov/lag(P.ibov))

ols.df <- data.frame(R.petr4, R.ibov )

# remove NA
ols.df <- ols.df[complete.cases(ols.df), ]

mkt.model <- lm(data = ols.df, formula = R.petr4 ~ R.ibov)

summary(mkt.model)

alpha <- coef(mkt.model)[1]
beta <- coef(mkt.model)[2]

res <- mkt.model$residuals

value.vec <- vector(length = N.Sim)
for (i.sim in seq(N.Sim)){
  
  rnd.res <- sample(res)
  y.star <- mkt.model$fitted.values + rnd.res
  
  ols.df.boots <- data.frame(y.star, ols.df$R.ibov)
  
  bootstrapping.model <- lm(data = ols.df, formula = y.star ~ R.ibov)
  
  alpha.boot <- coef(bootstrapping.model)[1]
  beta.boot <- coef(bootstrapping.model)[2]
  
  value.vec[i.sim] <- alpha.boot/beta.boot

  cat('\ni.sim = ', i.sim)

}

x11()
qplot(x = value.vec, geom = 'histogram')

cat('\nErro padrão de alpha/beta = ', sd(value.vec))

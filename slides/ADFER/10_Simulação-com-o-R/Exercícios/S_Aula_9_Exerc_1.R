# Realizando uma amostragem (sampling) no R
library(ggplot2)

set.seed(10)

N.Sim = 1
n.T <- 100

P.0 <- 100
my.sd <- 0.1
my.C <- 0.01

my.P <- vector(length = n.T)
my.R <- vector(length = n.T)
my.P[1] <- P.0
for (i.t in seq(2,n.T)){
  
  my.R[i.t] <- my.C + rnorm(n = 1,mean = 0, sd = my.sd)
  my.P[i.t] <- my.P[i.t-1]*exp(my.R[i.t])
  
}

x11()
qplot(y = my.P, x = seq(n.T), geom= 'line')
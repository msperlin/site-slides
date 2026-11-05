# Realizando uma amostragem (sampling) no R
library(ggplot2)
graphics.off()

set.seed(10)

N.Sim = 1000
n.T <- 100

P.0 <- 100
my.sd <- 0.01
my.C <- 0.01

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
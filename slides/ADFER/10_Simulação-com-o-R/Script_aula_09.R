library(ggplot2)
N <- 100000

# Normal variable
X <- rnorm(n = N, mean = 2, sd = 10)

x11(); 

ggplot(data.frame(X), aes(x = X)) + geom_histogram() + 
  labs(main = 'Normal Distribution') + 
  theme_light()


library(ggplot2)

N <- 100
alpha <- 100
beta <- 0.2
eps <- rnorm(N, mean = 0, sd = 1)

x <- rnorm(N, mean = 0, sd = 0.2)
y <- alpha + beta*x + eps

p <- ggplot(dplyr::tibble(x, y), aes(y, x)) + 
  geom_line() + 
  theme_light() + 
  labs(title = "A simulated regression model",
       y = "Simulated Series",
       x = "Index")

x11(); p

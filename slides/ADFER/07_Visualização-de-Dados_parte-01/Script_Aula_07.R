tickers <- c("^BVSP", "^FTSE", "^GSPC")

df_yf <- yfR::yf_get(tickers, "2015-01-01")

dplyr::glimpse(df_yf)

library(ggplot2)

# versao 1
p <- ggplot(data = df_yf, 
            aes(x = ref_date, y = cumret_adjusted_prices))

x11(); print(p)

# versao 2
p <- ggplot(data = df_yf, 
            aes(x = ref_date, y = cumret_adjusted_prices)) +
  geom_line()

x11(); print(p)

# versao 3
p <- ggplot(data = df_yf, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices,
                color = ticker)) +
  geom_line()

x11(); print(p)

# versao 4
first_year <- format(min(df_yf$ref_date), "%Y")
p <- ggplot(data = df_yf, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices,
                color = ticker)) +
  geom_line() + 
  labs(
    title = "Valor acumulado de índices de ações",
    subtitle = paste0("Dados desde ", first_year),
    x = "Datas",
    y = "Investimento Acumulado",
    caption = paste0("Dados do YF, retirados em ", Sys.time())
  )

x11(); print(p)

# versao 5 (final)
first_year <- format(min(df_yf$ref_date), "%Y")
p <- ggplot(data = df_yf, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices,
                color = ticker)) +
  geom_line() + 
  labs(
    title = "Valor acumulado de índices de ações",
    subtitle = paste0("Dados desde ", first_year),
    x = "Datas",
    y = "Investimento Acumulado",
    caption = paste0("Dados do YF, retirados em ", Sys.time())
  ) + 
  theme_light() 

x11(); print(p)


x11(); colorspace::hcl_palettes(plot = TRUE)

# exemplo faceta
first_year <- format(min(df_yf$ref_date), "%Y")
p <- ggplot(data = df_yf, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices,
                color = ticker)) +
  geom_line() + 
  labs(
    title = "Valor acumulado de índices de ações",
    subtitle = paste0("Dados desde ", first_year),
    x = "Datas",
    y = "Investimento Acumulado",
    caption = paste0("Dados do YF, retirados em ", Sys.time())
  ) + 
  theme_light() +
  facet_wrap(facets = "ticker")

x11(); print(p)

f_png <- "~/grafico_ações.png"
ggsave(f_png, p,
       height = 7,
       width = 12)

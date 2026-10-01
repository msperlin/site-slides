#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
classtools::setup_quarto_slides('content')
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
knitr::include_graphics("figs/capa-livro-siegel.jpg")
#
#
#
#
#
knitr::include_graphics("figs/investing_for_the_long_run.jpg")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
library(ggplot2)
library(dplyr)

# Usamos um arquivo de dados já exportado e versionado, garantindo que os
# slides compilem mesmo sem conexão com a internet. Para baixar os dados
# diretamente da fonte (BCB-SGS, série 433), use:
# df_inflation <- GetBCBData::gbcbd_get_series(433) |>
#   mutate(value = value/100) |>
#   janitor::clean_names()

df_inflation <- vdr::data_import("Chapter02-inflation-BR-2005-2022.csv")

df_1 <- df_inflation |>
  dplyr::filter(ref_date >= as.Date("2015-01-01"))

p_ugly <- ggplot(df_1, aes(x = ref_date, y = value)) +
  geom_col() + 
  labs(title = "Inflação")

p_ugly
#
#
#
#
#
#
#
#
#
#
#
#
library(stringr)
library(ggtext)
library(dplyr)

build_inflation_plot <- function(df) {
    
  first_month <- format(min(df$ref_date), '%d/%m/%Y')
  last_month <- format(max(df$ref_date), '%d/%m/%Y')
  
  color_max <- 'red'
  color_min <- 'blue'
  
  my_mean <- vdr::format_percent(mean(df$value))
  my_sd <-  vdr::format_percent(sd(df$value))

  df_points <- df |>
    slice(c(which.max(value), which.min(value)) ) |>
    mutate(name = c('max', 'min'))
  
  p <- ggplot(df, aes(x = ref_date, y = value, fill = value)) + 
    geom_col(alpha = 0.75) + #geom_line() + 
    geom_point(data = df_points, aes(color = name), size = 5) + 
    scale_color_manual(values = c(color_max, color_min)) + 
    colorspace::scale_fill_binned_diverging("blue-red", rev=FALSE, mid=mean(df$value )) +
    #scale_fill_grey(start = 0.8, end = 0.2)  + 
    labs(title = str_glue('<span style="font-size:16pt">A **Variabilidade** da Inflação (IPCA) </span>', 
                          '<span style="font-size:10pt">{first_month} - {last_month}</span>'),
         subtitle = str_glue('A média de inflação mensal é {my_mean}, com desvio padrão de {my_sd}', 
                             '<br>',
                             'A inflação mensal variou de um mínimo de ', 
                             '<span style="color:{color_min}"> {vdr::format_percent(min(df$value))} </span>',
                             ', até um máximo de ',
                             '<span style="color:{color_max}"> {vdr::format_percent(max(df$value))} </span>.'),
         x = '',
         y = 'Inflação Mensal',
         caption = str_glue('Dados para índice IPCA mensal amplo',
                            '<br>',
                            'Dados obtidos no BCB-SGS, série 433') ) + 
    scale_y_continuous(labels = scales::percent) + 
    theme_light() + 
    theme(
      axis.text.y = element_markdown(),
      plot.subtitle = element_markdown(),
      plot.caption = element_markdown(),
      plot.title = element_markdown(lineheight = 1.2),
      legend.position = 'none'
    )
  
  return(p)
}

p_pretty <- build_inflation_plot(df_1)

p_pretty
#
#
#
#
#
cowplot::plot_grid(
  p_ugly + labs(title = "Versão original"),
  p_pretty,
  nrow = 1
)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
ggplot(data = df, aes(x = ..., y = ...)) +
  geom_*() +
  scale_*() +
  facet_*() +
  theme_*()
#
#
#
#
#
#
#
#
#
#
library(ggplot2)

name_file <- "Chapter02-PETR-stock-2015-2022.csv"
df_yf <- vdr::data_import(name_file)

p0 <- ggplot(
  data = df_yf,
  mapping = aes(x = ref_date, y = price_adjusted)
)

print(p0)
#
#
#
#
#
min_year <- lubridate::year(min(df_yf$ref_date))
max_year <- lubridate::year(max(df_yf$ref_date))
today <- format(Sys.Date(), "%d/%m/%Y")

this_title <- stringr::str_glue(
  "Preços da Petrobrás ({min_year} - {max_year})"
)
this_subtitle <- "Preços ajustados a eventos corporativos"
this_caption <-  stringr::str_glue(
  "Dados obtidos do Yahoo Finance em {today}"
)

p1 <- p0 +
  labs(title = this_title,
       subtitle = this_subtitle,
       x = "Datas",
       y = "Preços",
       caption = this_caption
  )

print(p1)
#
#
#
#
#
p2 <- p1 +
  geom_line()

print(p2)
#
#
#
#
#
p3 <- p2 +
  geom_point() +
  theme_light()

print(p3)
#
#
#
#
#
plot_l <- list(p0, p1, p2, p3)

p <- cowplot::plot_grid(
  plotlist = plot_l,
  nrow = 2,
  ncol = 2,
  hjust = 0,
  labels = vdr::versions_string(length(plot_l))
  )

p
#
#
#
#
#
#
#
df_yf <- vdr::data_import(
  "Chapter03-bvsp-ftse-sp500-2015-2022.csv"
  )

glimpse(df_yf)
#
#
#
#
#
p <- ggplot(
  data = df_yf,
  mapping = aes(
    x = ref_date,
    y = cumret_adjusted_prices,
    color = ticker
    )
  ) + 
  geom_line()

p
#
#
#
#
#
p <- ggplot(
  data = df_yf,
  mapping = aes(
    x = ref_date,
    y = cumret_adjusted_prices,
    linetype = ticker
    )
  ) + 
  geom_line()

p
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| code-fold: true
colorspace::hcl_palettes(plot = TRUE)
```
#
#
#
#| code-fold: true
p <- ggplot(
  data = df_yf,
  mapping = aes(
    x = ref_date,
    y = cumret_adjusted_prices,
    color = ticker
    )
  ) + 
  geom_line(linewidth = 2)
#
#
#
#
#
#
#
#
#| code-fold: true
p
#
#
#
#
#
#
#
#
#| code-fold: true
p + colorspace::scale_color_discrete_qualitative('Cold') 
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#| code-fold: true
p <- ggplot(
  data = df_yf,
  mapping = aes(
    x = ref_date,
    y = cumret_adjusted_prices,
    color = cumret_adjusted_prices,
    group = ticker
    )
  ) + 
  geom_line(linewidth = 2)
#
#
#
#
#
#
#
#
#| code-fold: true
p
#
#
#
#
#
#
#
#
#| code-fold: true
p + colorspace::scale_color_continuous_sequential('Grays') 
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#| code-fold: true
colorspace::demoplot(
  colorspace::sequential_hcl(5, "Viridis"),
  type = "heatmap"
)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
# Gráfico base simples, independente do último `p` definido anteriormente
p_tema <- ggplot(
  data = df_yf,
  mapping = aes(x = ref_date, y = cumret_adjusted_prices, color = ticker)
) +
  geom_line() +
  labs(title = "Desempenho de índices",
       x = "Datas",
       y = "Valor acumulado")
#
#
#
#
#
#
#
#
#| code-fold: true
p_tema
#
#
#
#
#
#
#
#
#
#| code-fold: true
p_tema + theme_classic()
```
#
#
#
#
#
#
#
#
#
#
#| code-fold: true
df_yf <- vdr::data_import(
  "Chapter04-stocks-by-country-2015-2022.csv"
)

p <- ggplot(df_yf, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices, 
                color = ticker)) + 
geom_line() +
labs(title = "Desempenho de ações") +
theme_light() + 
facet_wrap(facets = "country", 
           nrow = 3)

p
#
#
#
#
#
#
#
#| code-fold: true
df_yf_filtered <- df_yf |>
  mutate(year = lubridate::year(ref_date)) |>
  filter(year >= 2020)

p <- ggplot(df_yf_filtered, 
            aes(x = ref_date, 
                y = cumret_adjusted_prices, 
                color = ticker)) + 
  geom_line() +
  labs(title = "Desempenho de ações") +
  theme_light() + 
  facet_grid(rows = vars(country), 
             cols = vars(year))

p
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| code-fold: true
library(ggplot2)

p <- ggplot(data = iris, 
            mapping = aes(y = Species, 
                          x = Sepal.Length)) + 
  geom_point()

f_fig <- tempfile(pattern = "fig-example-", 
                  fileext = '.png')
                  
ggsave(filename = f_fig,
       plot = p, 
       width = 10,
       height = 10,
       units = "cm",
       dpi = 300)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

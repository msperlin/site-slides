library(dplyr)

data_year <- 2019
br <- geobr::read_country(
  year = data_year, 
  showProgress = FALSE
)

dplyr::glimpse(br)


library(ggplot2)

p0 <- ggplot(data = br) + 
  geom_sf() + 
  theme_light()

x11(); p0


df_cities <- vdr::data_import(
  "Chapter07-latlong-cities-brazil.csv"
)

dplyr::glimpse(df_cities)

p1 <- p0 + 
  geom_point(data = df_cities,
             mapping = aes(y = latitude, x = longitude),
             size = 0.05, 
             color = "blue",
             alpha = 0.35) + 
  geom_point(data = df_cities |> filter(capital == TRUE),
             mapping = aes(y = latitude, x = longitude),
             size = 1.5,
             color = 'red') +           
  labs(title = "Cidades do Brasil",
       subtitle = "Capitais dos estados em vermelho",
       caption = "Dados do IBGE (2019)")

x11(); p1



df_ibge <- vdr::data_import(
  "Chapter07-data-ibge.csv"
)

dplyr::glimpse(df_ibge)

data_year <- 2010
states <- geobr::read_state(code_state = "all", 
                            year = data_year, 
                            showProgress = FALSE) |>
  left_join(df_ibge, by = c("code_state" = "codigo"))

p <- ggplot(data = states, 
            aes(fill = rendimento_mensal_domiciliar)) + 
  geom_sf() + 
  theme_light() + 
  labs(fill = "Rend. Mensal",
       title = "Renda Mensal Domiciliar por Estado",
       caption = "Dados do IBGE (2021)") + 
  colorspace::scale_fill_binned_diverging(
    "Blue-Red", 
    mid = median(states$rendimento_mensal_domiciliar))

x11(); p


library(ggmap)

google_key <- readr::read_lines('C:/Users/00141390/Insync/marceloperlin@gmail.com/Google Drive/98-pass-and-bash/.gmaps_api_key.txt')

register_google(
  key = google_key, 
  account_type = 'standard'
)

ggmap::geocode("Porto Alegre RS")

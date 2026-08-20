# Soluções das Atividades de Aula - ADFER Aula 02

# ==============================================================================
# BLOCO 1: Objetos e Pacotes
# ==============================================================================

# --- Exercício 1.1 ---
yvec <- c('text1', 'text2', 'text3', 'text4', 'text5', 'text6')
zvec <- paste0('text', 1:6)

print(yvec)
print(zvec)

# Verificação:
identical(yvec, zvec) # TRUE, pois paste0('text', 1:6) gera os mesmos 6 elementos


# --- Exercício 1.2 ---
# install.packages("fortunes")
library(fortunes)
fortune()


# --- Exercício 1.3 ---
# pak::pkg_install("msperlin/afedR3") ou remotes::install_github("msperlin/afedR3")
f_df <- afedR3::data_path("CH04_ibovespa.csv")
df <- readr::read_csv(f_df)
print(df)
# Finalidade: Encontra o caminho local do arquivo de exemplo empacotado no afedR3
# e o carrega em um data frame / tibble usando a biblioteca readr.


# --- Exercício 1.4 ---
v <- c(10, 20, "30")
class(v) # "character", porque a presença do texto "30" forçou a coerção implícita de todos os números para texto

# A operação direta v + 5 resulta em erro (non-numeric argument to binary operator):
# v + 5 

# Correção com conversão explícita:
v_num <- as.numeric(v)
v_num + 5


# ==============================================================================
# BLOCO 2: Interagindo com o SO, Internet e Produtividade
# ==============================================================================

# --- Exercício 2.1 ---
my_url <- "https://www.msperlin.com/files/afedr-files/afedR-code-and-data.zip"
zip_temp <- fs::file_temp(ext = ".zip")

download.file(url = my_url, 
              destfile = zip_temp)


# --- Exercício 2.2 ---
dir_to_unzip <- fs::path_temp("afedr_data")
fs::dir_create(dir_to_unzip)

unzip(zipfile = zip_temp, 
      exdir = dir_to_unzip)

fs::file_delete(zip_temp)

all_unzipped_files <- fs::dir_ls(dir_to_unzip, recurse = TRUE, type = "file")
n_files_unzip <- length(all_unzipped_files)
message("Total de arquivos descompactados: ", n_files_unzip)


# --- Exercício 2.3 ---
my_path <- .libPaths()[1]

all_dir <- fs::dir_ls(my_path, type = "directory")
n_pkgs <- length(all_dir)
message("Total de pacotes instalados: ", n_pkgs)


# --- Exercício 2.4 ---
all_files <- fs::dir_ls(my_path, type = "file", recurse = TRUE)
n_files_pkg <- length(all_files)
message("Média de arquivos por pacote: ", round(n_files_pkg / n_pkgs, 2))


# --- Exercício 2.5 ---
# install.packages("GetTDData")
df_yc <- GetTDData::get.yield.curve()
print(head(df_yc))


# --- Exercício 2.6 ---
# pak::pkg_install("tidyverse/ggplot2") ou remotes::install_github("tidyverse/ggplot2")
library(ggplot2)

df_sim <- data.frame(
  x = 1:10,
  y = rnorm(10)
)

ggplot(df_sim, aes(x = x, y = y)) +
  geom_point(color = "steelblue", size = 3) +
  theme_minimal() +
  labs(title = "Exemplo com ggplot2", x = "Eixo X", y = "Eixo Y")


# --- Exercício 2.7 (DESAFIO) ---
get_n_files <- function(path_in) {
  cli::cli_alert_info("Verificando: {path_in}")
  files <- tryCatch(
    fs::dir_ls(path_in, recurse = TRUE, type = "file", fail = FALSE),
    error = function(e) character(0)
  )
  n <- length(files)
  cli::cli_alert_success("\tEncontrados {n} arquivos")
  return(n)
}

# Usa o diretório do usuário para compatibilidade multiplataforma (Windows/Linux/macOS)
target_dir <- fs::path_home()
subdirs <- fs::dir_ls(target_dir, type = "directory")

n_files_vec <- sapply(subdirs, get_n_files)
top_5 <- head(sort(n_files_vec, decreasing = TRUE), 5)
print(top_5)

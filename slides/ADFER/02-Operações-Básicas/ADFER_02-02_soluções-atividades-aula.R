# 01
my_url <- "https://www.msperlin.com/files/afedr-files/afedR-code-and-data.zip"
zip_temp <- fs::file_temp(ext = '.zip')

download.file(url = my_url, 
              destfile = zip_temp)

# 02
dir_to_unzip <- "~"
unzip(zipfile = zip_temp, 
      exdir = dir_to_unzip)

fs::file_delete(zip_temp)

dir_to_check <- "~/Documents/afedR-code-and-data"
all_files <- fs::dir_ls(dir_to_check, 
                        recurse = TRUE)

n_files <- length(all_files)
n_files

# 03
my_path <- Sys.getenv("R_LIBS_USER")

all_dir <- fs::dir_ls(my_path, type = 'directory')

n_pkgs <- length(all_dir)
n_pkgs

# 04
all_files <- fs::dir_ls(my_path, type = 'file',
                        recurse = TRUE)
n_files <- length(all_files)

n_files/n_pkgs

# 05
install.packages("GetTDData")

df_yc <- GetTDData::get.yield.curve()
df_yc

readr::write_csv(df_yc, 'curva-juros.csv')

# 06
remotes::install_github("hadley/ggplot2")

library(ggplot2)

x11(); qplot(y = rnorm(10), 
             x = rnorm(10))

# 07
get_n_files <- function(path_in) {
  
  cli::cli_alert_info("fetching path {path_in}")
  all_files <- fs::dir_ls(path_in, recurse = TRUE,
                          type = "file", fail = FALSE)
  
  n_files <- length(all_files)
  cli::cli_alert_success("\tgot {n_files} files")
  
  return(n_files)
}

dir_at_root <- fs::dir_ls('C:/', 
                          type = 'directory')

dir_at_root

n_files_vec <- sapply(dir_at_root,
                      get_n_files)

sort(n_files_vec)

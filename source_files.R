
# R script: source_files.R

# Ad hoc function to source files from R sub-folder

# 1-2. First we create the path to the \R folder for each of the scripts we want to source
files <- list.files(here::here("R"),
                    full.names = TRUE,
                    pattern = "R$")

# 2-2. Adhoc function that sources all files from \R sub-folder

# Function 01: Source all files from R folder

source_all <-function(path = "R"){
  files <- list.files(here::here(path),
                      full.names = TRUE,
                      pattern = "R$")
  suppressMessages(lapply(files,source))
  invisible(path)
}

# Invoke this source_all() ad hoc function to run all R scripts
source_all()

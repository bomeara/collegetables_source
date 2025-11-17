rm(list=ls())
Sys.setenv(RSTUDIO_PANDOC="/usr/local/bin/pandoc")
system("export PATH=$PATH:/usr/local/bin")
#Sys.setenv(R_MAX_VSIZE = 16e10)
library(targets)
source("_packages.R")
source("R/functions.R")

#tar_invalidate(index_et_al)

#tar_invalidate(db_from_access)
#ar_invalidate(ipeds_directly)

tar_option_set(memory = "transient", garbage_collection = TRUE)


# Only render site if needing to do new pages

#rmarkdown::render_site()
tar_make(callr_function = NULL)
#tar_make()

#system("cp -r docs/* ../collegetables_site_x2024")
#system("cp *html docs")
#system("cp *html ../collegetables_site_x2024")
#system("cp CNAME docs/CNAME")


#system('rsync -avz --delete --exclude=".*" docs/ ../collegetables_site_x2024/')
#system("cp CNAME ../collegetables_site_x2024/CNAME")

system("open docs/index.html")


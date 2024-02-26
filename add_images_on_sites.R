# run in collegetables_source, it'll commit in sites dir

setwd("/Users/bomeara/Documents/MyDocuments/GitClones/collegetables_site")
system("git commit -uno -m 'update site' -a")
system("git push")
system("git prune")
system("git add *html")
system("git commit -uno -m 'update site'")
system("git push")
system("git add *files")
system("git commit -uno -m 'update site'")

files <- list.files("/Users/bomeara/Documents/MyDocuments/GitClones/collegetables_site/images", pattern = "png", full.names = TRUE, recursive = TRUE)

# for each set of 50 files, commit them
for (i in seq(1, length(files), 25)) {
  system(paste("git add", paste(files[i:(i+24)], collapse = " ")))
  system("git commit -uno -m 'add images'")
  system("git push")
}
# Xavier de Pedro. Copyleft 2016 (cc-by-sa). xavier.depedro@vhir.org - xavier.depedro@seeds4c.org
# From 
# http://www.r-bloggers.com/when-documents-become-databases-tabulizer-r-wrapper-for-tabula-pdf-table-extractor/
# https://github.com/leeper/tabulizer/blob/master/vignettes/tabulizer.Rmd
# https://github.com/leeper/tabulizer

if(!require("ghit")){
  install.packages("ghit")
}
# on 64-bit Windows
#ghit::install_github(c("leeper/tabulizerjars", "leeper/tabulizer"), INSTALL_opts = "--no-multiarch")
# elsewhere
ghit::install_github(c("leeper/tabulizerjars", "leeper/tabulizer"))

# Useful commands
library("tabulizer")

test_demo <- F # Enable this flag if you'd like to play with some demo instructions and documents.

if (test_demo) {
  
  f <- system.file("examples", "data.pdf", package = "tabulizer")
  
  # extract table from first page of example PDF
  tab <- extract_tables(f, pages = 1)
  head(tab[[1]])
  extract_tables(f, pages = 2, method = "data.frame")
  str(extract_tables(f, pages = 2, area = list(c(126, 284, 174, 417)), guess = FALSE, method = "data.frame"))
  extract_areas(f, 1)
  extract_tables(f, method = "csv")
  
  f2 <- "https://github.com/leeper/tabulizer/raw/master/inst/examples/data.pdf"
  extract_tables(f2, pages = 2)
  
} 

# Let's fire the task on that data set from 
# http://www.aspb.cat/quefem/docs/InformeSalut2014_2010.pdf
# for pages: 74-77 (which are page numbers in the real pdf document: 75-78)
pdffile <- "InformeSalut2014_2010.pdf"

# Be aware of where you will download the file (adapt as needed with setwd("path") )
getwd()
download.file(url="http://www.aspb.cat/quefem/docs/InformeSalut2014_2010.pdf", destfile=pdffile)

p <- pdffile
#extract_tables(p, pages = c(75:78), method = "csv")
extract_areas(p, pages = c(75:78), method = "csv")

# Open Those csv files in LibreOffice or similar, and marge by hand, since this is a once way process
# and not a repetitive task that would need to be automated some way, etc.
# (easier and faster by hand for this use case)
# And fill in the district blanks so that it behaves like a proper database
# Sand save as ODS, or Excel, etc.
# Done!

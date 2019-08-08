For every data set:

1. Save data and metadata in ExpHub
  - relevant scripts/Rmds in `inst/scripts/`
    - `make-data.Rmd` -- describe how the data stored in ExpHub was obtained and saved
        ```
        ## describe how the data was obtained and processed
        count.file <- read.table("file.txt")
        counts <- as.matrix(count.file)
        coldata <- DataFrame(row.names = colnames(count.file),
                            condition = c("A","A","B","B"))
                            
        ## save the data
        path <- file.path("myPackage", "storeddata", "1.0.0")
        dir.create(path, showWarnings-FALSE, recursive=TRUE)
        
        saveRDS(counts, file = file.path(path, "counts.rds"))
        saveRDS(coldata, file = file.path(path, "coldata.rds"))
        ```
    - `make-metadata.R` -- generate a csv file that will be stored in the `inst/extdata` folder of the package
        ```
        write.csv(file = "../extdata/metadata-storeddata.csv", stringsAsFactors = FALSE, data.frame(...) )
        ```
2. Provide function to generate the R object that will be exposed to the user
  - 
  - `.create_se()`

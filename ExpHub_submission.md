For **every data set**:

## 1. Save data and metadata in ExpHub (documentation by [ExperimentHub](https://bioconductor.org/packages/3.10/bioc/vignettes/ExperimentHub/inst/doc/CreateAnExperimentHubPackage.html))
  - .R or .Rmds stored in `inst/scripts/`
    - `make-data.Rmd` -- describe how the data stored in ExpHub was obtained and saved. [example Rmd](https://github.com/LTLA/scRNAseq/blob/master/inst/scripts/make-nestorowa-hsc-data.Rmd)
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
    - `make-metadata.R` -- generate a csv file that will be stored in the `inst/extdata` folder of the package, the result can look [like this](https://github.com/LTLA/scRNAseq/blob/master/inst/extdata/metadata-nestorowa-hsc.csv). [example R script](https://github.com/LTLA/scRNAseq/blob/master/inst/scripts/make-nestorowa-hsc-metadata.R)
        ```
        write.csv(file = "../extdata/metadata-storeddata.csv", stringsAsFactors = FALSE, data.frame(...) )
        ```
## 2. Provide functions to generate the R object that will be exposed to the user
  - scripts in `R/`
    - `get_storeddata.R`
        ```
        get_data_hpca <- function() {
            version <- "1.0.0"
            se <- .create_se(file.path("hpca", version), has.rowdata=FALSE)
        }
        ```
    - `create_se.R`

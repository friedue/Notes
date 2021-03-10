# Summarizing GO terms using semantic similarity

[REVIGO](http://revigo.irb.hr/) clusters GO terms based on their semantic similarity, p-values, and relatedness resulting in a hierarchical clustering where less dispensable terms are placed closer to the root. The clustering is visualized in a clustered heatmap showing the p-values for each term. 

REVIGO generates multiple plots; the easiest way to obtain them in high quality is to download the R scripts that it offers underneath each of the options (e.g. scatter plot, tree map) and to run those yourself.
 
Here, I've downloaded the R script after selecting the treemap plot ("Make R script for plotting").
The script is aptly named `REVIGO_treemap.r`. 
The plot can be generated as easily as this:

```{r eval=FALSE}
## this will generate a PDF file named "REVIGO_treemap.pdf" in your current
## working directory
source("~/Downloads/REVIGO_treemap.r")  
```

Since I personally don't like plots being immediately printed to PDF (much more difficult to include them in an Rmarkdown!), 
I've tweaked the function a bit; it's essentially the original REVIGO script that I downloaded minus the part where the `revigo.data` object is generated and with a couple more options to tune the resulting heatmap.

```{r define_own_treemap_function}
REVIGO_treemap <- function(revigo.data, col_palette = "Paired",
                           title = "REVIGO Gene Ontology treemap", ...){
  stuff <- data.frame(revigo.data)
  names(stuff) <- c("term_ID","description","freqInDbPercent","abslog10pvalue",
                    "uniqueness","dispensability","representative")
  stuff$abslog10pvalue <- as.numeric( as.character(stuff$abslog10pvalue) )
  stuff$freqInDbPercent <- as.numeric( as.character(stuff$freqInDbPercent) )
  stuff$uniqueness <- as.numeric( as.character(stuff$uniqueness) )
  stuff$dispensability <- as.numeric( as.character(stuff$dispensability) )
  # check the treemap command documentation for all possible parameters - 
  # there are a lot more
  treemap::treemap(
    stuff,
    index = c("representative","description"),
    vSize = "abslog10pvalue",
    type = "categorical",
    vColor = "representative",
    title = title,
    inflate.labels = FALSE,      
    lowerbound.cex.labels = 0,   
    bg.labels = 255,
    position.legend = "none",
    fontsize.title = 22, fontsize.labels=c(18,12,8),
    palette= col_palette, ...
  )
}
```

I still need the originally downloaded script to generate the `revigo.data` object, which I will then pass onto my newly tweaked function.
Using the command line (!) tools `sed` and `egrep`,  I'm going to only keep the lines between the one starting with "revigo.data" and the line starting with "stuff".
The output of that will be parsed into a new file, which will only generate the `revigo.data` object that I'm after (no PDF!).

```{r}
# the system function allows me to run command line stuff outside of R
# just for legibility purposes, I'll break up the command into individual 
# components, which I'll join back together using paste()
sed_cmd <- "sed -n '/^revigo\\.data.*/,/^stuff.*/p'"
fname <- "~/Downloads/REVIGO_treemap.r"
egrep_cmd <- "egrep '^rev|^c'"
out_fname <- "~/Downloads/REVIGO_myData.r"
system(paste(sed_cmd, fname, "|", egrep_cmd, ">", out_fname))
## upon sourcing; no treemap PDF will be generated, but the revigo.data object
## should appear in your R environment
source("~/Downloads/REVIGO_myData.r")
REVIGO_treemap(revigo.data)
```

If this is all too tedious, you may want to check out a recent Python implementation of REVIGO's principles: [GO-figure](https://www.biorxiv.org/content/10.1101/2020.12.02.408534v1.full).
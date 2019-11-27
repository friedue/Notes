## Karyotype plots

- Cytogenetic G-banding data (G-banding = Giemsa staining based)
- Giemsa bands are related to functional nuclear processes such as replication or transcription in the following points
- G bands are late- replicating
- chromatins in G bands are more condensed
- G-band DNA is localized at the nuclear periphery
- G bands are homoge- neous in GC content and essentially consist of GC-poor iso- chores

[PNAS 2002](doi.dx.org/10.1073/pnas.022437999)

Recommended package: [karyoploteR](https://bernatgel.github.io/karyoploter_tutorial/) ([vignette](https://bioconductor.org/packages/release/bioc/vignettes/karyoploteR/inst/doc/karyoploteR.html))

![](https://bernatgel.github.io/karyoploter_tutorial/Examples/MultipleDataTypes/images/Figure-1.png)

>Chemically staining the metaphase chromosomes results in a alternating dark and light banding pattern, which could provide information about abnormalities for chromosomes. Cytogenetic bands could also provide potential predictions of chromosomal structural characteristics, such as repeat structure content, CpG island density, gene density, and GC content.
biovizBase package provides utilities to get ideograms from the UCSC genome browser, as a wrapper around some functionality from rtracklayer. It gets the table for cytoBand and stores the table for certain species as a GRanges object.
We found a color setting scheme in package geneplotter, and we implemented it in biovisBase.
The function .cytobandColor will return a default color set. You could also get it from options after you load biovizBase package.
And we recommended function getBioColor to get the color vector you want, and names of the color is biological categorical data. This function hides interval color genenerators and also the complexity of getting color from options. You could specify whether you want to get colors by default or from options, in this way, you can temporarily edit colors in options and could change or all the graphics. This give graphics a uniform color scheme.

[BioViz Vignette](https://www.bioconductor.org/packages/release/bioc/vignettes/biovizBase/inst/doc/intro.pdf)

- brown/red corresponds to "stalk"

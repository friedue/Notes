marker genes expressed >= 4x than the rest of the genes, either Seurat or Simlr algorithm will work [(Abrams 2018)][Abrams 2018]

## Dropouts

Current hypothesis:

* small amount of starting material and low capture efficiency &rarr; only a small fraction of the mRNA molecules in the cell is captured and amplified
* large number of zero counts (but apparently not zero-inflated as argued i.a. by [Yanai][Wagner 2018] and [Svensson][Valentin Nov2017], i.e. "observed zeros are consistent with count statistics, and droplet scRNA-seq protocols are not producing higher numbers of dropouts than expected")
* bimodal distributions 

[(Ye 2017)][Ye 2017]:
* SCDE (Kharchenko et al, 2015) assumes all zeroes are technical zeroes
* MAST (Finak et al., 2015) categorizes all zero counts as 'unexpressed'

The `scone` package contains lists of genes that are believed to be ubiquitously and even uniformly expressed across human tissues. If we assume these genes are truly expressed in all cells, we can label all zero abundance observations as drop-out events. [scone vignette][scone]

## Normalization

global scaling methods will fail if there's a large number of DE genes &rarr; per-clustering using rank-based methods followed by normalization within each group is preferable for those cases (see `scran` implementation)

---------

[Abrams 2018]: https://doi.org/10.1101/247114 "A computational method to aid the design and analysis of single cell RNA-seq experiments for cell type identification"
[scone]: 
[Valentin Nov2017]: http://www.nxn.se/valent/2017/11/16/droplet-scrna-seq-is-not-zero-inflated 
[Valentin Jan2018]: http://www.nxn.se/valent/2018/1/30/count-depth-variation-makes-poisson-scrna-seq-data-negative-binomial
[Wagner 2018]: https://www.biorxiv.org/content/early/2018/01/24/217737
[Ye 2017]: http://dx.doi.org/10.1101/225177 "DECENT: Differential Expression with Capture Efficiency AdjustmeNT for Single-Cell RNA-seq Data"

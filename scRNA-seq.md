* [Dropouts](#dropouts)
* [Normalization](#norm)
* [Smoothening & Imputation](#smooth)
* [Dimensionality reduction & clustering](#dims)
* [DE](#de)


-------------------------------

<a name="dropouts"></a>
## Dropouts

Current hypothesis:

* small amount of starting material and low capture efficiency &rarr; only a small fraction of the mRNA molecules in the cell is captured and amplified
* large number of zero counts (but apparently not zero-inflated as argued i.a. by [Yanai][Wagner 2018] and [Svensson][Valentin Nov2017], i.e. "observed zeros are consistent with count statistics, and droplet scRNA-seq protocols are not producing higher numbers of dropouts than expected")
* bimodal distributions 

[(Ye 2017)][Ye 2017]:
* SCDE (Kharchenko et al, 2015) assumes all zeroes are technical zeroes
* MAST (Finak et al., 2015) categorizes all zero counts as 'unexpressed'

The `scone` package contains lists of genes that are believed to be ubiquitously and even uniformly expressed across human tissues. If we assume these genes are truly expressed in all cells, we can label all zero abundance observations as drop-out events. [(scone vignette)][scone]

```
data(housekeeping, package = "scone")
```

### scone's approach

[`scone`'s][scone] approach to identifying transcripts that are worth keeping:

```
# Initial Gene Filtering: 
# Select "common" transcripts based on proportional criteria.
num_reads = quantile(assay(fluidigm)[assay(fluidigm) > 0])[4]
num_cells = 0.25*ncol(fluidigm)
is_common = rowSums(assay(fluidigm) >= num_reads ) >= num_cells

# Final Gene Filtering: Highly expressed in at least 5 cells
num_reads = quantile(assay(fluidigm)[assay(fluidigm) > 0])[4]
num_cells = 5
is_quality = rowSums(assay(fluidigm) >= num_reads ) >= num_cells
```

### My own approach using dropout rates

```
## calculate drop out rates
gns_dropouts <- calc_dropouts_per_cellGroup(sce, genes = rownames(sce), split_by = "condition")

## define HK genes for display
hk_genes <- unique(c(grep("^mt-", rownames(sce), value=TRUE, ignore.case=TRUE), # mitochondrial genes
            grep("^Rp[sl]", rownames(sce), value=TRUE, ignore.case=TRUE))) # ribosomal genes

## plot
ggplot(data = gns_dropouts,
        aes(x = log10(mean.pct.of.counts),
            y = log10(pct.zeroCov_cells + .1),
        text = paste(gene, condition, sep = "_"))) + 
  geom_point(aes(color = condition), shape = 1, size = .5, alpha = .5) +
  ## add HK gene data points
  geom_point(data = gns_dropouts[gene %in% hk_genes],
             aes(fill = condition), shape = 22, size = 4, alpha = .8) +
   facet_grid(~condition) + 
   ggtitle("With housekeeping genes")
```

<a name="norm"></a>
## Normalization

global scaling methods will fail if there's a large number of DE genes &rarr; per-clustering using rank-based methods followed by normalization within each group is preferable for those cases (see `scran` implementation)

<a name="smooth"></a>
## Smoothening

| Publication                        | Method          | Package |
|------------------------------------|-----------------|---------|
| [Wagner, Yatai, 2018][Wagner 2018] | knn-smoothing   | [github.com/yanailab/knn-smoothing](http://github.com/yanailab/knn-smoothing) |
| [Dijk et al., 2017][Dijk 2017]     | manifold learning using diffusion maps | [github](https://github.com/KrishnaswamyLab/magic) |

* there is no guarantee that a smoothened expression profile accurately reflects an existing cell population
* might be a good idea to use scater's approach of first clustering and then smoothening within every cluster of similar cells (MAGIC tries that inherently)
* after smoothening, values of different genes might no longer independent, which violates basic assumption of most DE tests (Wagner's method generates a dependency of the cells, rather than genes)

<a name="dims"></a>
## Dimensionality reduction and clustering

marker genes expressed >= 4x than the rest of the genes, either Seurat or Simlr algorithm will work [(Abrams 2018)][Abrams 2018]

### t-SNE

great write up: ["t-sne explained in plain javascript"](https://beta.observablehq.com/@nstrayer/t-sne-explained-in-plain-javascript)

### PCA

Avril Coghlan's write-up of [PCA](http://little-book-of-r-for-multivariate-analysis.readthedocs.io/en/latest/src/multivariateanalysis.html#principal-component-analysis)

<a name="de"></a>
## DE

[Soneson & Robinson][Soneson 2017]:

* Pre-filtering of lowly expressed genes can have important effects on the results, particularly for some of the methods originally developed for analysis of bulk RNA-seq data
* Generally, methods developed for bulk RNA-seq analysis do not perform notably worse than those developed specifically for scRNA-seq.

---------

[Abrams 2018]: https://doi.org/10.1101/247114 "A computational method to aid the design and analysis of single cell RNA-seq experiments for cell type identification"
[Dijk 2017]: https://www.biorxiv.org/content/early/2017/02/25/111591
[scone]: http://www.bioconductor.org/packages/release/bioc/vignettes/scone/inst/doc/sconeTutorial.html "Scone Vignette"
[Soneson 2017]: https://doi.org/10.1101/143289 "Bias, Robustness And Scalability In Differential Expression Analysis Of Single-Cell RNA-Seq Data"
[Valentin Nov2017]: http://www.nxn.se/valent/2017/11/16/droplet-scrna-seq-is-not-zero-inflated 
[Valentin Jan2018]: http://www.nxn.se/valent/2018/1/30/count-depth-variation-makes-poisson-scrna-seq-data-negative-binomial
[Wagner 2018]: https://www.biorxiv.org/content/early/2018/01/24/217737
[Ye 2017]: http://dx.doi.org/10.1101/225177 "DECENT: Differential Expression with Capture Efficiency AdjustmeNT for Single-Cell RNA-seq Data"

# Gene set enrichment analyses

## Classical GSEA

* reference: Subramanian et al., 2005 (PNAS)
* genes are usually ranked based on comparisons between 2 conditions, e.g. logFC
* ES = maximal deviation from zero
    * neg. ES --> genes are enriched at the bottom of the list
    * pos. ES --> genes are enriched at the top of the list  

![GSEA02](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA02.png)

![GSEA](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA.png)

## ssGSEA
* reference: Barbie et al., 2009 (Nature)
* genes are ranked based on their expression value within one sample
* ES = sum of the differences between the ECDF of the genes within a gene set and the ECDF of the genes outside the gene set
    * this is not a Kolmogorov-Smirnov statistic!  

![ssGSEA](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA_ssGSEA.png)

> A positive enrichment score indicates a positive correlation between genes in the gene set and the tumor sample expression profile.
(Verhaak et al., 2010)

For the following image, they:
1. determined gene sets typical for oligodendrocytes, neurons, astrocytes and cultured astroglia
2. ssGSEA using these gene sets with gene expression profiles of different samples

![Verhaak](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA_Verhaak.png)

In Barbie et al., they found RAS signatures in mutant KRAS lung adenocarcinomas correlate with NF-κB but not IRF3 signatures (red denotes activation, blue denotes inactivation)

![Barbie](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA_Barbie.png)

### differences to GSEA

* emphasis on gene sets that are concordantly active or repressed
* ES represents the sum of differences between genes within the set and genes outside the set while classical GSEA ES represents the maximum difference

>In the regular GSEA a similar ES is used, but the __weight is typically set to 1__. (Barbie et al., 2009)

>If one is interested in __penalizing sets for lack of coherence__ or to discover sets with any type of nonrandom distribution of tags, a value p < 1 might be appropriate. (Subramanian et al., 2005)

>Also, instead of the sumer over _i_, the [ssGSEA] ES is computed according to the largest difference. (Barbie et al., 2009)

> As you progress along the rank ordered list of genes, the algorithm looks for a __difference__ in encountering the genes in the gene set compared to the non-gene set genes. If the gene set genes are encountered relatively early in the list the ES is negative, late in the list the ES is positive and encountered at roughly the same rate as the non-gene set genes the ES is near 0. (Charlie Witthaker, see references)


## GSVA
* reference: Haenzelmann et al., 2013 (BMC Bioinformatics)
* R package

* two ES calculations are offered (via `mx.diff` option)
    * _classical ES_: maximum deviation from 0 of the random walk of the _j_th sample w.r.t. _k_th gene set
        - this tends to be bimodal
    * _alternative ES_: | ESpos | - | ESneg |
        - emphasizes gene sets that show enrichment in only one tail of the distribution
    * the alternative ES score is not available when `method = "ssGSEA"`


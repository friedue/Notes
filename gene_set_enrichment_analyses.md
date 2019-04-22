# Gene set enrichment analyses

* [Classical GSEA - background](#classGSEA)
	*	[R implementations](#rgseas) 
		* [Fast GSEA](#fgsea)
		* [enrichPW](#enrichpw)
		* [time-course GSA](#tcgsa)
* [single sample GSEA](#ssgsesa)
	* [Differences to GSEA](#ssGSEAvsGSEA) 
* [GSVA](#GSVA)

<a name="classGSEA"></a>
## Classical GSEA

* reference: Subramanian et al., 2005 (PNAS)
* genes are usually ranked based on comparisons between 2 conditions, e.g. logFC
* ES = maximal deviation from zero
    * neg. ES --> genes are enriched at the bottom of the list
    * pos. ES --> genes are enriched at the top of the list  

![GSEA02](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA02.png)

![GSEA](https://raw.githubusercontent.com/friedue/Notes/master/images/GSEA.png)

### Downloading `gmt` files

The MSigDB sets can be downloaded from the Broad: [http://software.broadinstitute.org/gsea/msigdb/collections.jsp](http://software.broadinstitute.org/gsea/msigdb/collections.jsp).

Some examples:

| MsigDB Name | Meaning |
|-------------|----------|
| `C2*gmt`    | curated gene sets |
| `H*gmt`     | Hallmark gene set |
| `C3*gmt`    | Motif gene sets |
| `C3.tft.*gmt`|TF targets|
|`C4.cm.*gmt`  | Cancer moduls (individual modules have non-descript names!) |
| `C6.all.*gmt` | oncogenic signatures |
| `C7.all*gmt`  | immunologic signatures |

<a name="rgseas"></a>
### R implementations

GSEA is usually run via the Broad Institute's JAVA implementation.
R has numerous solutions, too. 
They usually rely on the user to download the gene sets/pathways (see above for donwloading `gmt` files).

Info about how to generate self-built `gmt` files are [here](https://cran.r-project.org/web/packages/TcGSA/vignettes/TcGSA_userguide.html#self-built-gmt).


<a name="fgsea"></a>
#### 1. fgsea

A fast implementation of GSEA.

The preranked gene set enrichment analysis takes as input two objects: an array of gene statistic values S and a list of query gene sets P. The goal of the analysis is to determine which of the gene sets from P has a non-random behavior.

>To assess the algorithm performance we ran the algorithm on a T-cells differentiation dataset [4]. The ranking was obtained from differential gene expression analysis for Naive vs. Th1 states using limma [2]. From that results we selected 12000 genes with the highest mean expression levels.
[Ref](https://www.biorxiv.org/content/10.1101/060012v1.full)

More details [at Dave Tang's Blog](https://davetang.org/muse/2018/01/10/using-fast-preranked-gene-set-enrichment-analysis-fgsea-package/) including example code for generating a ranked list.

```
library(fgsea)

## 1. read in the gmt file
pw_oncoSig <- fgsea::gmtPathways("c6.all.v6.2.entrez.gmt")

## 2. generate a sorted named vector where the values correspond
## to the ranking statistic and the names to ENTREZ IDs
ranks <- tibble::deframe( x = data.frame( lfc_dt[!is.na(ENTREZID),
                                                  mean(get(rank_by)),
                                                  by = "ENTREZID"]) )
ranks <- sort(ranks, decreasing = TRUE)

### 3. run fGSEA
fgsea_oncoSig <- fgsea(pathways = pw_oncoSig, stats = ranks,
                 minSize = 15, maxSize = 500, nperm = 100000)
```

For the conversion to ENTREZ IDs, this function is handy:

```
clusterProfiler::bitr(t_tx$gene_symbol, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db")
```

One can also use REACTOME (or KEGG) pathways with `fgsea`:

```
fgsea::reactomePathways(genes = an$ENTREZID)
```

For displaying the results, `fgsea::plotGseaTable ` and `fgsea::plotEnrichment` are helpful:

```
## Table
topPW_Up <- fgsea_result[ES > 0][head(order(pval), n=n_pw), pathway]
topPW_Down <- fgsea_result[ES < 0][head(order(pval), n=n_pw), pathway]
topPW <- c(topPW_Up, rev(topPW_Down))
P <- plotGseaTable(original_pws[topPW], stats =  ranks, fgseaRes = fgsea_result,  gseaParam = 0.5)  
```

```
## single PW enrichment plot
tPW <- fgsea_result[ES > 0][head(order(pval), n=1), pathway]
P <- plotEnrichment(pathway = orginal_pws[[tPW]], ranks)
P + ggtitle("Most strongly enriched pathway")
```

<a name="enrichpw"></a>
#### 2. enrichPW (ReactomePA package)

This is useful because it can directly be used with `clusterProfiler::compareClusters`

Based on [Yu et al, 2016](https://dx.doi.org/10.1039/C5MB00663E).

* the input gene ID should be Entrez gene ID (see `clusterProfiler::bitr` for a conversion function)
* This approach will find genes where the difference is large, but it will not detect a situation where the difference is small, but evidenced in coordinated way in a set of related genes. Gene Set Enrichment Analysis (GSEA)(Subramanian et al. 2005) directly addressed this limitation. All genes can be used in GSEA; GSEA aggregates the per gene statistics across genes within a gene set, therefore making it possible to detect situations where all genes in a predefined set change in a small but coordinated way
* uses the fGSEA implementation described above [reference](http://bioconductor.org/packages/release/bioc/vignettes/DOSE/inst/doc/GSEA.html)

Instructions for preparing the geneList were taken from [here](https://github.com/GuangchuangYu/DOSE/wiki/how-to-prepare-your-own-geneList) -- basically, one needs a named and sorted vector of a rank statistic, the same as for fgsea [(see above)](#fgsea).

```
## prepare geneList
d = read.csv(your_csv_file)
## assume 1st column is ID
## 2nd column is FC

## feature 1: numeric vector
geneList = d[,2]
## feature 2: named vector
names(geneList) = as.character(d[,1])
## feature 3: decreasing order
geneList = sort(geneList, decreasing = TRUE)

```

```
y <- gsePathway(geneList, nPerm=10000,
                pvalueCutoff=0.2,
                pAdjustMethod="BH", verbose=FALSE)
res <- as.data.frame(y)
```

<a name="tcgsa"></a>
#### 3. TcGSA: time-course GSA

[Time-course Gene Set Enrichment Analysis](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004310) and its [vignette](https://cran.r-project.org/web/packages/TcGSA/vignettes/TcGSA_userguide.html)

3 inputs are required to run TcGSA:

* The gene set object: `gmt`
* The **gene expression matrix**: The gene expression should already be normalized before using TcGSA. In the rownames, the name of each probe/gene must match with the name of probes/genes in the gmt object.
* The **design data** matrix: i.e., sample info table with samples = rows


<a name="ssGSEA"></a>
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

<a name="ssGSEAvsGSEA"></a>
### differences to GSEA

* emphasis on gene sets that are concordantly active or repressed
* ES represents the sum of differences between genes within the set and genes outside the set while classical GSEA ES represents the maximum difference

>In the regular GSEA a similar ES is used, but the __weight is typically set to 1__. (Barbie et al., 2009)

>If one is interested in __penalizing sets for lack of coherence__ or to discover sets with any type of nonrandom distribution of tags, a value p < 1 might be appropriate. (Subramanian et al., 2005)

>Also, instead of the sumer over _i_, the [ssGSEA] ES is computed according to the largest difference. (Barbie et al., 2009)

> As you progress along the rank ordered list of genes, the algorithm looks for a __difference__ in encountering the genes in the gene set compared to the non-gene set genes. If the gene set genes are encountered relatively early in the list the ES is negative, late in the list the ES is positive and encountered at roughly the same rate as the non-gene set genes the ES is near 0. (Charlie Witthaker, see references)


<a name="GSVA"></a>
## GSVA

* reference: Haenzelmann et al., 2013 (BMC Bioinformatics)
* R package

* two ES calculations are offered (via `mx.diff` option)
    * _classical ES_: maximum deviation from 0 of the random walk of the *j*th sample w.r.t. *k*th gene set
        - this tends to be bimodal
    * _alternative ES_: `| ESpos | - | ESneg |`
        - emphasizes gene sets that show enrichment in only one tail of the distribution
    * the alternative ES score is not available when `method = "ssGSEA"`


# Gene set enrichment analyses

* [Classical GSEA - background](#classGSEA)
	*	[R implementations](#rgseas) 
		* [Fast GSEA](#fgsea)
		* [clusterProfiler::GSEA](#clusterProfilerGSEA)
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

<a name="clusterProfilerGSEA"></a>
#### 2. clusterProfiler::GSEA

```
library(clusterProfiler)
# parse the gmt file into a TERM2GENE data.frame 
c5 <- read.gmt(gmtfile)

## alternatively, there's a function to retrieve specific sets directly:
msigdbr(species = "Homo sapiens", category = "C3") %>%  dplyr::select(gs_name, entrez_gene)

data(geneList, package="DOSE") # named and sorted vector where the names are ENTREZ IDs and the values are some rank statistic
egmt_gsea <- GSEA(geneList, TERM2GENE=c5, verbose=FALSE)

## hypergeometric enrichment analysis is also possible
gene <- names(geneList)[abs(geneList) > 2]
egmt_enricher <- enricher(gene, TERM2GENE=c5)
```

The results can be used with:

* `barplot` or `dotplot` [Reference](http://guangchuangyu.github.io/2015/06/dotplot-for-enrichment-result/), [clusterProfiler book](https://yulab-smu.github.io/clusterProfiler-book/)
    - shows the number of genes associated with the first 50 terms (size) and the p-adjusted values for these terms (color)
    - x-axis can be gene count or gene ratio
    - count = core genes
    - gene ratio = Count/setSize (# genes related to GO term / total number of sig genes) [Ref4](https://hbctraining.github.io/DGE_workshop_salmon/lessons/functional_analysis_2019.html)
* `emapplot` [Reference 1](https://www.r-bloggers.com/enrichment-map/)
    - relationship between the top 50 most significantly enriched GO terms (padj.), by grouping similar terms together [Ref4](https://hbctraining.github.io/DGE_workshop_salmon/lessons/functional_analysis_2019.html)
    - size of the terms represents the number of genes that are significant from our list [Ref4](https://hbctraining.github.io/DGE_workshop_salmon/lessons/functional_analysis_2019.html) 
    - network-based visualization method for gene-set enrichment results
    - nodes = gene sets, edges = gene overlap between gene sets
    - This technique finds functionally coherent gene-sets, such as pathways, that are statistically over-represented in a given gene list. [Reference 2](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2981572/)
    - Automated network layout groups related gene-sets into network clusters; mutually overlapping gene sets are tend to cluster together,
    - `clusterProfiler` provides the R implementation of the [original cytoscape enrichment map](http://baderlab.org/Software/EnrichmentMap/)
* `cnetplot` = category netplot
    - depicts the linkages of genes and biological concepts (e.g. GO terms or KEGG pathways) as a network [Ref 3](https://yulab-smu.github.io/clusterProfiler-book/chapter12.html#gene-concept-network)
    - shows the relationships between the genes associated with the top five most significant GO terms and the fold changes of the significant genes associated with these terms (color) [Ref4](https://hbctraining.github.io/DGE_workshop_salmon/lessons/functional_analysis_2019.html) 
    - size of the GO terms reflects the pvalues of the terms
    - ![](https://yulab-smu.github.io/clusterProfiler-book/clusterProfiler_files/figure-html/unnamed-chunk-45-1.png)
* `heatplot`
    - ![](https://yulab-smu.github.io/clusterProfiler-book/clusterProfiler_files/figure-html/unnamed-chunk-46-2.png)
    
    ```
    If you are interested in significant processes that are not among the top five, you can subset your ego dataset to only display these processes:
    ## Subsetting the ego results without overwriting original `ego` variable
    ego2 <- ego
    ego2@result <- ego@result[c(1,3,4,8,9),]
    
    ## Plotting terms of interest
    cnetplot(ego2, 
             categorySize="pvalue", foldChange=OE_foldchanges, showCategory = 5, vertex.label.font=6)
    ```
    ![](https://hbctraining.github.io/DGE_workshop_salmon/img/cnetplot-2_salmon.png)
    
* `gseaplot(egmt_gsea, geneSetId = "X")` and `gseaplot2(edo2, geneSetID = 1:3, pvalue_table = TRUE, color = c("#E495A5", "#86B875", "#7DB0DD"), ES_geom = "dot")`
    - ![](https://yulab-smu.github.io/clusterProfiler-book/clusterProfiler_files/figure-html/unnamed-chunk-54-1.png)
* `gsearank`
    - ![](https://yulab-smu.github.io/clusterProfiler-book/clusterProfiler_files/figure-html/unnamed-chunk-57-1.png)

<a name="enrichpw"></a>
#### 2. enrichPW (ReactomePA package)

This is useful because its output can directly be used with `clusterProfiler::compareClusters`.
However, it only performs GSEA on the REACTOME pathways.

Based on [Yu et al, 2016](https://dx.doi.org/10.1039/C5MB00663E).

* the input gene ID should be Entrez gene ID (see `clusterProfiler::bitr` for a conversion function)
* This approach will find genes where the difference is large, but it will not detect a situation where the difference is small, but evidenced in coordinated way in a set of related genes. Gene Set Enrichment Analysis (GSEA)(Subramanian et al. 2005) directly addressed this limitation. All genes can be used in GSEA; GSEA aggregates the per gene statistics across genes within a gene set, therefore making it possible to detect situations where all genes in a predefined set change in a small but coordinated way
* uses the fGSEA implementation described above [reference](http://bioconductor.org/packages/release/bioc/vignettes/DOSE/inst/doc/GSEA.html)

Instructions for preparing the geneList were taken from [here](https://github.com/GuangchuangYu/DOSE/wiki/how-to-prepare-your-own-geneList) -- basically, one needs a named and sorted vector of a rank statistic, the same as for fgsea [(see above)](#fgsea).

```
## get ENTREZ IDs (can also be done with clusterProfiler::bitr)
library(AnnotationDbi)
library(org.Hs.eg.db)
columns(org.Hs.eg.db)
#[1] "ACCNUM"       "ALIAS"        "ENSEMBL"      "ENSEMBLPROT"  "ENSEMBLTRANS" "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"    
#[11] "GO"           "GOALL"        "IPI"          "MAP"          "OMIM"         "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PFAM"         "PMID"        
#[21] "PROSITE"      "REFSEQ"       "SYMBOL"       "UCSCKG"       "UNIGENE"      "UNIPROT"

anno_entrez <- select(org.Hs.eg.db,
                      keys = unique(dp_all_DN$Uniprot),
                      columns = c("ENTREZID", "SYMBOL"),
                      keytype = "UNIPROT") 
```

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


## The tibble::deframe function is very useful for this, too:
ranks_DN <- tibble::deframe( x = data.frame( dp_all_DN[!is.na(ENTREZID), mean(t), by = "ENTREZID"])) 
```

```
y <- gsePathway(geneList, nPerm=10000,
                pvalueCutoff=0.2,
                pAdjustMethod="BH", verbose=FALSE)
res <- as.data.frame(y)
```

<a name="tcgsa"></a>
#### 3. TcGSA: time-course GSA

From the [original paper](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004310#pcbi-1004310-g005):

1. **Determining signficantly changing gene sets**
    >In TcGSA, a "significant" gene set is a gene set whose expression is not stable either over time (in one group experiments) or over groups (in several groups experiments), once between genes and patients variability is taken into account.
    The null hypothesis is that inside the gene set S, the evolution of gene expressions over time is the same regardless of the group.
    One model is fitted under the null hypothesis, and one is fitted under the alternative. The likelihood ratio is then computed.
2. **Estimating individual gene profiles**
   > The mixed model uses the repeated pattern of the longitudinal measurements to structure the variation. Its estimations give smoother trajectories for the genes than the raw data, which makes the general evolution of the set clearerhe estimations from the mixed model are shrunken towards the average expression inside the gene set.
3. **Clustering trends within significantly changing gene sets**
   > Once a gene set S has been identified as significant through the previous mixed likelihood ratio statistics, a summary of its dynamic over time is needed. However, due to the possible heterogeneity of S, giving a summary representation of S dynamic is not obvious. We propose to automatically identify the number of trends in a significant gene set from the fit of the model. Predicted gene expressions from the linear mixed model are clustered, and the optimal number of trends is selected with the gap statistic. (...) Therefore, gene sets are actually split when heterogeneous, before being summarized. The predicted gene expression from the linear mixed model is used for this (and not the observed expression) because smoothness of trajectories facilitates classification

[Time-course Gene Set Enrichment Analysis](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004310) and its [vignette](https://cran.r-project.org/web/packages/TcGSA/vignettes/TcGSA_userguide.html)

3 inputs are required to run TcGSA:

* The gene set object: `gmt`
* The **gene expression matrix**: The gene expression should already be normalized before using TcGSA. In the rownames, the name of each probe/gene must match with the name of probes/genes in the gmt object.
* The **design data** matrix: i.e., sample info table with samples = rows

```
tcgsa_result <- TcGSA::TcGSA.LR(expr = norm.df, 
                                   gmt = gmt_hallmark,
                                   design = si.df[colnames(norm.df),], 
                                   subject_name = "subject", 
                                   time_name = "day", 
                                   group_name = "group")
summary(tcgsa_result)
#		A TcGSA object
#Form of the time trend:
#	linear
#Number of treatment groups:
#	2
#Number of gene sets tested for significant time trend:
#	50
#
#Number of significant gene sets at a 5% threshold (BY procedure):
#	35 out of 50 gene sets

head(TcGSA::signifLRT.TcGSA(tcgsa_result)$mixedLRTadjRes)
#                       GeneSet      AdjPval                                                                         desc
#33 HALLMARK_ALLOGRAFT_REJECTION 1.515091e-02 http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_ALLOGRAFT_REJECTION
#10   HALLMARK_ANDROGEN_RESPONSE 4.151712e-18   http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_ANDROGEN_RESPONSE
#28        HALLMARK_ANGIOGENESIS 2.330152e-09        http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_ANGIOGENESIS
#14     HALLMARK_APICAL_JUNCTION 7.833198e-19     http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_APICAL_JUNCTION
#15      HALLMARK_APICAL_SURFACE 8.813033e-04      http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_APICAL_SURFACE
#7            HALLMARK_APOPTOSIS 1.888258e-21           http://www.broadinstitute.org/gsea/msigdb/cards/HALLMARK_APOPTOSIS
```

The likelihood ratio provides insight on the magnitude of the variation of each gene set.
The `tcgsa_result` object contains the LR for every tested gene set:

```
> str(tcgsa_result$fit$LR)
 num [1:50] 1.41e+02 1.91e+02 6.05e+01 1.88e+02 7.14e-03 ...
```


```
#This function clusters the genes dynamics of one gene sets into different dominant trends.
# Uses the Gap statistics to determine the optimal number of clusters
tcgsa_clust <- TcGSA::clustTrend(tcgs = tcgsa_result, 
                                 expr=tcgsa_result$Estimations,
                                 baseline = 1, # first time point,
                                 ref = "control",
                                 group_of_interest="DN")
names(tcgsa_clust)
#[1] "NbClust"        "ClustMeds"      "GenesPartition" "MaxNbClust"    
names(tcgsa_clust[["ClustMeds"]])
# [1] "HALLMARK_ALLOGRAFT_REJECTION"               "HALLMARK_ANDROGEN_RESPONSE"                 "HALLMARK_ANGIOGENESIS"                     
# [4] "HALLMARK_APICAL_JUNCTION"                   "HALLMARK_APICAL_SURFACE"                    "HALLMARK_APOPTOSIS"                        
# [7] "HALLMARK_BILE_ACID_METABOLISM"              "HALLMARK_CHOLESTEROL_HOMEOSTASIS"           "HALLMARK_COAGULATION"                      
#[10] "HALLMARK_COMPLEMENT"                        "HALLMARK_E2F_TARGETS"                       "HALLMARK_EPITHELIAL_MESENCHYMAL_TRANSITION"
#[13] "HALLMARK_ESTROGEN_RESPONSE_EARLY"           "HALLMARK_FATTY_ACID_METABOLISM"             "HALLMARK_GLYCOLYSIS"                       
#[16] "HALLMARK_HEME_METABOLISM"                   "HALLMARK_HYPOXIA"                           "HALLMARK_IL2_STAT5_SIGNALING"              
#[19] "HALLMARK_IL6_JAK_STAT3_SIGNALING"           "HALLMARK_INFLAMMATORY_RESPONSE"             "HALLMARK_INTERFERON_GAMMA_RESPONSE"        
#[22] "HALLMARK_KRAS_SIGNALING_UP"                 "HALLMARK_MITOTIC_SPINDLE"                   "HALLMARK_MYC_TARGETS_V1"                   
#[25] "HALLMARK_MYC_TARGETS_V2"                    "HALLMARK_MYOGENESIS"                        "HALLMARK_NOTCH_SIGNALING"                  
#[28] "HALLMARK_OXIDATIVE_PHOSPHORYLATION"         "HALLMARK_PROTEIN_SECRETION"                 "HALLMARK_REACTIVE_OXIGEN_SPECIES_PATHWAY"  
#[31] "HALLMARK_SPERMATOGENESIS"                   "HALLMARK_TGF_BETA_SIGNALING"                "HALLMARK_TNFA_SIGNALING_VIA_NFKB"          
#[34] "HALLMARK_UV_RESPONSE_DN"                    "HALLMARK_XENOBIOTIC_METABOLISM"            

## heatmap
plot(x = tcgsa_result,
     expr = tcgsa_result$Estimations, 
     clust_trends = tcgsa_clust,
     legend.breaks = seq(from = -2,to = 2, by = 0.01),
     time_unit="D",
     #main = "Median trends...", 
     subtitle="Hallmark gene sets",
     cex.label.row=1.5, cex.label.col=1, cex.main=0.7,
     heatmap.width = 0.1, dendrogram.size = 0.1, margins = c(5,15), heatKey.size = 0.5,
     descript = FALSE, # avoids printing of Description column to the row names
     color.vec = c("#D73027", "#FC8D59","lightyellow", "#91BFDB", "#4575B4")
)
```

From the [original publication](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004310#pcbi-1004310-g005):

>The median estimated gene expression over the patients is used for each trend.
Each trend has seen its values reduced (so that its variance is 1) in order to make the dynamics more comparable.
Each row is a group of gene having the same trend inside a gene set, and each column is a time point.
The color key represents the median of the standardized estimation of gene expression over the patients for a given trend in a significant gene set. 
It becomes red as median expression is up-regulated or blue as it is down-regulated compared to the value in the placebo (saline) at the same time.

>It can be of interest to rank the significant gene sets to identify the most acute signals. The likelihood ratio provides insight on the magnitude of the variation of each gene set. The percentile of their corresponding likelihood ratio gives an idea of the importance of the variation for a significant gene set. 

> Globally, the intensity of the response was stronger with the pneumoccocal vaccine than with the flu vaccine (Fig 5). The early response induced by the pneumococcal vaccine was dominated by inflammation whereas the top signal triggered by the flu vaccine involved an interferon signature (Fig 5B and 5D). In both vaccine, a T-cell response was also visible. In the pneumoccocal vaccine, a plasma cell signal, in association with cell cycle gene sets (Figs 5A and 5C), started at Day 7 until Day 14. This plasma blast signal was much less clear in the flu vaccine (Figs 5B and 5D).

![Fig.5 from the TcGSA paper](https://journals.plos.org/ploscompbiol/article/figure/image?size=large&id=info:doi/10.1371/journal.pcbi.1004310.g005)

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


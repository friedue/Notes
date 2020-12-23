# Exploring heteroskedasticity



```r
## read counts
featCounts <- read.table("~/Documents/Teaching/ANGSD/data/featCounts_Gierlinski_genes.txt", header=TRUE, row.names = 1)
names(featCounts) <- names(featCounts) %>% gsub(".*alignment\\.", "", .) %>% gsub("_Aligned.*", "",.)
counts.mat <- as.matrix(featCounts[, -c(1:5)])

## sample info
samples <- data.frame(condition = gsub("_.*", "", colnames(counts.mat)),
  row.names = colnames(counts.mat))
samples$condition <- ifelse(samples$condition == "SNF2", "SNF2.KO", samples$condition)

## DESeq2 object
dds <- DESeqDataSetFromMatrix(counts.mat, colData = samples, design = ~condition)
# normalizing for diffs in sequencing depth and abundances per sample
dds <- estimateSizeFactors(dds) 
```

**Heteroskedasticity** = absence of homoskedasticity.
Where homoscedasticity is defined as ["the property of having equal statistical variances"](https://www.merriam-webster.com/dictionary/homoscedasticity).

Historically, **log-transformation** was proposed to counteract heterosced://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-2-r29):

> Large log-couts have much larger standard deviations than small counts.
> A logarithmic transformation counteracts this, but it overdoes it. Now, large counts have smaller standard deviations than small log-counts.


```r
## Greater variability across replicates for low-count genes
counts(dds, normalized = TRUE) %>% .[,1:2] %>% log2 %>% 
  plot(., main = "Greater variability of library-size-norm,\nlog-transformed counts for small count genes")
```


```r
## meanSDPlot (vsn library)
rowV = function(x, Mean) {
  sqr     = function(x)  x*x
  n       = rowSums(!is.naTRUE) %>% rowMeans(., na.rm = TRUE)
vars.exprs   = co mean.exprs)
sd.exprs <- sqrt(vars.exprs)
#var   = counts(dds[, dds$condition == "WT"], normalized = dds[, dds$condition == "WT"], normalized = TRUE)rs)
#vars <- sqrt(rowSums((x-means)^2)/(nlin the mean", cex = .2, lwd = .1)
plot(m = .2, lwd = .1)
```

![](RNA_heteroskedasticitunts(dds[, dds$condition == "WT"], normal0,1000), ylim = c(0, 2000))
#plot(mean.e

The greater the mean expression, the gre as the average expression value and ther some toy examples to illustrate that poi`

```
## [1] 0.01449957
```

```r
10 - 9
`s>

Intuitively, one can also see that tlized = TRUE) %>% .[,c(1,2)] %>% log2 %>% 

```r
# example with high expression 
meas > 0] %>% sort %>% head #YPR099C
```

``D/Var are higher for high-count genes,
th.exprs[c(high.exprsd, low.exprsd)] / mea% t %>% 
  as.data.table(., keep.rownames point(size = 4, alpha = .5, shape = 1) + 
  xprs[high.exprsd], "\nSD/mean:", noise.maable(., keep.rownames = "sample") %>%
 = .5, shape = 1) + 
  xlab("condition") +/mean:", noise.mag[low.exprsd]))

p1 + p2 +es/figure-html/unnamed-chunk-8-1.png)<!--(high.exprsd, low.exprsd)]

p1 <- log2(c "sample") %>% 
  ggplot(., aes(x = gsub( xlab("condition") + 
  ggtitle("Highly og2.mag[high.exprsd]))

p2 <- log2(coule") %>%
  ggplot(., aes(x = gsub("_.*",ondition") + 
  ggtitle("Lowly expressedw.exprsd]))

p1 + p2 + plot_annotation(tfigure-html/unnamed-chunk-9-1.png)<!-- -->
vs.log2 <- sd.log2exprs / mean.log2exprs of counts")
plot(mean.log2exprs, cvs.logasticity_files/figure-html/unnamed-chunk-e) happens to match the definition of th

### Fold changes are also heteroskedas0550-8) demonstrated heteroskedasticity  to show much stronger **differences** bn most HTS datasets, is a direct conseque low**

![](https://media.springernature.c14_Article_550_Fig2_HTML.jpg)

The fannissed genes.

The reasons are the same asusing models to gauge whether the differoup 1 (e.g. "WT") to the values from groand does not depend on the mean.
That ment about read count data properties, weth log-transformed data (as shown above)where we can **include the mean-variancetion that the variance is equal for all valto choose.
For Poisson, that relationshid relationships, e.g. a quadratic relation4288/2411520) for their `edgeR` package.ent of variation) with the main messageter for small count genes

Here are the1520) related to this:

>The coefficienmall to moderate counts but for larger c arises from the technical variability agical variation remains roughly constant. F CV decreases as the size of the counts increurce of uncertainty for high-count genesession in RNA-Seq experiments. If the abue standard deviations are proportional es, then it is reasonable to suppose thw is it related?

Overdispersion refers is again is an argument against the use of a simpd as `mean = variance`. 

## Summary

* Heteroskedastf read count values.
* Depending on whether thehigh-count genes (untransformed).


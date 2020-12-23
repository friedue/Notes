# Exploring heteroskedasticity

*For the R code used to generate the images shown here, see the corresponding [Rmd](https://github.com/friedue/Notes/blob/master/RNA_heteroskedasticity.Rmd).*

**Heteroskedasticity** = absence of homoskedasticity.
Where homoscedasticity is defined as ["the property of having equal statistical variances"](https://www.merriam-webster.com/dictionary/homoscedasticity).

Historically, **log-transformation** was proposed to counteract heteroscedasticity.
However, read counts retain unequal variabilities, even after log-transformation.
As described by [Law et al.](https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-2-r29):

> Large log-couts have much larger standard deviations than small counts.
> A logarithmic transformation counteracts this, but it overdoes it. Now, large counts have smaller standard deviations than small log-counts.

![](RNA_heteroskedasticity_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

Left: The greater the mean expression, the greater the variance.
Right: The greater the log-transformed expression, the smaller the variance as the average expression value and the actual expression value (`x`) are closer together.

<details>
  <summary>Click here for some toy examples to illustrate why log-transformation turns the relationship on its head.</summary>


```r
1000 - 990
```

```
## [1] 10
```

```r
log2(1000) - log2(990)
```

```
## [1] 0.01449957
```

```r
10 - 9
```

```
## [1] 1
```

```r
log2(10) - log2(9)
```

```
## [1] 0.1520031
```

</details>

Intuitively, one can also see that the "spread" of the data points is greater for low-count values:

![](RNA_heteroskedasticity_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

Let's have a closer look at two example genes, one that's highly and one that's lowly expressed

While the absolute values of SD and Variance are higher for high-count genes (in the absence of log-transformation),
the **magnitude** of the noise is greater for the low-count genes.
The following plots display the actual normalized expression values (not log-transformed) with the SD and the ratio `SD/mean` noted in the title.


![](RNA_heteroskedasticity_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

![](RNA_heteroskedasticity_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

This is true irrespective of log-transformation:

![](RNA_heteroskedasticity_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

The value that I named "magnitude of noise" (`noise.mag` in the code) happens to match the definition of the [**coefficient of variation**](https://en.wikipedia.org/wiki/Coefficient_of_variation)

### Fold changes are also heteroskedastic

[Love & Huber](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-014-0550-8) demonstrated heteroskedasticity as "variance of log-fold changes depending on mean count".

>weakly expressed genes seem to show much stronger **differences** between the compared mouse strains than strongly expressed genes. This phenomenon, seen in most HTS datasets, is a direct consequence of dealing with count data, in which **ratios are inherently noisier when counts are low**

![](https://media.springernature.com/full/springer-static/image/art%3A10.1186%2Fs13059-014-0550-8/MediaObjects/13059_2014_Article_550_Fig2_HTML.jpg)

The fanning out on the left indicates that the logFC often tend to be higher for very lowly expressed genes.

The reasons are the same as for the underlying counts.


## Why does the heteroscedasticity matter?

Because we're using models to gauge whether the difference in read counts is greater than expected by chance
when comparing the values from group 1 (e.g. "WT") to the values from group 2 (e.g. "SNF2.KO").

**Ordinary linear models** assume that the variance is constant and does not depend on the mean.
That means, linear models will only work with **homoscedastic** data.
Knowing what we just learnt about read count data properties, we can therefore rule out that simple linear models might be applied 'as is' -- not even with log-transformed data (as shown above)! 

This is why we turned to **generalized linear models** which allow us to use models where we can **include the mean-variance relationship**.
GLM with negative binomial or Poisson regression do not make the assumption that the variance is equal for all values, instead they explicitly model the variance -- using a relationship that we have to choose.
For Poisson, that relationship is `mean = variance`.
For negative binomial models, we can choose even more complicated relationships, e.g. a quadratic relationship as it was chosen by [McCarthy et al.](https://academic.oup.com/nar/article/40/10/4288/2411520) for their `edgeR` package.

That same paper also offers a nice discussion of the properties of the noise (coefficient of variation) with the main message being:

1. Total CV = biological noise + technical noise
2. technical noise will be greater for small count genes

Here are the direct quotes from [McCarthy et al.](https://academic.oup.com/nar/article/40/10/4288/2411520) related to this:

>The coefficient of variation (CV) of RNA-seq counts should be a decreasing function of count size for small to moderate counts but for larger counts should asymptote to a value that depends on biological variability
>The first term arises from the technical variability associated with sequencing, and gradually decreases with expected count size, while biological variation remains roughly constant. For large counts, the CV is determined mainly by biological variation.

>The technical CV decreases as the size of the counts increases. BCV on the other hand does not. BCV is therefore likely to be the dominant source of uncertainty for high-count genes, so reliable estimation of BCV is crucial for realistic assessment of differential expression in RNA-Seq experiments. If the abundance of each gene varies between replicate RNA samples in such a way that the genewise standard deviations are proportional to the genewise means, a commonly occurring property of measurements on physical quantities, then it is reasonable to suppose that BCV is approximately constant across genes.

## What does "overdispersion" mean and how is it related?

Overdispersion refers to the observation that the variance tends to be *greater* than the mean expression. 
This again is an argument against the use of a simple Poisson model where the relationship between mean and variance would be fixed as `mean = variance`. 

## Summary

* Heteroskedasticity is simply the absence of equal variances across the entire spectrum of read count values.
* Depending on whether the counts are log-transformed, the variance is higher for low-count genes (log) or high-count genes (untransformed).

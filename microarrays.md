Microarray analysis
=====================

There are two types of MA platforms:

* spotted array -- 2 colors
	* ![](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_twoColors.png)
* synthesized oligos -- 1 color (Affymetrix)
	* * ![](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_oneColor.png)
	
We have: **GeneChip Human Transcriptome Array 2.0** (Affymetrix, now Thermo Scientific Fisher)

* Gene Level plus Alternative Splicing
* 70% exon probes, 30% exon-exon spanning probes
* additional files and manuals provided by [Thermo Fisher](https://www.thermofisher.com/order/catalog/product/902162)

## File formats of microarrays

* `.CEL`: Expression Array feature intensity
* `.CDF`:
	- Chip definition file
	- information relating probe pair sets to locations on the array ("mapping" of the probe to a gene annotation)
	- in princple, these mappings can be updated

![]((https://raw.githubusercontent.com/friedue/Notes/master/images/MA_mapping.png)

## Packages

* `oligo` 
	- supposed to replace `affy` for the more modern exon-based arrays
	- for data import and preprocessing
	- uses `ExpressionSet`

*  `affy`
	- very comprehensive, but cannot read in HTA2.0 data
	- [affycoretools](https://github.com/Bioconductor-mirror/affycoretools/tree/master/R) has some functions to streamline array analysis, but they don't seem particularly fast
	- `arrayQualityMetrics` operates on `AffyBatch`
* `xps`
	- uses `ROOT` to speed up storage and retrieval
* `affyPLM`:
	- MAplot function will work on `ExpressionSet`  	

### Turning fluorescence signal into biological signal

old MAs had mismatch probes to estimate the noise --> the RMA algorithm made those obsolete, so modern MAs only have perfect match (PM) probes

**probeset** = group of probes covering one gene

The data analyst can choose one from three definitions of probesets for summarization to the transcript level:

1. **Core Probesets**: supported by RefSeq and full-length mRNA GenBank records;
2. **Extended Probesets**: supported by non-full-length mRNA GenBank records, EST sequences, ENSEMBL gene collections and others;
3. **Full Probesets**: supported by gene and exon prediction algorithms only.

Which one to use?

![WhitePaper probe sets](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_differentProbesets.png)

> Each gene annotation is constructed from transcript annotations from one or more confidence levels. Some parts of a gene annotation may
 derive from high confidence core annotations, while other parts derive from the lower confidence extended or full annotations. [White Paper Probe Sets II](http://tools.thermofisher.com/content/sfs/brochures/exon_probeset_trans_clust_whitepaper.pdf)

#### Normalization methods

##### MAS5

basically subtracts out mismatch probes

- Tukey's biweight estimator to provide robust mean signal, Wilcoxo rank test for p-value
- bckg estimation: weighted average of the lowest 2% if the feature intensities
- makes use of mismatch probes (applicable to HTA?)
- linear scaling with trimmed mean
- analyzes each array independently --> reduced power compared to the other methods

info based on TAC User Manual, more details can be found in the slides of the [Canadian Bioinfo Workshop 2012, pages 5-7](http://bioinformatics.ca/files/public/Microarray_2012_Module2.pdf)

##### Robust Microarray Average (RMA) 

is a log scale linear additive model that uses only perfect match probes and extracts background mathematically (GCRMA additionally corrects for mismatch probes)

_info from [Carvalho 2016](https://www.ncbi.nlm.nih.gov/pubmed/27008013), [RMA paper](https://www.ncbi.nlm.nih.gov/pubmed/12925520?access_num=12925520&link_type=MED)_

Steps implemented in `rma()`:

1. Background adjustment
	- noise from cross-hybridization and optical noise from the scanning
	- remove _local_ artifacts so that measurements aren't so affected by their neighbors
	- bckg noise = normal distribution
	- true signal = exponential distribution that is probeset-specific 
2. Quantile normalization
	- remove array-specific effects
3. Summarization --> obtaining expression levels
	- collapsing multiple probes per target into one signal
	- note that "probes" will be represented by background-adjusted, quantile-normalized, log-transformed PM intensities
	- ![rma](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_rma.png)
	- probe affinity a_j_ and chip effect beta_i_ must be estimated:
		- RMA default method: Tukey's Median Polish strategy (robust and fast, but no standard error estimates)
		- fits iteratively; successively removing row and column medians, and accumulating the terms until the process stabilizes; the residuals are what is left at the end
		- ![median polish](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_medianPolish.png)
		- alternative: fitting a linear model (Probe Level Model, PLM)
		- ![PLM](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_PLM.png)


![Comparison of correction and normalization approaches](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_normMethodComparison_TACmanual.png)

PLIER is the proprietory (?) algorithm of Affymetrix/Thermo Fisher; Table taken from TAC Manual (Appendix)

[White Paper Normalization](http://tools.thermofisher.com/content/sfs/brochures/sst_gccn_whitepaper.pdf) |
[White Paper Probe Sets A](http://tools.thermofisher.com/content/sfs/brochures/exon_gene_signal_estimate_whitepaper.pdf) |
[White Paper Probe Sets B](http://tools.thermofisher.com/content/sfs/brochures/exon_probeset_trans_clust_whitepaper.pdf)

## QC

### Pseudo images

Chip pseudo-images are very useful for detecting spatial differences (artifacts) on the invidual arrays (so not for comparing between arrays).

Pseudo-images are generated by fitting a probe-level model (PLM) to the data that assumes that all probes of a probe set behave the same in the different samples: probes that bind well to their target should do so on all arrays, probes that bind with low affinity should do so on all arrays.

You can create pseudo-images based on the residuals or the weights that result from a comparison of the model (the ideal data, without any noise) to the actual data. These weights or residuals may be graphically displayed using the `image()` function in Bioconductor (default: weights)

The model consists of a probe level (assuming that each probe should behave the same on all arrays) and an array level (taking into account that a gene can have different expression levels in different samples) parameter. 

>info from [wiki.bits](http://wiki.bits.vib.be/index.php/How_to_create_chip_pseudo-images)

### Histograms of log2 intensity 

![](http://data.bits.vib.be/hidden/jhslbjcgnchjdgksqngcvgqdlsjcnv/pubma2014/janick/BioC14.png)

```
	for(i in 1:6){
		hist(data[,i],lwd=2,which='pm',ylab='Density',xlab='Log2ntensities',
		main=ph@data$sample[i])
		}
		
	# ggplot2 way
	pmexp = pm(data)
	
```

### Boxplots of log2 intensity per sample

![](http://data.bits.vib.be/hidden/jhslbjcgnchjdgksqngcvgqdlsjcnv/pubma2014/janick/BioC20.png)

`pmexp = log2(pm(data))`

### Boxplots of log2 intensity per GC probe

![from Affy's White Paper](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_GCprobes.png)

### MA plots

MA plots were developed for two-color arrays to detect differences between the two color labels on the same array, and for these arrays they became hugely popular. This is why more and more people are now also using them for Affymetrix arrays but on Affymetrix only use a single color label. So people started using them to compare each Affymetrix array to a pseudo-array. The pseudo array consists of the median intensity of each probe over all arrays.

The MA plot shows to what extent the variability in expression depends on the expression level (more variation on high expression values?). In an MA-plot, A is plotted versus M:

- **M** = difference between the intensity of a probe on the array and the median intensity of that probe over all arrays
- **A** = average of the intensity of a probe on that array and the median intesity of that probe over all arrays; `A = (logPMInt_array + logPMInt_medianarray)/2`

![MA plot](http://data.bits.vib.be/hidden/jhslbjcgnchjdgksqngcvgqdlsjcnv/pubma2014/janick/BioC18.png)

Ideally, the cloud of data points should be centered around M=0 (blue line). This is because we assume that the majority of the genes is not DE and that the number of upregulated genes is similar to the number of downregulated genes. Additionally, the variability of the M values should be similar for different A values (average intensities). You see that the spread of the cloud increases with the average intensity: the loess curve (red line) moves further and further away from M=0 when A increases. To remove (some of) this dependency, we will normalize the data.

```
for (i in 1:6)
{
name = paste("MAplot",i,".jpg",sep="")
jpeg(name)
# MA-plots comparing the second array to the first array 
affyPLM::MAplot(eset.Dilution, which=c(1,2),ref=c(1,2),plot.method="smoothScatter")
# if multiple ref are given, these samples will be used to calculate the median
# equivalent: which=c("20A","20B"),ref=c("20A","20B")
dev.off()
}
```

### Relative expression boxplot (RLE)

How much is the expression of a probe spread out relative to the same probe on other arrays?

Computed  for  each  probeset  by  comparing  the  expression  value
on each array against the median expression value for that probeset across all arrays.
Ideally: most RLE values should be around zero.

see affyPLM

![RLE](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_RLE.png)


### Normalized unscaled standard error (NUSE)

How much is the variability of probes within a gene spread out relative to probes of the same gene on other arrays?

see affyPLM

![NUSE](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_NUSE.png)

### QC stat plot

see simpleaffy

### Source of variation

which attribute explains most of the variation ([page 82f.](https://assets.thermofisher.com/TFS-Assets/LSG/manuals/tac_user_manual.pdf))

Determine the fraction of the total variation of the samples can be explained by a given attribute:

1. compute variance of each probeset 
2. retain the 1000 probesets having the highest variance
3. Accumulate the _total sum of squares_ for each attribute
4. The _residual sum of squares_ (where the sum over j represents the  sum over samples within the  attribute level) is accumulated.
5. The fraction of variance explained for the attribute is the _mean of the fraction explained_ over all of the probesets.



	
-----------------------------------------------

## Affymetrix' TAC 

* Affymetrix' software (Windows only)
	- [User manual](https://assets.thermofisher.com/TFS-Assets/LSG/manuals/tac_user_manual.pdf) 
* uses the following R packages:
	- [Apcluster](https://dx.doi.org/10.1093/bioinformatics/btr406) - affinity propagation clustering
	- [Dbscan](https://CRAN.R-project.org/package=dbscan) - density based clustering of applications with noise
	- Rtsne
	- limma
* offers the following __normalization methods__:
	- RMA
	- MAS5
	- Plier PM-MM
* __QC__:
	- [Thermo Fisher White Paper](http://tools.thermofisher.com/content/sfs/brochures/exon_gene_arrays_qa_whitepaper.pdf)
	- PCA  

## Alternative splicing

- **EventPointer**
	- [R vignette](https://bioconductor.org/packages/release/bioc/vignettes/EventPointer/inst/doc/EventPointer.html)
	- [original paper]()
	- [code at github](https://github.com/jpromeror/EventPointer)
	- [Example Data](https://www.dropbox.com/sh/wpwz1jx0l112icw/AAD4yrEY4HG1fExUmtoBmrOWa/HTA%202.0?dl=0) including GTF file

## References

* [JR Stevens 2012](www.math.usu.edu/~jrstevens/stat5570/1.4.Preprocess.pdf)
* [Canadian Bioinfo Workshop on Microarrays](https://bioinformatics.ca/workshops/2012/microarray-data-analysis)

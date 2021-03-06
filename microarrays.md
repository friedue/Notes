Microarray analysis
=====================

* [MA Platforms](#platforms)
* [File Formats](#fileformats)
* [R packages](#packages)
* [Normalizations](#norms)
* [QC](#qc)
* [Annotation with gene names](#anno)
	* [Tx cluster vs. probe set level](#difflevels)
* [DE analysis](#de)
* [Affymetrix proprietary software](#affy)
* [Alternative splicing analysis](#alts)
* [References](#refs)

---------------------------------

<a name="platforms"></a>
There are two types of MA platforms:

* spotted array -- 2 colors
	* ![](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_twoColors.png)
* synthesized oligos -- 1 color (Affymetrix)
	* ![](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_oneColor.png)
	
We have: **GeneChip Human Transcriptome Array 2.0** (Affymetrix, now Thermo Scientific Fisher)

* Gene Level plus Alternative Splicing
* 70% exon probes, 30% exon-exon spanning probes
* additional files and manuals provided by [Thermo Fisher](https://www.thermofisher.com/order/catalog/product/902162)

Typically used microarrays:

![from https://bioinformatics.cancer.gov/sites/default/files/course_material/Btep-R-microA-presentation-Jan-Feb-2015.pdf](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_types.png)

<a name="fileformats"></a>
## File formats of microarrays

* `.CEL`: Expression Array feature intensity
* `.CDF`:
	- Chip definition file
	- information relating probe pair sets to locations on the array ("mapping" of the probe to a gene annotation)
	- in princple, these mappings can be updated

![](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_mapping.png)

<a name="packages"></a>
## Packages

* `oligo` 
	- supposed to replace `affy` for the more modern exon-based arrays
	- for data import and preprocessing
	- uses `ExpressionSet`
    - the best intro I found was the [github wiki](https://github.com/benilton/oligoOld/wiki/Getting-the-grips-with-the-oligo-Package)

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

<a name="norms"></a>
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

<a name="qc"></a>
## QC

According to [McCall et al., 2011](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-137), the most useful QC measures for identifying poorly performing arrays are:

* RLE
* NUSE
* percent present

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

* large spread of RLE indicates large number of DE genes
* Computed  for  each  probeset  by  comparing  the  expression  value
on each array against the median expression value for that probeset across all arrays.
* Ideally: most RLE values should be around zero.
* does not depend on RMA model

see `affyPLM`

![RLE](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_RLE.png)


### Normalized unscaled standard error (NUSE)

How much is the variability of probes within a gene spread out relative to probes of the same gene on other arrays?

see affyPLM

![NUSE](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_NUSE.png)

### QC stat plot

see `simpleaffy` [documentation](https://www.rdocumentation.org/packages/simpleaffy/versions/2.48.0/topics/plot.qc.stats)

| Parameter | Meaning |
|-----------|---------|
| x			  | A QCStats object |
| fc.line.col | The colour to mark fold change lines with |
|sf.ok.region | The colour to mark the region in which scale factors lie within appropriate bounds |
| chip.label.col | The colour to label the chips with |
|sf.thresh | Scale factors must be within this fold-range 
| gdh.thresh | Gapdh ratios must be within this range |
| ba.thresh | beta actin must be within this range |
|present.thresh | The percentage of genes called present must lie within this range |
| bg.thresh	|  Array backgrounds must lie within this range |
| label 		|  What to call the chips |
| main			|  The title for the plot |
| usemid		| If true use 3'/M ratios for the GAPDH and beta actin probes |
|cex			| Value to scale character size by (e.g. 0.5 means that the text should be plotted half size) |
| ... | Other parameters to pass through to |

![qc plot](http://cms.cs.ucl.ac.uk/fileadmin/bcb/QC_Report/Appendix_QCstats.jpg)

* lines = arrays, from the 0-fold line to the point that corresponds to its MAS5 scale factor. Affymetrix recommend that scale factors should lie within 3-fold of each other. 

* points: GAPDH and beta-actin 3'/5' ratios. Affy states that beta actin should be within 3, gapdh around 1. Any that fall outside these thresholds (1.25 for gapdh) are coloured red; the rest are blue.

* number of genes called present on each array vs. the average background. These will vary according to the samples being processed, and Affy's QC suggests simply that they should be similar. If any chips have significantly different values this is flagged in red, otherwise the numbers are displayed in blue. By default, 'significant' means that %-present are within 10% of each other; background intensity, 20 units. These last numbers are somewhat arbitrary and may need some tweaking to find values that suit the samples you're dealing with, and the overall nature of your setup.

* BioB = spike-in; if not present on a chip, this will be flagged by printing 'BioB' in red; this is a control for the hybridization step


### Source of variation

which attribute explains most of the variation ([page 82f.](https://assets.thermofisher.com/TFS-Assets/LSG/manuals/tac_user_manual.pdf))

Determine the fraction of the total variation of the samples can be explained by a given attribute:

1. compute variance of each probeset 
2. retain the 1000 probesets having the highest variance
3. Accumulate the _total sum of squares_ for each attribute
4. The _residual sum of squares_ (where the sum over j represents the  sum over samples within the  attribute level) is accumulated.
5. The fraction of variance explained for the attribute is the _mean of the fraction explained_ over all of the probesets.

<a name="anno"></a>
## Annotating probes with gene names

Thermo Fisher provides data bases with the mappings [here](https://www.thermofisher.com/us/en/home/life-science/microarray-analysis/microarray-data-analysis/genechip-array-annotation-files.html)

[Annotation Dbi](https://www.bioconductor.org/packages/devel/bioc/vignettes/AnnotationDbi/inst/doc/IntroToAnnotationPackages.pdf) seems to be the native R way to do this.

For an overview of all bioconductor-hosted annotation data bases, see [here](http://www.bioconductor.org/packages/release/BiocViews.html#___AnnotationData).
For HTA2.0, there are two options: [transcript clusters](http://www.bioconductor.org/packages/release/data/annotation/manuals/hta20transcriptcluster.db/man/hta20transcriptcluster.db.pdf) and [probe sets](http://www.bioconductor.org/packages/release/data/annotation/manuals/hta20probeset.db/man/hta20probeset.db.pdf)

<a name="difflevels"></a>
* __probe sets__: for HTA2.0, a probe set is more are less an exon, but not quite
	- old Exon ST arrays had four-probe probesets (e.g., four 25-mers that were summarized to estimate the expression of a 'probe set region', or PSR). A PSR was some or all of an exon, so it wasn't even that clear what you were measuring. If the exon was long, there might have been multiple PSRs for the exon, or if it was short maybe only one.
	- when you summarize at the probeset level on the HTA arrays, you are summarizing all the probes in a probeset, which may measure a PSR, or may also summarize a set of probes that are supposed to span an exon-exon junction
	- analyzing the data at this level is very complex: any significantly differentially expressed PSR or JUC (junction probe) just says something about a little chunk of the gene, and what that then means in the larger context of the gene is something that you have to explore further.
* __transcript clusters__: contain all probe sets of a _transcript_
	- there may be multiple transcript probesets for a given gene
	- given the propensity for Affy to re-use probes in the later versions of arrays, the multiple probesets for a given gene may well include some of the same probes!
	- the transcript level probesets provide some relative measure of the underlying transcription level of a gene
	- different probesets for the same gene may measure different splice variants.

[Ref1](https://www.biostars.org/p/12180/),
[Ref2](https://support.bioconductor.org/p/89308/)

[Stephen Turner](http://www.statsblogs.com/2012/01/17/annotating-limma-results-with-gene-names-for-affy-microarrays/) has a blog entry on how to do the annotation before the limma analysis; he uses transcript clusters (= gene-level analysis)

<a name="de"></a>
## DE Analysis

A very good summary of all the most important steps is given by [James MacDonald at biostars](https://support.bioconductor.org/p/89308/).

```
library(oligo)
dat <- read.celfiles(list.celfiles())
eset <- rma(dat)

## you can then get rid of background probes and annotate using functions in my affycoretools package
library(affycoretools)
library(hta20transcriptcluster.db)
eset.main <- getMainProbes(eset, pd.hta.2.0)
eset.main <- annotateEset(eset.main, hta20stranscriptcluster.db)
```

For probe-set level analysis (see caveats above!):

```
eset <- rma(dat, target = "probeset")
eset.main <- getMainProbes(eset, pd.hta.2.0)
eset.main <- annotateEset(eset.main, hta20probeset.db)
```

-----------------------------------------------

<a name="affy"></a>
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

<a name="alts"></a>
## Alternative splicing

- **EventPointer**
	- [R vignette](https://bioconductor.org/packages/release/bioc/vignettes/EventPointer/inst/doc/EventPointer.html)
	- [original paper]()
	- [code at github](https://github.com/jpromeror/EventPointer)
	- [Example Data](https://www.dropbox.com/sh/wpwz1jx0l112icw/AAD4yrEY4HG1fExUmtoBmrOWa/HTA%202.0?dl=0) including GTF file


<a name="refs"></a>
## References

* [JR Stevens 2012](www.math.usu.edu/~jrstevens/stat5570/1.4.Preprocess.pdf)
* [Canadian Bioinfo Workshop on Microarrays](https://bioinformatics.ca/workshops/2012/microarray-data-analysis)

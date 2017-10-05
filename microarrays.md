Microarray analysis
=====================

we have: **GeneChip Human Transcriptome Array 2.0** (Affymetrix, now Thermo Scientific Fisher)

* Gene Level plus Alternative Splicing
* 70% exon probes, 30% exon-exon spanning probes
* additional files and manuals provided by [Thermo Fisher](https://www.thermofisher.com/order/catalog/product/902162)


`.CEL`: Expression Array feature intensity

`oligo` for data import and preprocessing

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

- Tukey's biweight estimator to provide robust mean signal, Wilcoxo rank test for p-value
- bckg estimation: weighted average of the lowest 2% if the feature intensities
- makes use of mismatch probes (applicable to HTA?)
- linear scaling with trimmed mean
- analyzes each array independently --> reduced power compared to the other methods

info based on TAC User Manual

##### Robust Microarray Average (RMA) 

Steps:

1. Background adjustment
	- noise from cross-hybridization and optical noise from the scanning
	- bckg noise = normal distribution
	- true signal = exponential distribution that is probeset-specific 
2. Quantile normalization
3. Summarization
	- collapsing multiple probes per target into one signal
	- e.g. using a linear model
	- RMA method: Tukey's Median Polish strategy (robust and fast)

info from [Carvalho 2016](https://www.ncbi.nlm.nih.gov/pubmed/27008013)
[RMA paper](https://www.ncbi.nlm.nih.gov/pubmed/12925520?access_num=12925520&link_type=MED)

![Comparison of correction and normalization approaches](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_normMethodComparison_TACmanual.png)

PLIER is the proprietory (?) algorithm of Affymetrix/Thermo Fisher

[White Paper Normalization](http://tools.thermofisher.com/content/sfs/brochures/sst_gccn_whitepaper.pdf)
[White Paper Probe Sets I](http://tools.thermofisher.com/content/sfs/brochures/exon_gene_signal_estimate_whitepaper.pdf)
[White Paper Probe Sets II](http://tools.thermofisher.com/content/sfs/brochures/exon_probeset_trans_clust_whitepaper.pdf)

## QC

* [Hybridization controls](#hcontrol)
* [Labeling controls](#labelcontrol)
* Internal control genes (Housekeeping controls)
* [Global array metrics](#globalmetrics)

### Hybridization Control <a name="hcontrol"></a>

see [page 55 ff.](https://assets.thermofisher.com/TFS-Assets/LSG/manuals/tac_user_manual.pdf)

Hybridization Controls can be viewed in a 
line graph to __monitor consistency__ across 
samples as well as a relative increase in 
signal from BioB to Cre 

* 20x Eukaryotic Hybridization Controls
* spiked into the hybridization cocktail, independent of RNA sample preparation
* default spike controls: 

	- AFFX-r2-Ec-BioB
	- AFFX-r2-Ec-BioC
	- AFFX-r2-Ec-BioD
	- AFFX-r2-P1-Cre

### Label Control <a name="labelcontrol"></a>

* poly-A RNA controls, synthesized in vitro
* probe sets from _B. subtilis_ genes that are absent in eukaryotic samples (lys, phe, thr, and dap)

### Global array metrics <a name="globalmetrics"></a>

* __Source of variation__: which attribute explains most of the variation ([page 82f.](https://assets.thermofisher.com/TFS-Assets/LSG/manuals/tac_user_manual.pdf))
	- determine the fraction of the total variation of the samples can be explained by a given attribute
	- First, the variance of each probeset is computed, and the 1000 probesets having the highest variance are  retained.
	- Second, the _total sum of squares_ is accumulated for each attribute.
	- Third, the _residual sum of squares_ (where the sum over j represents the  sum over samples within the  attribute level) is accumulated.
	- Fourth, the fraction of variation explained for the probeset is.
	- Finally, the fraction of variance explained for the attribute is the mean of the fraction explained over all of the probesets.

* __boxplots__
	- per sample
	- per probe GC content
	![from Affy's White Paper](https://raw.githubusercontent.com/friedue/Notes/master/images/MA_GCprobes.png)

	
-----------------------------------------------

## TAC 

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


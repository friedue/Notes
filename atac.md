# ATAC-seq normalization

-  IMO, the background (in ChIP-seq) is really much more representative of how well the sequencing worked than the peaks, especially for tricky ChIPs
-  for ATAC-seq, I'm not so sure. Might depend on the sample. "Efficiency bias" could be confounded with "population heterogeneity", ergo, subtle changes in 'peak height' may reflect biologically meaningful differences in the number of cells that show chromatin accessibility at a given locus

What could cause efficiency bias in ATAC-seq samples?

- tagmentation differences -- how fickle is the digestion step? or, rather, how similar are the outputs for the same sample types when digestion times are kept constant?
- over-digestion --> tags from open regions are lost (too small); too much of the normally closed chromatin ends up being sequenced 
- under-digestion

## CSAW's take

From [csaw vignette](https://bioconductor.org/packages/3.12/workflows/vignettes/csawUsersGuide/inst/doc/csaw.pdf):

If one assumes that the differences at high abundances represent genuine DB events, then we need to remove **composition bias**.

- composition biases are formed when there are differences in the composition of sequences across libraries, i.e. in the region repertoire
- Highly enriched regions consume more sequencing resources and thereby suppress the representation of other regions. Differences in the magnitude of suppression between libraries can lead to spurious DB calls.
- Scaling by library size fails to correct for this as composition biases can still occur in libraries of the same size.
- to correct for this, use **non-DB background regions**

	binned <- windowCounts(bam.files, bin=TRUE, width=10000, param=param)
	filtered.data <- normFactors(binned, se.out=filtered.data)
	

If the systematic differences are not genuine DB, they must represent **efficiency bias** and should be removed by applying the TMM method on high-abundance windows.

- Efficiency biases = fold changes in enrichment that are introduced by variability in IP efficiencies between libraries
- assumption: **high-abundance windows** (=peaks) represent binding events and the fluctuations seen in these windows represent technical noise
	
		me.bin <- windowCounts(me.files, bin=TRUE, width=10000, param=param)
		keep <- filterWindowsGlobal(me.demo, me.bin)$filter > log2(3) filtered.me <- me.demo[keep,]
		filtered.me <- edgeR::normFactors(filtered.me, se.out=TRUE)
	 
>The normalization strategies for composition and efficiency biases are **mutually exclusive**.
>In general, normalization for composition bias is a good starting point for any analysis. This can be considered as the "default" strategy unless there is evidence for a confounding efficiency bias.

My own opinion: **efficiency bias** is more prevalent than composition bias in ChIP-seq samples. For ATAC-seq, I still don't have a good intuition.

## DiffBind's take

[DiffBind vignette](https://bioconductor.org/packages/release/bioc/vignettes/DiffBind/inst/doc/DiffBind.pdf)

* `bFullLibrarySize=FALSE` standard RNA-seq normalization method (based on the number of reads in consensus peaks), which assumes that most of the "genes" don't change expression, and those that do are divided roughly evenly in both directions
* `bFullLibrarySize=TRUE` simple normalization based on total number of reads [bioc forum](https://support.bioconductor.org/p/118182/)

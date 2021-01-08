# ATAC-seq normalization

-  IMO, the background (in ChIP-seq) is really much more representative of how well the sequencing worked than the peaks, especially for tricky ChIPs
-  for ATAC-seq, I'm not so sure. Might depend on the sample. "Efficiency bias" could be confounded with "population heterogeneity", ergo, subtle changes in 'peak height' may reflect biologically meaningful differences in the number of cells that show chromatin accessibility at a given locus
	-  It all comes down to having replicates of the same condition -- those will help with the decision about the types of biases we're encountering in a given set of samples -- and it doesn't fully matter whether the differences between the replicates represent biological or technical causes as long as we can agree that these differences are *uninteresting* for the bigger picture.

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

There are seven primary ways to normalize the example dataset: 

1. Library size normalization using full sequencing depth
2. Library size normalization using Reads in Peaks
3. RLE on Reads in Peaks
4. TMM on Reads in Peaks
5. loess fit on Reads in Peaks 6. RLE on Background bins
7. TMM on Background bins

> choice of which sets of reads to use for normalizing (focusing on reads in peaks or on all the reads in the libraries) is most important
 
>An assumption in RNA-seq analysis, that the read count matrix reflects an unbiased repre- sentation of the experimental data, may be violated when using a narrow set of consensus peaks that are chosen specifically based on their rates of enrichment. It is not clear that using normalization methods developed for RNA-seq count matrices on the consensus reads will not alter biological signals; **it is probably a good idea to avoid using the consensus count matrix (Reads in Peaks) for normalizing** unless there is a good prior reason to expect balanced changes in binding.

*Right. And good prior reason can only come from looking at replicates.*

* `bFullLibrarySize=FALSE` standard RNA-seq normalization method (based on the number of reads in consensus peaks), which assumes that most of the "genes" don't change expression, and those that do are divided roughly evenly in both directions
* `bFullLibrarySize=TRUE` simple normalization based on total number of reads [bioc forum](https://support.bioconductor.org/p/118182/)

>normalizing against the background vs. enriched consensus reads has a greater impact on analysis results than which specific normalization method is chosen.

* simple lib-size based normalization is the default because "RLE-based analysis [as in DESeq2's sf], as it alters the data distribution to a greater extent"
* how the lib size is calculated matters: using only reads in peaks will "take into account aspects of both the sequencing depth and the 'efficiency' of the ChIP". [see `csaw`'s efficiency bias approach]
* **alternatively**, one could focus on large windows: "it is expected that there should not be systematic differences in signals over much larger intervals (on the order of 10,000bp and greater)" -- I take it, that this is what Aaron refers to as "composition bias correction"

		tamoxifen <- dba.normalize(tamoxifen, method=DBA_ALL_METHODS,
									normalize=DBA_NORM_NATIVE,
									background=TRUE) # this is the point here
* "background normalization is even **more conservative**" than trivial lib-size norm

## ATPoints

* https://www.biostars.org/p/308976/
* [Illustration of bigwig norm. differences](https://www.biostars.org/p/413626/)
	- for visualization purposes it's probably not a bad idea to remove putative efficiency bias by calculating the scaling factor on peaks, especially if one has replicates to back up the issue of the efficiency bias
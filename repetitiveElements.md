Repetitive elements and short-read DNA sequencing
==================================================

* 40-50% of mouse and human genomes are made up of **repetitive elements**
	* interspersed ones that have mostly been acquired exogeneously: LINEs, SINEs, ERVs
	* satellite repeats, telomeres, centromeres
* mouse and humans have different types of ERVs and other endogenous (formerly) mobile elements (TEs)
* **discarding multi-mapping reads leads to dramatic under-representation of all of these regions**, but especially more evolutionary younger elements, that tend to be less frequently mutated

## ENCODE pipeline/Anshul's recommendation

### Chromap - Heng Li's ATAC-seq aligner

## Random assignment of multimappers: `STAR` + `featureCounts`

[Teissandier et al., 2019: Tools and best practices for retrotransposon analysis with HTS data](https://dx.doi.org/10.1186/s13100-019-0192-1)

* `TEtools` uses TE annotation to create `Bowtie2` index and performs mapping by reporting randomly one position [13,14]
* `SQuIRE` [17] allows quantifying TE single copies and families performing the alignment with STAR and using an iterative method to assign multi-mapped reads (SQuIRE)
	* SQuIRE quantifies TE expression at the locus level
	* refines initial (multi-read) assignment by redistributing multi-mapping read fractions in proportion to estimated TE expression with an expectation-maximization algorithm
	* `Map` aligns RNA-seq data using the STAR aligner with parameters tailored to TEs that allow for **multi-mapping reads and discordant alignments** --> BAM file 
	* `Count` quantifies TE expression using a `SQuIRE`-specific algorithm that incorporates both unique (uniquely map to particular TE loci) and multi-mapping reads --> read counts
* `TEtranscripts` [19] advises to generate BAM files with the `STAR` mapper, and performs TE quantification using only uniquely-mapped reads (`TEtranscripts Unique`), or using multi-mapped reads with an iterative method (`TEtranscripts Multiple`).

>reporting randomly one position (`TEtools` and `FeatureCounts Random alignments`) gave the **most satisfactory TE estimation**
>reporting multi-mapped reads or reporting randomly one position increases the percentage of mapping close to 100% but at the cost of lower precision

- but `TEtools` tends to overestimate LINE1 and LTR elements because it ignores the non-repetitive genome
- reporting multi-hits is more consuming in terms of storage and time compared to report randomly one position per read

**Their take-home messages:**

1. **paired-end library** should be used to increase the uniqueness of sequenced fragments.
2. During the alignment step, `STAR` is the **best compromise between efficiency and speed.** Parameters have to be set according to the TE content.
3. Reporting randomly one position and using `FeatureCounts` to quantify TE families gives the best estimation values [compared to unique reads only]
4. When TE annotation on an assembled genome is available, mapping and quantification should be done with the reference genome.

```
# By default, STAR reports up to 10 alignments per read.
#STAR v2.5.2b random mode [for MOUSE; see supplemental notes for HUMAN]
--runThreadN 4 --outSAMtype BAM Unsorted --runMode alignReads \
--outFilterMultimapNmax 5000 \
--outSAMmultNmax 1 \
--outFilterMismatchNmax 3 \
--outMultimapperOrder Random \
--winAnchorMultimapNmax 5000 --alignEndsType EndToEnd \
--alignIntronMax 1 --alignMatesGapMax 350 \
--seedSearchStartLmax 30 --alignTranscriptsPerReadNmax 30000 \
--alignWindowsPerReadNmax 30000 --alignTranscriptsPerWindowNmax 300 \
--seedPerReadNmax 3000 --seedPerWindowNmax 300 --seedNoneLociPerWindow 1000

# FeatureCounts Random Alignments
featureCounts -M -F SAF -T 1 -s 0 -p -a rmsk.SAF -o outfeatureCounts.txt Input.bam
```

`SQUIRE`:

```
squire Map -1 R1.fastq -2 R2.fastq -o outSquire -f genomeSquire -r 100 -p 4
squire Count -m outSquire -f genomeSquire -r 100 -p 4 -o outSquire -c genomeCleanSquire
```

## Bayesian assignment of multimappers: `SmartMap`

- an algorithm that uses *iterative Bayesian re-weighting of ambiguous mappings*, with assessment of alignment quality as a factor in assigning weights to each mapping

>We find that SmartMap markedly increases the number ofreads that can be analyzed and thereby improves counting statistics and read depth recovery at repetitive loci. This algorithm and software implementation is compatible with both paired-end and single-end sequencing, and can be used for both strand-independent and strand-specific methods employing NGS backends to generate genome-wide read depth datasets.

- motivated by the assumption that *regions with more alignments are more likely to be the true source of a multiread than those with fewer alignments*. 
- increase in read depth from the SmartMap analysis is primarily at loci where the uniread analysis performs poorly

>multireads instead concentrate into a minority of loci (Table 2) and particularly those with low uniread depth (Figs 3C and S2C and S2D). This suggests that the unireads and multireads have different genomic distributions, violating the critical assumption underlying proportional allocation of multireads. Another method of resolving multireads is to select one alignment at random for each read 

* <https://shah-rohan.github.io/SmartMap/analysis.html>
* <https://github.com/shah-rohan/SmartMap>
* [Shah et al., 2021](http://dx.doi.org/10.1371/journal.pcbi.1008926)

useful for ATAC-seq and ChIP-seq, not so much RNA-seq (they claim that they don't handle gapped reads etc. well: "*Because our reweighting algorithm assigns weights based on the average read depth across an alignment, an alignment spanning a splice junction in RNA-seq may be unfairly assigned a lower weight due to decreased read depth in the intron. As such, highly spliced genes may be given a lower read depth than a similarly expressed gene with fewer introns*"

- they find that spitting out up to 50 alignments for multi-reads is sufficient
- compared to random assignment they claim "usage of alignment quality scores and paired-end sequencing can *markedly increase the accuracy* of imputed alignments"

### `SmartMap` usage

- `SmartMapPrep` for
	- alignment (`bowtie2`)
	- filtering
	- BED file generation
	- reads are sorted into separate files based on the number of alignments per read
- `SmartMap` turns BED file into BEDGRAPH
	- weighted genome coverage file 


--> sounds pretty cumbersome

- needs lots of memory (>60GB)
- works with Bowtie2 and was tested with Bowtie2 reporting up to 50 possible alignments
 
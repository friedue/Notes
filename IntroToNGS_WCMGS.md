
In the last decade, extraordinary advances in high-throughput DNA sequencing have laid the foundation for addressing molecular questions at a genome-wide scale. Instead of investigating one locus at a time, researchers can now acquire data covering the entire genome in one single experiment. 
While these data sets can assist the elucidation of complex biological systems and diseases, they also require sophisticated solutions for data storage, processing, analysis and interpretation. Simply put: you won't get very far with Excel spreadsheets if you're looking at 30,000 genes at a time -- and to arrive at biologically meaningful values for 30,000 genes it takes a lot of data wrangling and processing!

At WCM, several Core Facilities exist to enable researchers to take full advantage of the cutting-edge research possibilities related to high-throughput DNA sequencing experiments, ranging from optimized protocols for the different types of sequencing-related assays to high-performance computing environments and bioinformatics support.
We strongly encourage you to tap into their expertise to help you set up your own experiments. 

The following paragraphs are very brief summaries of the most important points to consider when thinking about using high-throughput DNA sequencing experiments in your own work.

* [Overview](#overview)
* [WCM's infrastructure](#infrastructure)
* [Parameters to consider for planning the experiment](#params)
	- [How many and what type of replicates?](#reps)
	- [Experimental design](#design)
* [Classes, workshops, hands-on help at WCM](#courses)
	- [Self-paced reading and studying](#refs)

<a name="overview"></a>
## Overview

DNA sequencing is used for far more than actually reading the DNA sequence. The advent of massive parallel DNA sequencing (synonyms: shotgun sequencing, next-generation sequencing, deep sequencing) has enabled researchers to do quantitative counting of RNA and DNA molecules, which can be combined with more spophisticated biochemical set-ups allowing the interrogation of active transcription (RNA-seq, PRO-seq, GRO-seq) as well as insights about protein-DNA interactions (ChIP-seq), the 3D structure of chromatin (ChIA-PET, ChIP-seq), and many more.
Even antibody-stainings typically used for FACS analyses can now be translated into DNA reads (CITE-seq).

The following figure taken from [Frese et al., 2013](http://www.mdpi.com/2079-7737/2/1/378) highlights some of the most commonly applied seq-based applications:

![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/biology-02-00378-g001.jpg)

For more details about the different high-throughput sequencing platforms and applications, see [Goodwin et al., 2016](http://dx.doi.org/10.1038/nrg.2016.49) and [Reuter et al., 2015](https://www.sciencedirect.com/science/article/pii/S1097276515003408).

The general workflow of any experiment based on high-throughput DNA sequencing involves the following steps:

1. **Sample prepration** This step is usually done by the molecular biologist.
What type of starting material is needed depends on the type of assay. For RNA-seq, this would include RNA extraction from all samples of interest; for eRRBS, WGBS, exome-sequencing etc. DNA will have to be extracted; for ChIP-seq, chromatin will be purified, immunoprecipitated and eventually fragmented into small DNA pieces; and so on.
2. **Sequencing**
    1. *Library preparation*: the RNA or DNA fragments delivered to the sequencing facility are (highly) amplified, and ligated to the adapters and primers that are needed for sequencing
    2. *Sequencing-by-synthesis*: the libraries are loaded onto the lanes of a flow cell, in which the base pair order of every DNA fragment is determined using distinct fluorescent dyes for ever nucleotide (for more details, see Section 1.3 of the [Introduction to RNA-seq](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf) )
3. **Bioinformatics**
    1. Quality control and *processing* of the raw sequencing reads, e.g., trimming of excess adapter sequences
    2. Read *alignment* and QC
    3. Additional *processing*, e.g. normalization to account for differences in sequencing depth (= total numbers of reads) per sample
    4. Downstream analyses, e.g. identification of differentially expressed genes (RNA-seq); peak calling (ChIP-seq); differentially methylated regions (eRRBS, WGBS); sequence variants (exome-seq); and so on

<a name="infrastructure"></a>
## WCM's infrastructure for high-throughput DNA sequencing experiments

WCM offers assistance for virtually every step that's needed for the successful implementation and interpretation of experiments involving high-throughput DNA sequencing.

* **Sequencing** and basic data processing: [Genomics Core](), [Epigenomics Core](http://epicore.med.cornell.edu/)
* **Analysis**: [Applied Bioinformatics Core](abc.med.cornell.edu)
* **Storage and high-performance computing servers**: Scientific Computing Unit
	
![WCM Infrastructure](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/wcm_schema.png)

We highly recommend to get in touch with the Core Facilities in order to work out the details of your own experiment.
There are many parameters that can be tuned and optimized; the following paragraphs are meant to give you a brief glimpse into some of the major aspects that should be considered _before_ actually preparing your samples.

The Epigenomics Core also compiled [detailed information](http://epicore.med.cornell.edu/services.php) about the different assays they're offering.

<a name="params"></a>
### Parameters to consider for the experiment

Here are some of the most important things to think about:

* appropriate control samples (e.g. input samples for ChIP-seq)
* number of replicates
* sequencing read length
* paired-end sequencing or single reads
* specific library preparations, e.g. poly-A enrichment vs. ribosomal depletion for RNA-seq, size range of the fragments to be amplified etc.
* strand information is typically lost, but can be preserved it needed

Typical problems of Illumina-based sequencing data are:

* PCR artifacts such as duplicated fragments, lack of fragments with very high or very low GC content and biases towards shorter read lengths
* sequencing errors and mis-identified bases

These problems can be mitigated, but not completely eliminated, with careful library preparation (e.g., minimum numbers of PCR cycles, removal of excess primers) and frequent updates of Illumina's machines and chemistry.

In addition, there are inherent limitations that are still not overcome:

* short reads -- regions with lots of repetitive regions will be virtually impossible to see with typical read lengths of 100 bp
* the data will most likely be only as good as the reference genome
* statistical analysis of many applications has not caught up with the speed at which new assays are being developed -- gold standards of analysis exist for very few applications and many analyses are still hotly debated in the bioinformatics community (e.g., identification of broad histone mark enrichments, single cell RNA-seq analysis, isoform quantification, de novo transcript discovery (including lncRNA), ...)

**There may be questions that are not best addressed with Illumina's sequencing platform!**

<a name="reps"></a>
### How many and what types of replicates?

For many HTS applications, the ultimate goal is to find the subset of regions or genes that show differences between the conditions that were analyzed. Conventional RNA-seq analysis, for example, can be used to interrogate thousands of genes at the same time, but the question you're asking for every gene is the same: is there a significant difference in expression between the two (or more) conditions?

In order to be somewhat confident that the expression levels (or enrichment levels or methylation levels -- or whatever type of biological signal you were interested in) you're comparing are not just reflecting normal biological variation, but are indeed a consequence of the experimental condition, you will need to have more than one measurement per locus.
Ideally, you should have hundreds of measurements, but practically, this will not be feasible due to financial and other constraints. You will therefore have to find a compromise between the number of samples you can afford to prepare and sequence and the number of samples you think you will need to gauge the variation in your system. 
The next figure illustrates how the assessment of a single locus (her called "Rando1A") changes depending on how many and which (!) samples were analyzed (note that all values come from the _same_ distribution that were arbitrarily assigned to either "sample type").

!["Replicates matter"](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/replicates2.png)

**Technical replicates** are repeated measurements of the *same* sample.
**Biological replicates** are parallel measurements of biologically *distinct* samples that capture random biological variation 

![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/replicates.png)

<a name="design"></a>
### Experimental design considerations 

The major rule is: **Block what you can, randomize what you cannot.**
In practice, this means that you should try to keep the technical nuisance factors (e.g. cell harvest date, RNA/DNA extraction method, sequencing date, ...) to a minimum, i.e., try to be as consistent as possible. If you cannot harvest all the cells on the same day, make sure you do not confound parameters of interest with technical factors, i.e., absolutely avoid processing all, say, wild type samples on day 1 and all mutant samples on day 2. 

Don't overthink it (fully blocked design is simply not feasible), but make sure that the factors of interest are clear. This also means communicating with the sequencing facility about how to randomize technical variation appropriately and in accordance with your experiment's design.
The classic paper by [Auer & Doerge](http://dx.doi.org/10.1534/genetics.110.114983) established the rules of balanced experimental design while leveraging the features of typical high-throughput DNA sequencing platforms.
The following figure is taken from their paper:

![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/AuerDoerge2010.png)

For more details about experimental design considerations, see Section 1.4 of the [Introduction to RNA-seq](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf), Altman N and Krzywinski M. (2014) [Nature Methods, 12(1):5–6, 2014](http://dx.doi.org/10.1038/nmeth.3224), and Blainey et al. (2014) [Nature Methods, 1(9) 879–880](https://www.nature.com/articles/nmeth.3091).

<a name="courses"></a>
## Classes, workshops, hands-on help at WCM

WCM is part of a vibrant community of computational biologists and DNA sequencing experts!

**Meetings**:

Every Thursday, the Applied Bioinformatics Core offers weekly [Bioinformatics Walk-in Clinic](https://abc.med.cornell.edu/ABC_Clinic.pdf) -- for all your questions about experimental design and data analysis!

For more experienced coders and programmers, you may be interested to join the mailing list of [d:bug](https://github.com/abcdbug/dbug) to stay up-to-date with cool packages and state-of-the-art data science tips.

**Classes**:

* Q-Bio
* TRI-I workshops taught by personnel of the [Applied Bioinformatics Core](https://abc.med.cornell.edu):
    - Introduction to UNIX ([schedule](http://www.trii.org/courses/), [course notes](http://chagall.med.cornell.edu/UNIXcourse/))
    - Intro to differential gene expression analysis using RNA-seq ([schedule](http://www.trii.org/courses/), [course notes](http://chagall.med.cornell.edu/RNASEQcourse/) )

<a name="refs"></a>
### Self-paced reading and studying

The Epigenomics Core has compiled [detailed information](http://epicore.med.cornell.edu/services.php) about the different types of -seq experiments they're performing. 

The [course notes](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf) accompanying the Applied Bioinformatics Core's RNA-seq class contain a comprehensive introduction into many aspects of high-throughput sequencing data analysis.

An introduction into general ChIP-seq analysis can be found [here](http://deeptools.readthedocs.io/en/latest/content/example_usage.html), including a [Glossary of HTS terms](http://deeptools.readthedocs.io/en/latest/content/help_glossary.html) including the different [file formats](http://deeptools.readthedocs.io/en/latest/content/help_glossary.html#file-formats).

#### Online courses

* Applied Bioinformatics Core's Datacamp Course [Introduction to R](https://www.datacamp.com/courses/abc-intro-2-r)
* Applied Bioinformatics Core's [Introduction to version control using RStudio](https://www.datacamp.com/courses/abc-intro-2-git-in-rstudio)
* [Michael Love's Intro to Computational Biology](https://biodatascience.github.io/compbio/)

#### Articles

* An excellent overview of the different sequencing techniques and applications: ["Coming of age: ten years of next- generation sequencing technologies"](http://dx.doi.org/10.1038/nrg.2016.49)
* A good summary of sequencing platforms including publicly available data: ["High-throughput sequencing"](http://www.cell.com/molecular-cell/fulltext/S1097-2765(15)00340-8)
* Nature Methods has compiled a great selection of brief introductions into many statistical concepts that biologists should be familiar with, such as p-value calculations, replicate handling, visualizations etc.: [Points of Significance Series](https://www.nature.com/collections/qghhqm/pointsofsignificance)
* F100Research: [Channels](https://f1000research.com/gateways) 

#### Community

* [Biostars](https://www.biostars.org/)
* [Seqanswers](http://seqanswers.com/forums/index.php)

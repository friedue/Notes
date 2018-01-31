Contents
---------

* [Overview](#overview)
* [WCM's infrastructure](#infrastructure)
* [Parameters to consider for experimental design](#design)
	- [How many and what type of replicates?](#reps)
* [ Classes, workshops, hands-on help at WCM(#courses)
	- [Self-paced reading and studying](#refs)
    
 ---------------------------------------------

>Efficient analysis and interpretation of Big Data opens new avenues to explore molecular biology, new questions to ask about physiological and pathological states, and new ways to answer these open issues. Such analyses lead to better understanding of diseases and development of better and personalized diagnostics and therapeutics. However, such progresses are directly related to the availability of new solutions to deal with this huge amount of information. New paradigms are needed to store and access data, for its annotation and integration and finally for inferring knowledge and making it available to researchers. Bioinformatics can be viewed as the “glue” for all these processes.

Efficient processing, storage and retrieval of large-scale sequencing data sets are crucially important for modern 'big-data-driven' life science. 

The ABC has compiled a comprehensive introduction into the principles of high-throughput DNA sequencing and the details of the bioinformatics processing and analyses with a focus on conventional RNA-seq. The course notes can be found [here](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf). The following paragraphs are very brief summaries of the most important points to consider when thinking about using high-throughput DNA sequencing experiments in your own work.

<a name="overview"></a>
## Overview

Typical biological questions to be addressed with the help of high-throughput DNA sequencing:

* Do gene expression patterns change between two (or more) different conditions?
* ...
* ...

![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/biology-02-00378-g001.jpg)

The general workflow of any experiment based on high-throughput DNA sequencing involves the following steps:

1. **Sample prepration** This step is usually done by the molecular biologist.
What type of starting material is needed depends on the type of assay. For RNA-seq, this would include RNA extraction from all samples of interest; for eRRBS, WGBS, exome-sequencing etc. DNA will have to be extracted; for ChIP-seq, chromatin will be purified, immunoprecipitated and eventually fragmented into small DNA pieces; and so on.
2. **Sequencing (biochemistry)**
    1. *Library preparation*: the RNA or DNA fragments delivered to the sequencing core are (highly) amplified, and ligated to the adapters and primers that are needed for sequencing
    2. *Sequencing-by-synthesis*: the libraries are loaded onto the lanes of a flow cell, in which the base pair order of every DNA fragment is determined using distinct fluorescent dyes for ever nucleotide (for more details, see Section 1.3 of the [Introduction to RNA-seq](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf) )
3. **Bioinformatics**
    1. Quality control and *processing* of the raw sequencing reads, e.g., trimming of excess adapter sequences
    2. Read *alignment* and QC
    3. Additional *processing*, e.g. normalization to account for differences in sequencing depth (= total numbers of reads) per sample
    4. Downstream analyses, e.g. identification of differentially expressed genes (RNA-seq); peak calling (ChIP-seq); differentially methylated regions (eRRBS, WGBS); sequence variants (exome-seq); and so on

<a name="infrastructure"></a>
## WCM's infrastructure for high-throughput DNA sequencing experiments

* Sequencing and basic data processing: Epigenomics Core, Genomics Core
* Analysis: Applied Bioinformatics Core
* Administration of storage and high-performance computing servers: Scientific Computing Unit

<a name="design"></a>
## Parameters to consider for experimental design

* appropriate control samples (e.g. input samples for ChIP-seq)
* number of replicates
* read length
* PE vs. SR
* poly-A enrichment vs. ribosomal depletion
* strand information


Typical problems of Illumina-based sequencing data are:

* PCR artifacts such as duplicated fragments, lack of fragments with very high or very low GC content and biases towards shorter read lengths
* sequencing errors and mis-identified bases

These problems can be mitigated, but not completely eliminated, with careful library preparation (e.g., minimum numbers of PCR cycles, removal of excess primers) and frequent updates of Illumina's machines and chemistry.

<a name="reps"></a>
### How many and what type of replicates?

For many HTS applications, the ultimate goal is to find the subset of regions or genes that show differences between the conditions that were analyzed. For example, you may 
For more details about experimental design considerations, see Section 1.4 of the [Introduction to RNA-seq](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf), [Altman N and Krzywinski M. (2014) Nature Methods, 12(1):5–6, 2014](http://dx.doi.org/10.1038/nmeth.3224), [Blainey et al. (2014) Nature Methods, 1(9) 879–880](https://www.nature.com/articles/nmeth.3091)


Technical replicates are therefore repeated measurements of the same sample while biological replicates are parallel measurements of biologically distinct samples that capture random biological variation 

![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/replicates.png)

<a name="courses"></a>
## Classes, workshops, hands-on help at WCM

Every Thursday, the Applied Bioinformatics Core offers weekly [Bioinformatics Walk-in Clinic](https://abc.med.cornell.edu/ABC_Clinic.pdf) -- for questions about experimental design and data analysis.

* Q-Bio
* TRI-I workshops taught by personnel of the [Applied Bioinformatics Core](https://abc.med.cornell.edu):
    - Introduction to UNIX ([schedule](http://www.trii.org/courses/), [course notes](http://chagall.med.cornell.edu/UNIXcourse/))
    - Intro to differential gene expression analysis using RNA-seq ([schedule](http://www.trii.org/courses/), [course notes](http://chagall.med.cornell.edu/RNASEQcourse/) )

For more experienced coders and programmers, you may be interested to join the mailing list of [d:bug](https://github.com/abcdbug/dbug) to stay up-to-date with cool packages and state-of-the-art data science tips.

<a name="refs"></a>
### Self-paced reading and studying

**Online courses**:

* Applied Bioinformatics Core's Datacamp Course [Introduction to R](https://www.datacamp.com/courses/abc-intro-2-r)
* Applied Bioinformatics Core's [Introduction to version control using RStudio](https://www.datacamp.com/courses/abc-intro-2-git-in-rstudio)
* [Michael Love's Intro to Computational Biology](https://biodatascience.github.io/compbio/)

**Articles**

* Nature Methods has compiled a great selection of brief introductions into many statistical concepts that biologists should be familiar with, such as p-value calculations, replicate handling, visualizations etc.: [Points of Significance Series](https://www.nature.com/collections/qghhqm/pointsofsignificance)
* F100Research: [Channels](https://f1000research.com/gateways) 

**Community**

* Biostars
* Seqanswers

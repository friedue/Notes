The ABC has compiled a comprehensive introduction into the principles of high-throughput DNA sequencing and the details of the bioinformatics processing and analyses with a focus on conventional RNA-seq. The course notes can be found [here](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf).


>Efficient analysis and interpretation of Big Data opens new avenues to explore molecular biology, new questions to ask about physiological and pathological states, and new ways to answer these open issues. Such analyses lead to better understanding of diseases and development of better and personalized diagnostics and therapeutics. However, such progresses are directly related to the availability of new solutions to deal with this huge amount of information. New paradigms are needed to store and access data, for its annotation and integration and finally for inferring knowledge and making it available to researchers. Bioinformatics can be viewed as the “glue” for all these processes.

Efficient processing, storage and retrieval of large-scale sequencing data sets are crucially important for modern 'big-data-driven' life science. 

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

### Parameters to consider for experimental design

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

## Replicates

For many HTS applications, the ultimate goal is to find the subset of regions or genes that show differences between the conditions that were analyzed. For example, you may 
For more details about experimental design considerations, see Section 1.4 of the [Introduction to RNA-seq](http://chagall.med.cornell.edu/RNASEQcourse/Intro2RNAseq.pdf), [Altman N and Krzywinski M. (2014) Nature Methods, 12(1):5–6, 2014](http://dx.doi.org/10.1038/nmeth.3224), [Blainey et al. (2014) Nature Methods, 1(9) 879–880](https://www.nature.com/articles/nmeth.3091)


Technical replicates are therefore repeated measurements of the same sample while biological replicates are parallel measurements of biologically distinct samples that capture random biological variation 


![](https://raw.githubusercontent.com/friedue/Notes/master/images/intro/replicates.png)

## Helpful references and additional material

### Classes, workshops, hands-on help at WCM

* Q-Bi0
* Intro to UNIX
* Intro to R
* Intro to RNA-seq analysis

* Walk-in clinic
* d:bug

### Self-paced reading and studying

* [Points of Significance Series of Nature Methods](https://www.nature.com/collections/qghhqm/pointsofsignificance)
* [Michael Love's Intro to Computational Biology](https://biodatascience.github.io/compbio/)
* F100Research: [Channels](https://f1000research.com/gateways) 
* Applied Bioinformatics Core's Datacamp Course [Introduction to R](https://www.datacamp.com/courses/abc-intro-2-r)
* Applied Bioinformatics Core's [Introduction to version control using RStudio](https://www.datacamp.com/courses/abc-intro-2-git-in-rstudio)

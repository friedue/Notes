# Motif analyses

## MEME suite

### Discovery

If you have a set of sequences and you want to discover new motifs you need to use MEME, DREME or MEME-ChIP.
MEME can discover more complex motifs than DREME but it requires far more processing resources (see [MEME: Dataset size and run time issues](https://groups.google.com/forum/#%21topic/meme-suite/QJiJsy1QxYk) )
and for that reason you may need to randomly subsample your dataset.
The public web application for MEME is **limited to 60kb of input sequences**!

#### DREME 

DREME discovers lots of short motifs relatively quickly (compared to MEME) and can handle much larger datasets before the runtime becomes intractable.
DREME is more suitable for short motifs, but is limited to motifs less that 8bp wide. 
DREME discovers motifs by finding matches to regular expressions that are enriched in the positive sequence set over the negative sequence set. At one step in the algorithm, the number of sequences containing a match to a regular expression is compared between the two sets. However, each sequence is counted only once, whether it contains 1 match or 100 matches. Longer sequences are more likely to contain multiple matches, so if you submit a collection of long sequences to DREME it may miss some significant motifs. The multiple matches in a single sequence won't add to the evidence for the motif. You'll increase DREME's sensitivity if you break up your 1000bp sequences into 10 100bp sequences.
 DREME depends on having two sets of sequences, one containing instances of the motifs and one not. If you don't provide a negative sequence set, DREME generates one by randomly shuffling the sequences you do provide. DREME then counts the number of exact matches in the two sequence sets to all words between length 4 and 8 in the two sets. At this stage wildcards are not part of the allowed alphabet. For each word DREME compares the number of exact matches in the positive and negative sets, and picks initial candidate motifs based on the p-value of the Fischer exact test for the counts in the two sets. The candidate motifs are then extended by adding wild cards to the allowed alphabet. If two motifs end up with the same significant final p-value they are both reported.
Once you've identified the motif and have a PWM, you can then scan a sequence database using FIMO or CentriMO.
 [Dreme Ref](https://groups.google.com/forum/#!searchin/meme-suite/DREME$20command$20line%7Csort:date/meme-suite/zOyDpLLtH_U/WLiOxdD0AwAJ)

DREME works best with lots of short (ca. 100bp) sequences.
If you have a couple of long sequences then it might be beneficial to split them into many smaller (ca. 100bp) sequences. With ChIP-seq data we recommend using 100bp regions around the peaks. [DREME tutorial](http://meme-suite.org/doc/dreme-tutorial.html?man_type=web)

If you happen to have a control sequence set (aka negative sequences) containing motifs you don't want to discover then you can perform discriminative motif discovery with both MEME and DREME.
The method for MEME is a little more involved (see [How do I perform discriminative motif discovery using the command line version of MEME?](https://groups.google.com/forum/#%21topic/meme-suite/wRcngYMKllE)).

MEME-ChIP is designed to make running MEME and DREME (as well as Tomtom and CentriMo) on ChIP-seq data easy.
All you have to do is provide it with a set of sequences which are all the same length (between 300bp and 500bp) 
which are centered on the ChIP-seq peaks and it will do the rest.

[**GC bias for MEME or DREME**](https://groups.google.com/forum/#!searchin/meme-suite/DREME$20command$20line|sort:date/meme-suite/N7WBZASOBvE/COPsSlJsAAAJ):

MEME adjusts for the biases in letters and groups of letters using the background model
that you provide.  A 1-order model (made using fasta-get-markov) adjusts for dimer biases
(like GC).

DREME does not use a background model, and normalization depends on the control
dataset it is provide with.

MEME-ChIP uses fasta-shuffle-letters with -kmer 2, preserving
dimer frequencies.  You could try manually creating a -kmer 3 (or higher) set of shuffled
sequences, and rerunning DREME with them.  Refer to the "Program Information" section
of your MEME-ChIP output to see how you would do this.


**Tips for using MEME with ChIP-seq data**: [Ref](https://groups.google.com/forum/#%21topic/meme-suite/rIbjIHbcpAE)

When there are 1000s of peaks, MEME can find the main motif easily in just a *subsample* of the peaks.
There is not much to be gained by including more than 1000 peaks, and MEME run time will increase greatly.

As of MEME release 4.4.0 patch 1 the MEME distribution contains a perl script called `fasta-subsample`.
This perl script lets you select the number of sequences you want in your new file.
Keep the number of sequences **under 1000** for reasonable MEME run times. 
Also, if the total length of sequences is 100,000 expect run times of about 20 minutes per motif (DNA, -revcomp, ZOOPS).

A typical use would be:

```
fasta-subsample all_chip_seqs.fasta 500 -rest cv.fasta -seed 1 > meme.fasta
```

The ZOOPS model with the -revcomp switch is usually the best choice for running MEME on ChIP-seq data.
The following command has worked well for us with ChIP-seq peak sequences:

```
meme meme.fasta -dna -revcomp -minw 5 -maxw 20
```


### Comparison

If you have an existing motif (ie from MEME, DREME or maybe a consensus sequence) and want to find other similar motifs then you should use Tomtom. Tomtom can take in a file of query motifs and compare them to multiple files containing potentially similar motifs.  Unless you have hundreds of motifs to search then I recommend you use the website version as it can automatically create MEME style motifs to search with from consensus sequences (allowing for IUPAC codes) or frequency/count matrices.

### Sequence Search

If you have a motif that you want to find in a set of sequences then you should use FIMO.
Note that you can't just scan a genome with a motif an expect that all sites you find are biologically active, 
because for most part chance matches will swamp the biologically relevant matches.
This is a well known problem in searching for motifs, jokingly called "The Futility Theorem" 
( Wasserman WW, Sandelin A. Applied bioinformatics for the identification of regulatory elements. Nat Rev Genet 2004;5:276-87.). 
Basically you will need to combine the motif with other sources of information.


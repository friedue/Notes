Rob Patro:

>Selective alignment is simply an efficient mechanism to compute actual alignment scores, it performs sensitive seeding, seed chaining & scoring, and crucially, actually computes an alignment score (via DP), while pseudo-alignment does not do these things, and is a way to quickly determine the likely compatibility between a read and a set of references.

> Both of the approaches are algorithmic ways to return, in the case of pseudoalignment, sets of references [that are most compatible with the reads at hand],
and in the case of selective alignment, scored mappings. They can both be run over "arbitrary" referenced indices.

>If you don't (1) validate the "compatibility" you find and (2) seed in a sensitive fashion, then you end up with mappings whose accuracy is lesser than that derived from alignments. [see their pre-print on this](https://www.biorxiv.org/content/10.1101/657874v1)

> For example, a 100bp read could "pseudoalign" to a transcript with which it shares only a single k-mer although that would preclude any reasonable quality alignment. There is no scoring adopted in the determination of compatibility, which can and does lead to spurious mapping.

Rob Patro:

>Selective alignment is simply an efficient mechanism to compute actual alignment scores, it performs sensitive seeding, seed chaining & scoring, and crucially, actually computes an alignment score (via DP), while pseudo-alignment does not do these things, and is a way to quickly determine the likely compatibility between a read and a set of references.

> Both of the approaches are algorithmic ways to return, in the case of pseudoalignment, sets of references [that are most compatible with the reads at hand],
and in the case of selective alignment, scored mappings. They can both be run over "arbitrary" referenced indices.

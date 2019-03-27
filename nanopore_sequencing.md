## Nanopore sequencing

Details of the methods were taken from [Deamer et al., 2016](https://www.nature.com/articles/nbt.3423#f3) and [Jain et al., 2016](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-016-1103-0).

>BASIC PRINCIPLE: intact DNA is ratcheted through a nanopore base-by-base and the identity of the bases are determined by distinct changes in current.

![](images/nanopore_principle.png)

* setup: 
    - membrane
    - salt solution
    - proteins that form pores just big enough to let single strands of DNA pass through
* the **nanopore** = biosensor _and_ only passageway for exchange between the ionic solution on two sides of a membrane
  - ionic conductivity through the narrowest region of the nanopore is particularly sensitive to the presence of a nucleobase's mass and its associated electrical field
  - different bases will invoke different changes in the ionic current levels that pass through the pore
* the DNA molecule is prepared for sequencing
    - fragmentation (mostly to achieve uniformity in the fragment size distributions)
    - **adapters** at both ends
        - *lead adapter* allows loading of a enzyme at the 5' end (the "motor protein")
        - *trailing adapter*: facilitates strand capture by concentrating DNA substrates at the membrane surface proximal to the nanopore
	- *hairpin adapter* permits contiguous sequencing of both strands: covalently connects both strands so that the second strand is not lost while the first is being passed through the pore

![](images/nanopore_processing.png)

* the ratchet **enzyme**
    - ensures:
      - unidirectional and *single*-nucleotide displacement
      - at a *slow* pace so that the signal can actually be registered
      - is typically an enzyme that processes single-nucleotides in real life, e.g. polymerases, exonucleases etc. -- the trick, of course, is to inhibit the catalysis of the actual processing and to just make use of the protein's capability to access one nucleotide at a time
      

![](images/nanopore_processing02.png)

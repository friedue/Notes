# RNA velocity

## Basics

* Goal: **predict the future expression state of a cell**
 * input: two gene-by-cell matrices
 	* one with spliced (`S`)
 	* one with unspliced counts (`U`)

For each *gene*, a phase-plot is constructed.
That phase-plot is used to estimate the gene- and cell-specific velocity.
The phase-plot is a scatterplot of the relevant row (gene) from the U and S matrices (well, a moment estimator of these quantities, but that is a minor point). In other words, the gene-specific velocities are determined by the relationship of S and U. [(HansenLabBlog)](http://www.hansenlab.org/velocity_batch)

In the words of the Theis Lab:
>VFor each gene, a steady-state-ratio of pre-mature (unspliced) and mature (spliced) mRNA counts is fitted, which constitutes a constant transcriptional state. Velocities are then obtained as **residuals from this ratio**. Positive velocity indicates that a gene is up-regulated, which occurs for cells that show higher abundance of unspliced mRNA for that gene than expected in steady state. Conversely, negative velocity indicates that a gene is down-regulated.

[This gif](https://user-images.githubusercontent.com/31883718/80227452-eb822480-864d-11ea-9399-56886c5e2785.gif) illustrates the principles.

In brief, velocity is estimated for each gene in each cell and then projected into lower dimensional space to reveal the direction of *cell* fate transitions.
The extraplolation of traditional RNA velocity measurements is valid for approx. a couple of hours (based on [Qiu et al., 2022](https://doi.org/10.1016/j.cell.2021.12.045).

### Batch effect 

Batch effect seems to be present according to the Hansen Lab. [(HansenLabBlog)](http://www.hansenlab.org/velocity_batch)

Challenge for RNA velocity: we need to batch correct not 1 but 2 matrices simultaneously

`scVelo` currently does not pay attention to this, as they state "any additional preprocessing step only affects X and is not applied to spliced/unspliced counts." [(Ref)](https://colab.research.google.com/github/theislab/scvelo_notebooks/blob/master/VelocityBasics.ipynb#scrollTo=SgjdS1emFTbq)

## Processing details

The starting point for any type of velocity analysis: **2 count matrices of pre-mature (unspliced) and mature (spliced) abundances**.

These can be obtained from standard sequencing protocols, using the `velocyto.py` or `loompy/kallisto` counting pipeline.

[**Velocyto**](http://velocyto.org/velocyto.py/tutorial/index.html) offers multiple wrappers around 10X Genomics (CellRanger) data, Smart-seq2 data etc.
It essentially looks at every single mapped read and determines whether it represents a spliced, unspliced or ambiguous molecule.

The BAM file will have to:

- Be sorted by mapping position.
- Represents either a single sample (multiple cells prepared using a certain barcode set in a single experiment) or single cell.
- Contain an error corrected cell barcodes as a TAG named CB or XC.
- Contain an error corrected molecular barcodes as a TAG named UB or XM.

```
# typical use case
velocyto run10x -m repeat_msk.gtf mypath/sample01 somepath/refdata-cellranger-mm10-1.2.0/genes/genes.gtf
```

The output is a 4-layered [loom file](http://linnarssonlab.org/loompy/index.html), i.e. an HDF5 file that contains specific groups representing the main matrix as well as row and column attribute. ([loom details here](http://linnarssonlab.org/loompy/conventions/index.html)).

For a more detailed run-down of how to move from R-processed data over to velocity, see [Sam's description](https://smorabit.github.io/tutorials/8_velocyto/)

### scanpy, scVelo and AnnData

scVelo is based on `adata`

- stores a data matrix `adata.X`,
- annotation of observations `adata.obs`
- variables `adata.var`, and 
- unstructured annotations `adata.uns`
- computed velocities are stored in `adata.layers` just like the count matrices. 

**Names** of observations and variables can be accessed via `adata.obs_names` and `adata.var_names`, respectively. 

AnnData objects can be sliced like dataframes: `adata_subset = adata[:, list_of_gene_names]`. For more details, see the [anndata docs](https://anndata.readthedocs.io/en/latest/api.html).

### Additional resources:

* For getting a better understanding of `AnnData`, it probably serves to look at a general `pandas` tutorial, e.g. [this one](https://blog.jetbrains.com/datalore/2021/02/25/pandas-tutorial-10-popular-questions-for-python-data-frames/)
* A good overview of typical `scanpy` commands (incl. PCA, UMAP), is given by the [PBMC tutorial](https://scanpy-tutorials.readthedocs.io/en/latest/pbmc3k.html).
* The [complete run-down of **scVelo** and visualization commands](https://scvelo.readthedocs.io/VelocityBasics.html)

Testing Seurat's label transfer
================================

> Friederike Dündar | 10/26/2020

## `Seurat`'s Azimuth workflow

>Azimuth, a workflow to leverage high-quality reference datasets to rapidly map new scRNA-seq datasets (queries). For example, you can map any scRNA-seq dataset of human PBMC onto our reference, automating the process of visualization, clustering annotation, and differential expression. Azimuth can be run within Seurat, or using a standalone web application that requires no installation or programming experience.
[Ref](https://satijalab.org/seurat/)

The [vignette](https://satijalab.org/seurat/v4.0/reference_mapping.html) is based on `Seurat v4` and describes how to transfer labels from [CITE-seq reference of 162,000 PBMC measures with 228 antibodies](https://www.biorxiv.org/content/10.1101/2020.10.12.335331v1)

>in this version of Azimuth, **we do not recommend mapping samples that have been enriched to consist primarily of a single cell type. This is due to assumptions that are made during SCTransform normalization**, and will be extended in future versions.
[Ref: app description](https://satijalab.org/azimuth/)

## How to handle batches

>UMAP and label transfer results are very similar whether a dataset containing multiple batches is mapped one batch at a time or combined. However, the mapping score returned by the app (see below for more discussion) may change. In the presence of batch effects, cells from certain batches sometimes receive high mapping scores when the batches are mapped separately but receive low mapping scores when batches are mapped together. Since the mapping score is meant to identify cells that are defined by a source of heterogeneity that is not present in the reference dataset, the presence of batch effects may cause low mapping scores.
[Ref](https://satijalab.org/azimuth/)

## Prediction vs. mapping score

**prediction score**: 

Prediction scores are calculated based on the cell type identities of the reference cells near to the mapped query cell.

- For a given cell, the sum of prediction scores for all cell types is 1.
- The PS for a given assigned cell type is the maximum score over all possible cell types
- the higher it is, the more **reference cells near a query cell have the same label**
- low prediction score may be caused if the probability for a given label is equally split between two clusters

**mapping score**:

From `?MappingScore()`

>This metric was designed to help identify query cells that aren't
     well represented in the reference dataset. The intuition for the
     score is that we are going to project the query cells into a
     reference-defined space and then project them back onto the query.
     By comparing the neighborhoods before and after projection, we
     identify cells who's local neighborhoods are the most affected by
     this transformation. This could be because there is a population
     of query cells that aren't present in the reference or the state
     of the cells in the query is significantly different from the
     equivalent cell type in the reference.

- This value from 0 to 1 reflects confidence that this cell is well represented by the reference
- cell types that are not present in the reference should have lower mapping scores


### How can a cell get a high prediction score and a low mapping score?

>A high prediction score means that a high proportion of reference cells near a query cell have the same label. However, these reference cells may not represent the query cell well, resulting in a low mapping score. Cell types that are not present in the reference should have lower mapping scores. For example, we have observed that query datasets containing neutrophils (which are not present in our reference), will be confidently annotated as CD14 Monocytes, as Monocytes are the closest cell type to neutrophils, but receive a low mapping score.

### How can a cell get a low prediction score and a high mapping score?

> A cell can get a low prediction score because its probability is equally split between two clusters (for example, for some cells, it may not be possible to confidently classify them between the two possibilities of CD4 Central Memory (CM), and Effector Memory (EM), which lowers the prediction score, but the mapping score will remain high.

## UMAP

From the help of `ProjectUMAP()`:

 This function will take a query dataset and project it into the coordinates of a provided reference UMAP. This is essentially a wrapper around two steps:

* `FindNeighbors()`: Find the nearest reference cell neighbors and
          their distances for each query cell.
*  `RunUMAP()`: Perform umap projection by providing the neighbor
     set calculated above and the umap model previously computed
    in the reference.

If there are cell states that are present in the query dataset that are not represented in the reference, they will project to the most similar cell in the reference. This is the expected behavior and functionality as established by the UMAP package, but can potentially mask the presence of new cell types in the query which may be of interest.
 

## Recommended "de novo" visualization by merging the PCs for reference and query

```
#merge reference and query
reference$id <- 'reference'
pbmc3k$id <- 'query'
refquery <- merge(reference, pbmc3k)
refquery[["spca"]] <- merge(reference[["spca"]], pbmc3k[["ref.spca"]])
refquery <- RunUMAP(refquery, reduction = 'spca', dims = 1:50)
DimPlot(refquery, group.by = 'id')
```

# Spatial transcriptomics

[Github repo](https://github.com/SpatialTranscriptomicsResearch) of the original lab that developed Visium

* [Viewer](https://github.com/jfnavarro/st_viewer/wiki)

## Detection of genes whose expression is highly localized

### Mark variogram

A spatial pattern records the locations of events produced by an underlying spatial process in a study region.

`spatstat`[http://www.spatstat.org/] package

Auxiliary information attached to each point in the point pattern is called a mark and we speak of a marked point pattern.

**Variogram**:

- function describing the degree of spatial dependence of a spatial random field
- how much do the values of two marks differ depending on the distance between those samples (assumption: samples taken far apart will vary more than samples taken close to each other)
- variogram = variance of the difference between fiedl values at two locations

#### Application to spatial transcriptomics

Originally introduced by the Sandberg Lab [(Edsgard, Johnsson & Sandberg (2018), Nat Methods)](https://www.nature.com/articles/nmeth.4634) in their package [`trendsceek`](https://github.com/edsgard/trendsceek):

>To identify genes for which dependencies exist between the spatial distribution of cells and gene expression in those cells, we modeled data as marked point processes, which we used to rank and assess the significance of the spatial expression trends of each gene. 

* points = spatial locations of cells (or regions)
* marks on each point = expression levels
* tests for significant dependency between the spatial distributions of points and their associated marks (expression levels) through **pairwise analyses of points as a function of the distance r (radius)** between them
* if marks and the locations of points are independent, the scores obtained should be constant across the different distances r
* To assess the significance of a gene's spatial expression pattern, we implemented a resampling procedure in which the expression values are permuted, reflecting a null model with no spatial dependency of expression

They also applied their method to the coordinates defined by UMAP/t-SNE

>spatial methods have the ability to identify continuous gradients or spatial expression patterns defined by fewer genes that would be hard to identify through clustering of pairwise cellular expression profile correlations 
>
>- only a subset of highly variable genes have significant spatial expression patterns

* For the distribution of all pairs at a particular radius, a mark segregation is said to be present if the distribution is dependent on r such that it deviates from what would be expected if the marks were randomly distributed
* Four summary statistics of the pair distribution were calculated for each radius and compared to the null distribution of the summary statistic derived from the permuted expression labels. 

### SpatialDE

* [Svensson et al.](https://www.nature.com/articles/nmeth.4636)
* [repo of the python package](https://github.com/Teichlab/SpatialDE/)

### Splotch

* [Aijo et al.](https://www.biorxiv.org/content/10.1101/757096v1.full.pdf+html)
* [repo](https://github.com/tare/Splotch)

## Spatial representations in R

### `sf` library

from [Jesse Sadler](https://www.jessesadler.com/post/simple-feature-objects/)

`sf class object` = `sfg` + `sfc` objects

- basically a data frame with rows of features, columns of attributes and a special geometry column with the spatial aspects of the features
	- `sf` object: collection of simple features represented by a data frame
	- `sfg` object: geometry of a single feature 
	- `sfc` object: geometry *column* with the spatial attributes of the object printed above the data frame


### `sfg` 

Represents the coordinates of the objects.

Geometry types:

| Name | Represents | Created with | Function |
|-----|-------------|--------------|----------|
| POINT | a single point | a vector | `sf_point()` |
| MULTIPOINT |multiple points |matrix with each row = point | `sf_multipoint()` |
LINESTRING | sequence of two or more points connected by straight lines | matrix with each row = point | `sf_linestring()` |
| MULTILINESTRING | multiple lines | list of matrices | `sf_multilinestring()`
| POLYGON | closed (!) ring with zero or more interior holes | list of matrices | `sf_polygon()`|
| MULTIPOLYGON |  multiple polygons | list of list of matrices | `sf_multipolygon()` |
| GEOMETRYCOLLECTION | any combination of the above types | list that combines any of the above | `sf_geometrycollection()` |

### `sfc`

For representing *geospatial* data, i.e. they are lists of of one ore more `sfg` objects with attributes that contain the coordinate reference system 

Functions for creating `sfc` objects: `st_sfc(multipoint_sfg)` (this would create an `sfc` object with `NA`'s in the `epsg` and `proj4string` attributes)

### Creating an `sf` object

The `sf` objects combine the spatial information with any number of attributes, e.g. names, values etc.

They can be created with the `st_sf()` function
	* joins a df to an sfg object
	
## Generating a point pattern (`ppp`)  object for `markvariogram` function (`spatstat` package)

```
## extract coordinates
spatial.coords <- reducedDim(sce.obj, coords_accessor)

## generate ppp object
  x.coord = spatial.coords[, 1]
  y.coord = spatial.coords[, 2]

  pp <- ppp(
    x = x.coord,
    y = y.coord,
    xrange = range(x.coord),
    yrange = range(y.coord)
  )
pp[["marks"]] <- as.data.frame(x = t(x = exprs_data))
mv <- markvario(X = pp, normalise = TRUE, ...)
```
	

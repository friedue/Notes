# Dimensionality reduction techniques

we are concerned with defining similarities between two objects *i* and *j*  in the high dimensional input space *X* and low dimensional embedded space *Y* 

>It is interesting to think about why basically each of the techniques is applicable in one particular research area and not common in other areas. For example, Independent Component Analysis (ICA) is used in signal processing, Non-Negative Matrix Factorization (NMF) is popular for text mining, Non-Metric Multi-Dimensional Scaling (NMDS) is very common in Metagenomics analysis etc., but it is rare to see e.g. NMF to be used for RNA sequencing data analysis. [Oskolkov](https://towardsdatascience.com/reduce-dimensions-for-single-cell-4224778a2d67)

* PCA
* UMAP
* tSNE
* diffusion map

>linear dimensionality reduction techniques can not fully resolve the heterogeneity in the single cell data. (...) Linear dimension reduction techniques are good at preserving the global structure of the data (connections between all the data points) while it seems that for single cell data it is more important to keep the local structure of the data (connections between neighboring points). [Oskolkov](https://towardsdatascience.com/reduce-dimensions-for-single-cell-4224778a2d67)

## UMAP: Uniform Manifold Approximation and Projection for Dimension Reduction

"The UMAP algorithm seeks to find an embedding by searching for a low-dimensional projection of the data that has the closest possible equivalent fuzzy topological structure"

Cost function: Cross-Entropy --> probably the main reason for why UMAP can preserve the global structure better than tSNE

![](https://pubs.acs.org/na101/home/literatum/publisher/achs/journals/content/ancham/2019/ancham.2019.91.issue-9/acs.analchem.8b05827/20190501/images/medium/ac-2018-05827j_0009.gif)

[Mathematical background](https://arxiv.org/abs/1802.03426)

3 basic assumptions [1](https://umap-learn.readthedocs.io/en/latest/):


1. The data is uniformly distributed on Riemannian manifold;
2. The Riemannian metric is locally constant (or can be approximated as such);
3. The manifold is locally connected.

In contrast to tSNE, UMAP *estimates* the nearest-neighbors distances (with the [nearest-neighbor-descent algorithm](https://dl.acm.org/citation.cfm?id=1963487)), which relieves some of the computational burden

From [Oskolkov](https://towardsdatascience.com/how-exactly-umap-works-13e3040e1668): 
Both tSNE and UMAP essentially consist of two steps:

1. Building a **graph** in high dimensions and computing the bandwidth of the exponential probability, σ, using the binary search and the fixed number of nearest neighbors to consider.
2. **Optimization of the low-dimensional representation** via Gradient Descent. The second step is the bottleneck of the algorithm, it is consecutive and can not be multi-threaded. Since both tSNE and UMAP do the second step, it is not immediately obvious why UMAP can do it more efficiently than tSNE. 

### `n_neighbors`

- constraining the size of the local neighborhood when learning the manifold structure
- low values --> focus on local structure
- default value: 15

### `min_dist`

- minimum distance between points in the low dimensional representation
- low values --> clumps
- range: 0-1; default: 0.1

### `n_components`

= number of dimensions in which the data should be represented

### `metric`

- distance computation, e.g. Euclidean, Manhttan, Minkowski...

## tSNE

The t-SNE cost function seeks to minimize the Kullback–Leibler divergence between the joint probability distribution in the high-dimensional space, *pij*, and the joint probability distribution in the low-dimensional space, *qij*. The fact that both *pij* and *qij* require calculations over all pairs of points imposes a high computational burden on t-SNE. [2](https://pubs.acs.org/doi/10.1021/acs.analchem.8b05827)

From Appendix C of [McInnes et al.](https://arxiv.org/abs/1802.03426):

t-SNE defines input probabilities in three stages:

1. For each pair of points, i and j, in X, a pair-wise similarity, vij, is calculated, Gaussian with respect to the Euclidean distance between xi and xj.
2. The similarities are converted into N conditional probability distributions by normalization. The perplexity of the probability distribution is matched to a user-defined value.
3. The probability distributions are symmetrized and further normalized over the entire matrix of values.

Similarities between pairs of points in the output space *Y* are defined using a Student t-distribution with one degree of freedom on the squared Euclidean distance followed by the matrix-wise normalization to form qij.

Barnes-Hut: only calculate vj|i for n nearest neighbors of i where n is a multiple of the user-selected perplexity; for all other j, vi|j is assumed to be 0 (justified because similarities in the high dimensions are effectively zero outside of the nearest neighbors of each point due to the calibration of the pj|i values to reprorcuce a desired perplexity)

## PCA

PCA relies on the determination of orthogonal eigenvectors along which the largest variances in the data are to be found. PCA works very well to approximate data by a low-dimensional subspace, which is equivalent to the existence of many linear relations among the projected data points.

## Diffusion Map

- based on calculating transition probabilities between cells; this is used to calculate the diffusion distance
- main idea: embed data into a lower-dimensional space such that the Euclidean distance between points approximates diffusion distance data [3](www.dam.brown.edu/people/mmcguirl/diffusionmapTDA.pdf)

1. Calculate diffusion distance: K(x,y) = exp(- (|x-y|)/alpha)
2. Create distance/kernel matrix: Kij = K(xi, xj)
3. Create diffusion matrix (Markov) M by normalizing so that sum over rows is 1
4. Calculate eigenvectors of M, sort by eigenvalues
5. Return top eigenvectors
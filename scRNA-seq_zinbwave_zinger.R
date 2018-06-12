# https://github.com/statOmics/zinbwaveZinger/blob/master/realdata/clusteringW/de.Rmd 
#https://github.com/statOmics/zinbwaveZinger/blob/master/realdata/usoskin/de.Rmd
library(scater)
library(zinbwave)

computeObservationalWeights <- function(model, x){
## if not part of zinba wave already
## taken from: https://github.com/statOmics/zinbwaveZinger/blob/master/realdata/usoskin/de.Rmd
  mu <- getMu(model)
  pi <- getPi(model)
  theta <- getTheta(model)
  theta <- matrix(rep(theta, each = ncol(x)), ncol = nrow(x))
  nb_part <- dnbinom(t(x), size = theta, mu = mu)
  zinb_part <- pi * ( t(x) == 0 ) + (1 - pi) *  nb_part
  zinbwg <- ( (1 - pi) * nb_part ) / zinb_part
  t(zinbwg)
}

load("../data/sce_2018-02-20_filteredCellsGenes.rda") #sce.filt
BiocParallel::register(BiocParallel::SerialParam())


### Fanny's routine

## prep data
core = core[,colData(core)$seurat %in% 1:2]
core = core[rowSums(assay(core)) > 0, ]
colData(core)$seurat = factor(colData(core)$seurat)

## Compute ZINB-WaVE observational weights
#zinb <- zinbFit(core, X = '~ seurat', epsilon = 1e12)
zinb <- zinbFit(core, epsilon = 1e8, X = '~ Pickingsessions + ourClusters')
counts = assay(core)
weights_zinbwave = computeObservationalWeights(zinb, counts)

colData(se)$ourClusters = factor(colData(se)$ourClusters)
colData(se)$Pickingsessions = factor(colData(se)$Pickingsessions)
design = model.matrix(~ colData(se)$Pickingsessions +
                        colData(se)$ourClusters)
counts = assay(se)
rownames(counts) = rowData(se)[,1]

## zinbwave-weighted edgeR
fit_edgeR_zi <- function(counts, design, weights,
                         filter = NULL){
  library(edgeR)
  d = DGEList(counts)
  d = suppressWarnings(calcNormFactors(d))
  d$weights <- weights 
  d = estimateDisp(d, design)
  fit = glmFit(d,design)
  glm = glmWeightedF(fit, filter = filter)
  tab = glm$table
  tab$gene = rownames(tab)
  de <- data.frame(tab, stringsAsFactors = FALSE)
  de = de[, c('gene', 'PValue', 'padjFilter', 'logFC')]
  colnames(de) = c('gene', 'pval', 'padj', 'logfc')
  de
}

nf <- edgeR::calcNormFactors(counts)
baseMean = unname(rowMeans(sweep(counts,2,nf,FUN="*")))
zinbwave_edgeR <- fit_edgeR_zi(counts, design,
                               weights = weights_zinbwave,
                               filter = baseMean)
zinbwave_edgeR$method <- 'zinbwave_edgeR'

### Berg's routine with multiple clusters----------------------
#https://github.com/statOmics/zinbwaveZinger/blob/master/realdata/usoskin/deAnalysis.Rmd 
cellType= droplevels(pData(eset)[,"Level 3"])
batch = pData(eset)[,"Picking sessions"]
counts = exprs(eset)
keep = rowSums(counts>0)>9
counts=counts[keep,]

core <- SummarizedExperiment(counts,
                             colData = data.frame(cellType = cellType, batch=batch))
zinb_c <- zinbFit(core, X = '~ cellType + batch', commondispersion = TRUE, epsilon=1e12)
weights = computeObservationalWeights(zinb_c, counts)
 d <- DGEList(counts)
  d <- suppressWarnings(edgeR::calcNormFactors(d))
  design <- model.matrix(~cellType+batch)
  d$weights = weights
  d <- estimateDisp(d, design)
  fit <- glmFit(d,design)
L <- matrix(0,nrow=ncol(fit$coefficients),ncol=11)
rownames(L) <- colnames(fit$coefficients)
colnames(L) <- c("NF1","NF2","NF3","NF4","NF5","NP1","NP2","NP3","PEP1","PEP2","TH")
L[2:11,1] <- -1/10 #NF1 vs. others
L[2:11,2] <- c(1,rep(-1/10,9)) #NF2 vs. others
L[2:11,3] <- c(-1/10,1,rep(-1/10,8)) #NF3 vs. others
L[2:11,4] <- c(rep(-1/10,2),1,rep(-1/10,7)) #NF4 vs. others
L[2:11,5] <- c(rep(-1/10,3),1,rep(-1/10,6)) #NF5 vs. others
L[2:11,6] <- c(rep(-1/10,4),1,rep(-1/10,5)) #NP1 vs. others
L[2:11,7] <- c(rep(-1/10,5),1,rep(-1/10,4)) #NP2 vs. others
L[2:11,8] <- c(rep(-1/10,6),1,rep(-1/10,3)) #NP3 vs. others
L[2:11,9] <- c(rep(-1/10,7),1,rep(-1/10,2)) #PEP1 vs. others
L[2:11,10] <- c(rep(-1/10,8),1,rep(-1/10,1)) #PEP2 vs. others
L[2:11,11] <- c(rep(-1/10,9),1) #TH vs. others
lrtListZinbwaveEdger=list()
for(i in 1:ncol(L)) lrtListZinbwaveEdger[[i]] <- zinbwave::glmWeightedF(fit,contrast=L[,i])
padjListZinbEdgeR=lapply(lrtListZinbwaveEdger, function(x) p.adjust(x$table$PValue,"BH"))
deGenesZinbEdgeR=unlist(lapply(padjListZinbEdgeR,function(x) sum(x<=.05)))
deGenesZinbEdgeR


#================================================

## pre-ranked GSEA
library(xCell) # for db
library(fgsea)
library(GSEABase)

## extract genesets from xcell
nagenes = unique(de[is.na(de$logfc), 'gene'])
de = de[!de$gene %in% nagenes, ]
genesets <- unlist(geneIds(xCell.data$signatures))
celltypes <- sapply(strsplit(names(genesets), "%"), function(x) x[1])
names(genesets) <- NULL
gs <- tapply(genesets, celltypes, c)
set.seed(6372)
gsea_res = lapply(unique(de$method), function(x){
  print(x)
  temp = de[de$method == x, ]
  pval = temp$pval
  zscores = qnorm(1 - (pval/2))
  zscores[is.infinite(zscores)] = max(zscores[!is.infinite(zscores)])
  logfc = temp$logfc
  zscores[logfc<0] = -zscores[logfc<0]
  names(zscores) = temp$gene
  if (x == 'seurat') zscores = -zscores
  gsea = fgsea(gs, zscores, nperm = 10000, minSize = 5)
  gsea$method = x
  gsea[order(-abs(gsea$NES)), ]
})
lapply(gsea_res, head)

gseaDf = as.data.frame(do.call(rbind, gsea_res))
gseaDf = gseaDf[gseaDf$size > 100, ]
gseaDf = gseaDf[, c('method', 'pathway', 'NES')]
#gseaDf$method = factor(gseaDf$method, levels = c('edgeR', 'seurat', 'MAST', 'zinbwave_DESeq2', 'limmavoom', 'zinbwave_edgeR'))
sortedPwy = gseaDf[gseaDf$method == 'zinbwave_edgeR', ]
sortedPwy = sortedPwy[order(sortedPwy$NES), 'pathway']
gseaDf$pathway = factor(gseaDf$pathway, levels = sortedPwy)

ggplot(gseaDf, aes(method, pathway)) +
  geom_tile(aes(fill = NES)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_gradient2(low = "blue", high = "red",
                       mid = "white", midpoint = 0,
                       space = "Lab", 
                       name="Normalized\nEnrichment\nScore") +
  ylab('Cell Type') + xlab('Method')
  

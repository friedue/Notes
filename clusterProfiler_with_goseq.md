I've been perpetually annoyed by the fact that clusterProfiler offers useful visualizations, but I don't want to miss out on the correction that GOseq offers.
So, here's a way to combine them both by replacing the p-values of the clusterProfiler result with the goseq results. 
It would probably make sense to use no cut-off when running enrichGO to obtain all possible gene sets.

```
# GOSEQ =================
library(goseq) # package for GO term enrichment that also accounts for gene legnth
gene.vector <- row.names(DGE.results) %in% DGEgenes %>% as.integer
names(gene.vector) <- row.names(DGE.results)
pwf <- nullp(gene.vector, "sacCer3", "ensGene")
GO.wall <- goseq(pwf, "sacCer3", "ensGene")

# CLUSTERPROFILE=========
library(clusterProfiler)
dge <- subset(dgeres, padj <= 0.01 )$ENTREZID
go_enrich <- enrichGO(gene = dge,
                      universe = dgeres$ENTREZID,
                      OrgDb = "org.Sc.sgd.db", 
                      keyType = 'ENTREZID',
                      readable = F, # setting this TRUE won't work with yeast
                      ont = "BP",
                      pvalueCutoff = 0.05, # probably better to turn this off
                      qvalueCutoff = 0.10)
					  
# COMBINE =================

comp.go <- merge(go_enrich@result[,1:7], GO.wall,
  by.x  = "ID", by.y = "category", all = TRUE)
  
## get adjusted goseq p.values
comp.go$padj_for_cp <- p.adjust(comp.go$pvalue, method = "BH") # BH is the default choice in enrichGO

## before we replace, we need to make sure that our df matches the results of enrichGO
rownames(comp.go) <- comp.go$ID
comp.go <- subset(comp.go, !is.na(pvalue))
comp.go <- comp.go[rownames(go_enrich@result),]

## add the goseq-values to the enrichGO results
go.res <- go_enrich
go.res@result$p.adjust <- comp.go$padj_for_cp
go.res@result$pvalue <- comp.go$over_represented_pvalue

# TADAA
dotplot(go.res, showCategory = 10)
````
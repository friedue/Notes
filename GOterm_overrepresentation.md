## ClusterProfiler

* `enrichGO` and `enrichKEGG`: test based on hypergeometric distribution with additional multiple hypothesis-testing correction [Paper](https://www.liebertpub.com/doi/10.1089/omi.2011.0118)

```
## retrieve ENTREZ IDs
eg <-  clusterProfiler::bitr(t_tx$gene_symbol, fromType="SYMBOL", toType="ENTREZID", OrgDb="org.Hs.eg.db") %>% 
    as.data.table
setnames(eg, names(eg), c("gene_symbol", "entrez"))

clstcomp <- eg[t_tx, on = "gene_symbol"] %>%
             .[, c("gene_symbol","entrez","cluster_k60","day","logFC"), with=FALSE] %>% 
             .[!is.na(entrez)] %>% unique

## make a list of ENTREZ IDs, one per cluster
clstcomp.list <- lapply(sort(unique(clstcomp$cluster_k60)), function(x) clstcomp[cluster_k60 == x]$entrez )

## run enrichGO
ck.GO_bp <- compareCluster(clstcomp.list, fun = "enrichGO", OrgDb = org.Hs.eg.db, ont = "BP")

## visualization
dotplot(ck.GO_bp) + ggtitle("Overrepresented GO terms (Biological Processes)")

```

Individual lists (no comparisons)

```
cp.GO_bp.ind <- lapply(clstcomp.list, function(x){
    out <- enrichGO(x, OrgDb = org.Mm.eg.db, universe = unique(deg.dt$entrez), ont = "BP", pvalueCutoff = 0.05, pAdjustMethod = "BH")
    out <- DOSE::setReadable(out, 'org.Mm.eg.db', 'ENTREZID')
    return(out)
})
```

* `geneRatio` should be number of genes that overlap gene set divided by size of gene set
* the number in parentheses for the clusterCompare plot corresponds to the number of genes that were in that group

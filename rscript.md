# Basic use of `Rscript`

Example script content:

```
#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
rnorm(n=as.numeric(args[1]), mean=as.numeric(args[2]))
```

Invoke the script:

```
$ Rscript myScript.R 5 100
```

Obviously, this creates a string vector `args` which contains the entries `5` and `100`

General usage:

```
Rscript [options] [-e expr [-e expr2 ...] | file] [args]
```

Handling mising arguments:

```
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
}
```

For storing helpful information about what types of parameters are expected etc., the `optparse` package is the way to go. [Eric Minikel](https://gist.github.com/ericminikel/8428297) has a great example. Below is a shorter summary:

```
#!/usr/bin/env Rscript
library("optparse")
 
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
    make_option(c("-o", "--out"), type="character", default="out.txt", 
              help="output file name [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser); # list with all the arguments sorted by order of appearance in option_list
```

Arguments can be called by their names; here: `opt$file` and `opt$out`:

```
## program...
df = read.table(opt$file, header=TRUE)
num_vars = which(sapply(df, class)=="numeric")
df_out = df[ ,num_vars]
write.table(df_out, file=opt$out, row.names=FALSE)
```

## References

- <https://www.r-bloggers.com/2015/09/passing-arguments-to-an-r-script-from-command-lines/> 
- <https://github.com/gastonstat/tutorial-R-noninteractive/blob/master/03-rscript.Rmd>
- <https://gist.github.com/ericminikel/8428297>
- [Great presentation touching on all important points](https://nbisweden.github.io/RaukR-2018/working_with_scripts_Markus/presentation/WorkingWithScriptsPresentation.html#1)

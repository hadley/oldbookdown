
doc_type <- function() knitr::opts_knit$get('rmarkdown.pandoc.to')

is_latex <- function() {
  identical(doc_type(), "latex")
}

`%||%` <- function(a, b) if (is.null(a)) b else a

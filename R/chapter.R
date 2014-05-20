#' @export
html_chapter <- function(raw = FALSE) {
  library(bookdown)

  base <- rmarkdown::html_document(
    self_contained = FALSE,
    lib_dir = "www",
    template = if (raw) system.file("raw-html.html", package = "bookdown") else "default",
    mathjax = if (raw) NULL else "default"
  )
  base$knitr <- knitr_opts("html")
  base
}

#' @export
pdf_chapter <- function(toc = FALSE, book = FALSE) {
  library(bookdown)

  base <- rmarkdown::pdf_document(
    keep_tex = TRUE,
    template = system.file("book-template.tex", package = "bookdown"),
    latex_engine = "xelatex"
  )
  base$knitr <- knitr_opts("tex")
  base
}

#' @export
tex_chapter <- function(toc = FALSE, book = FALSE) {
  library(bookdown)

  base <- rmarkdown::pdf_document(
    template = NULL,
    latex_engine = "xelatex",
    pandoc_args = c("--chapters")
  )
  base$pandoc$ext <- ".tex"
  base$knitr <- knitr_opts("tex")

  base
}


knitr_opts <- function(type = c("html", "tex")) {
  type <- match.arg(type)

  chunk <- list(
    comment = "#>",
    collapse = TRUE,
    error = FALSE,
    cache.path = "_cache/",
    fig.path = "figures/",
    fig.width = 4,
    fig.height = 4
  )
  if (type == "html") {
    chunk$dev <- "png"
    chunk$dpi <- 96
    chunk$fig.retina <- 2
  } else {
    chunk$dev <- "pdf"
  }

  rmarkdown::knitr_options(opts_chunk = chunk)
}

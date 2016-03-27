
#' @export
html_chapter <- function(raw = FALSE, toc = NULL, code_width = 80) {
  base <- rmarkdown::html_document(
    self_contained = FALSE,
    lib_dir = "www",
    template = if (raw) system.file("raw-html.html", package = "oldbookdown") else system.file("chapter-html.html", package = "oldbookdown"),
    mathjax = if (raw) NULL else "default"
  )
  # Remove --section-divs option
  base$pandoc$args <- setdiff(base$pandoc$args, "--section-divs")
  base$pandoc$from <- markdown_style



  if (!is.null(toc)) {
    old_p <- base$pre_processor
    base$pre_processor <- function(yaml_front_matter, utf8_input, runtime,
                                knit_meta, files_dir, output_dir) {
      update_links(utf8_input, toc)
      old_p(yaml_front_matter, utf8_input, runtime,
        knit_meta, files_dir, output_dir)
    }
  }

  base
}

#' @export
tex_chapter <- function(chapter = NULL,
                        latex_engine = c("xelatex", "pdflatex", "lualatex"),
                        code_width = 65) {
  options(digits = 3)
  set.seed(1014)

  latex_engine <- match.arg(latex_engine)
  rmarkdown::output_format(
    knitr_opts("html", chapter),
    rmarkdown::pandoc_options(
      to = "latex",
      from = markdown_style,
      ext = ".tex",
      args = c("--chapters", rmarkdown::pandoc_latex_engine_args(latex_engine))
    ),
    clean_supporting = FALSE
  )
}

markdown_style <- paste0(
  "markdown",
  "+autolink_bare_uris",
  "-auto_identifiers",
  "+tex_math_single_backslash",
  "-implicit_figures"
)

knitr_opts <- function(type = c("html", "latex"), chapter, code_width = 65) {
  type <- match.arg(type)

  pkg <- list(
    width = code_width
  )

  chunk <- list(
    comment = "#>",
    collapse = TRUE,
    cache.path = paste0("_cache/", chapter, "/"),
    cache = TRUE,
    fig.path = paste0("_figures/", chapter, "/"),
    fig.width = 4,
    fig.height = 4,
    fig.retina = NULL,
    dev = if (type == "html") "png" else "pdf",
    dpi = if (type == "html") 96 else 300
  )

  hooks <- list(
    plot = if (type == "latex") html_plot(),
    small_mar = function(before, options, envir) {
      if (before)
        par(mar = c(4.1, 4.1, 0.5, 0.5))
    }
  )

  rmarkdown::knitr_options(pkg, chunk, hooks)
}

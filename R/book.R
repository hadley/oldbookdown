#' @export
build_book <- function(chapters, output_dir = "book") {
  if (!file.exists(output_dir)) dir.create(output_dir)

  tex <- lapply(chapters, rmarkdown::render, tex_chapter(),
      output_dir = output_dir, runtime = "static", envir = new.env(),
      quiet = TRUE)

  options <- c(
    "--template",
    system.file("book-template.tex", package = "bookdown")
  )

  # FIXME: pandoc_convert only accepts single file
  rmarkdown::pandoc_convert(tex, to = "tex", options = options)
  rmarkdown::pandoc_convert(tex, to = "pdf", options = options)
}

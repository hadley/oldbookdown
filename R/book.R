#' @export
build_book <- function(chapters, output_dir = "book") {
  if (!file.exists(output_dir)) dir.create(output_dir)

  tex <- lapply(chapters, rmarkdown::render, md_chapter("tex"),
      output_dir = output_dir, runtime = "static", envir = new.env(),
      quiet = TRUE)

  options <- c(
    "--template",
    system.file("book-template.tex", package = "bookdown")
  )

  rmarkdown::pandoc_convert(md, output = "book.pdf", options = options)
}

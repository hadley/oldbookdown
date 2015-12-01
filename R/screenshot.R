#' Embed a screenshot.
#'
#' This embeds a png screenshot into the document. Generally you should use
#' \code{echo = FALSE} on such blocks. By convention, screenshots should
#' live in a \code{screenshots/} directory.
#'
#' @param path Path to screenshot.
#' @param dpi DPI of image. You can leave this blank if the dpi is stored
#'   in the png metadata
#' @export
screenshot <- function(path, dpi = NULL) {
  meta <- png_meta(path)
  dpi <- dpi %||% meta$dpi[1] %||% stop("Unknown dpi", call. = FALSE)

  if (is_latex()) {
    width <- round(meta$dim[1] / dpi, 2)

    knitr::asis_output(paste0(
      "\\includegraphics[",
      "width=", width, "in",
      "]{", path, "}"
    ))
  } else {
    knitr::asis_output(paste0(
      "<img src='", path, "'",
      " width='", round(meta$dim[1] / (dpi / 96)), "'",
      " height='", round(meta$dim[2] / (dpi / 96)), "'",
      " />"
    ))
  }
}

#' @export
#' @rdname screenshot
embed_png <- screenshot

png_meta <- function(path) {
  attr(png::readPNG(path, native = TRUE, info = TRUE), "info")
}

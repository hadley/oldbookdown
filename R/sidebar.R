#' @export
knit_print.knit_asis <- function(x, ...) x

#' @export
begin_sidebar <- function(title = NULL) {
  if (identical(doc_type(), "latex")) {
    # knitr::asis_output("\\begin{sidebar}")
  } else {
    knitr::asis_output("<div class = 'well'>\n")
  }
}

#' @export
end_sidebar <- function() {
  if (identical(doc_type(), "latex")) {
    # knitr::asis_output("\\end{sidebar}")
  } else {
    knitr::asis_output("</div>\n")
  }
}

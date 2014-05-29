#' @export
knit_print.knit_asis <- function(x, ...) x

#' @export
begin_sidebar <- function(title = NULL) {
  if (identical(doc_type(), "latex")) {
    knitr::asis_output(paste0("\\begin{SIDEBAR}", title, "\\end{SIDEBAR}\n"))
  } else {
    knitr::asis_output(paste0("<div class = 'sidebar'><h3>", title, "</h3>\n\n"))
  }
}

#' @export
end_sidebar <- function() {
  if (identical(doc_type(), "latex")) {
    knitr::asis_output("\\begin{ENDSIDEBAR}\\end{ENDSIDEBAR}\n")
  } else {
    knitr::asis_output("</div>\n")
  }
}

#' @export
latex_plot <- function(x, options) {
  paste0(
    latex_plot_begin(x, options),
    latex_plot_graphics(x, options),
    latex_plot_end(x, options)
  )
}

latex_plot_begin <- function(x, options) {
  if (!knitr_first_plot(options))
    return("")

  paste0(
    "\\begin{figure}[H]\n",
    if (options$fig.align == "center") "  \\centering\n"
  )
}
latex_plot_end <- function(x, options) {
  if (!knitr_last_plot(options))
    return("")

  paste0(
    if (!is.null(options$fig.cap)) {
      paste0(
        '  \\caption{', options$fig.cap, '}\n',
        '  \\label{', options$label, '}\n'
      )
    },
    "\\end{figure}\n"
  )
}
latex_plot_graphics <- function(x, options) {
  cols <- options$columns %||% 1
  max_width <- options$max_width %||% (if (cols == 1) 0.65 else 1)

  # If unknown width/height, compute from columns
  if (is.null(options$out.width) && is.null(options$out.height)) {
    options$out.width <- paste0(round(max_width / cols, 3), "\\linewidth")
  }

  opts <- c(
    sprintf('width=%s', options$out.width),
    sprintf('height=%s', options$out.height),
    options$out.extra
  )

  paste0("  \\includegraphics",
    paste0("[", paste(opts, collapse = ", "), "]"),
    "{", x, "}",
    if (!(options$fig.cur %% col)) "%",
    "\n"
  )
}

knitr_first_plot <- function(x) {
  x$fig.show != "hold" || x$fig.cur == 1L
}
knitr_last_plot <- function(x) {
  x$fig.show != "hold" || x$fig.cur == x$fig.num
}

columns <- function(n, aspect_ratio = 1, max_width = if (n == 1) 0.65 else 1) {
  if (is_latex()) {
    out_width <- paste0(round(max_width / n, 3), "\\linewidth")
    knitr::knit_hooks$set(plot = plot_hook_bookdown)
  } else {
    out_width <- paste0(round(max_width * 100 / n, 1), "%")
  }

  width <- 6 / n * max_width

  knitr::opts_chunk$set(
    fig.width = width,
    fig.height = width * aspect_ratio,
    fig.align = if (max_width < 1) "center" else "default",
    fig.show = if (n == 1) "asis" else "hold",
    fig.retina = NULL,
    out.width = out_width,
    out.extra = if (!is_latex())
      paste0("style='max-width: ", round(width, 2), "in'")
  )
}

#' @export
index <- function() {
  rmd <- dir(pattern = "\\.rmd$")
  headers <- lapply(rmd, extract_headers)
  names(headers) <- rmd

  headers_df <- stack(headers)
  headers_df$ind <- as.character(headers_df$ind)
  new <- setNames(as.list(headers_df$ind), headers_df$values)

  old <- readRDS("toc.rds")
  if (identical(old, new)) {
    return()
  }

  # Save in human readable and R readable
  cat(yaml::as.yaml(headers), file = "toc.yaml")
  saveRDS(new, "toc.rds")
}

#' @export
check_links <- function(path, index_path = "toc.rds") {
  index <- readRDS(index_path)
  body <- parse_md(path)[[2]]

  get_link <- function(type, contents, format, meta) {
    if (type == "Link")
      contents[[2]][[1]]
  }
  links <- walk_inline(body, get_link)
  type <- link_type(links)

  links_by_type <- split(links, type)
  if (length(links_by_type$bad) > 0) {
    message("Bad links: ", paste0(links_by_type$bad, collapse = ", "))
  }
  lapply(gsub("^#", "", links_by_type$internal), lookup, index)
  invisible()
}

# Convert internal links to explicit links also containing the file name
#' @export
update_links <- function(path, index_path = "toc.rds") {
  index <- readRDS(index_path)

  contents <- paste0(readLines(path, warn = FALSE), collapse = "\n")

  int_link_pos <- stringr::str_locate_all(contents, "\\(#[A-Za-z_0-9-]+\\)")[[1]]
  int_link <- stringr::str_sub(contents,
    int_link_pos[, "start"] + 2, # (#
    int_link_pos[, "end"] - 1    # )
  )

  replacement <- vapply(int_link, lookup, character(1), index = index)

  for(i in rev(seq_len(nrow(int_link_pos)))) {
    start <- int_link_pos[i, "start"] + 1
    end <- int_link_pos[i, "end"] - 1
    stringr::str_sub(contents, start, end) <- replacement[i]
  }

  writeLines(contents, path)
}


# Strategy: before running jekyll, parse all .Rmd files and build index
# Modify rmd2md to add json pass that modifies links

# Use pandoc to parse a markdown file
parse_md <- function(in_path) {
  out_path <- tempfile()
  on.exit(unlink(out_path))
  cmd <- paste0("pandoc -f ", markdown_style, " -t json -o ", out_path, " ", in_path)
  system(cmd)

  RJSONIO::fromJSON(out_path, simplify = FALSE)
}

type <- function(x) vapply(x, "[[", "t", FUN.VALUE = character(1))
contents <- function(x) lapply(x, "[[", "c")
id <- function(x) x[[2]][[1]]

extract_headers <- function(in_path) {
  x <- parse_md(in_path)
  body <- x[[2]]
  headers <- contents(body[type(body) == "Header"])

  ids <- vapply(headers, id, FUN.VALUE = character(1))
  ids[ids != ""]
}

link_type <- function(url) {
  ifelse(grepl("^#", url), "internal",
    ifelse(grepl("^[a-z]+://", url), "external",
      "bad"))
}


lookup <- function(name, index = readRDS("toc.rds")) {
  path <- index[[name]]
  if (length(path) == 0) {
    stop("Can't find ref '", name, "'", call. = FALSE)
  } else if (length(path) > 1) {
    stop("Ambiguous ref '", name, "' found in ", paste0(path, collapse = ", "),
      call. = FALSE)
  }

  paste0(gsub(".rmd", ".html", path), "#", name)
}

invert <- function(x) {
  if (length(x) == 0) return()
  unstack(rev(stack(x)))
}

# Walkers ----------------------------------------------------------------------

# action(key, value, format, meta)
#  key is the type of the pandoc object (e.g. 'Str', 'Para')
#  value is the contents of the object (e.g. a string for 'Str', a list of
#     inline elements for 'Para')
#  format is the target output format (which will be taken for the first
#    command line argument if present)
#  meta is the document's metadata.
#
# Return values:
#   NULL, the object to which it applies will remain unchanged.
#   If it returns an object, the object will be replaced.
#   If it returns a list, the list will be spliced in to the list to which the
#     target object belongs. (So, returning an empty list deletes the object.)

# Walker translated from
# https://github.com/jgm/pandocfilters/blob/master/pandocfilters.py
# Data types at
# http://hackage.haskell.org/package/pandoc-types-1.12.3/docs/Text-Pandoc-Definition.html
walk <- function(x, action, format = NULL, meta = NULL) {
  # Base cases
  if (is.null(x)) return()
  if (is.node(x)) return(action(x$t, action$c, format, meta))

  lapply(walk, x, action, format = format, meta = meta)
}

# action must return homogenous output
walk_inline <- function(x, action, format = NULL, meta = NULL) {

  recurse <- function(x) {
    unlist(lapply(x, walk_inline, action, format = format, meta = meta),
      recursive = FALSE)
  }

  # Bare list
  if (is.null(names(x))) return(recurse(x))
  if (!is.list(x)) browser()

  switch(x$t,
    # A list of inline elements
    Plain = ,
    Para = recurse(x$c),
    CodeBlock = NULL,
    RawBlock = NULL,
    # A list of blocks
    BlockQuote = recurse(x$c),
    # Attributes & a list of items, each of which is a list of blocks
    OrderedList = unlist(lapply(x$c[[2]], recurse)),
    # List of items, each a list of blocks
    BulletList = unlist(lapply(x$c, recurse)),
    # Each list item is a pair consisting of a term (a list of inlines) and
    # one or more definitions (each a list of blocks)
    DefinitionList = unlist(lapply(x$c, function(x) recurse(x[[1]]), recurse(x[[2]]))),
    # Third element is list of inlines
    Header = recurse(x$c[[3]]),
    HorizontalRule = NULL,
    # First element is caption, 4th element column eaders, 5th table rows (list
    # of cells)
    Table = c(recurse(x$c[[1]]), recurse(x$c[[4]]), unlist(lapply(x$c[[5]], recurse))),
    # Second element is list of blocks
    Div = recurse(x$c[[2]]),
    Null = Null,
    # Anything else must be a inline element
    action(x$t, x$c, format = format, meta = meta)
  )
}

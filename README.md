# Bookdown

The bookdown package is an R package and set of conventions for making books with Rmarkdown and RStudio. It's designed to produce both a website with one page per chapter, and a PDF for the entire book (future versions might also add epub support).  The process is still rather idiosyncratic and tightly joined to my style of book writing, but it will probably get more flexible in time, and just seeing my approach (and code) might be useful to you.

## Dependencies

To use bookdown, you'll need:

* `make`
* [latekmk](http://users.phys.psu.edu/~collins/software/latexmk-jcc/)
* [pandoc](http://pandoc.org)
* `devtools::install_github("hadley/bookdown")`

## Local setup

* To build a single chapter, use `Cmd + Shift + K` to knit and preview.

* To rebuild the complete book, use `Cmd + Shift + B` to run the makefile 
  and build both the website and the pdf.

* To rebuild everything from scratch, use `Clean and Rebuild` in the build pane.

Note that knitr caching is setup up so that all three ways of building a chapter use the same cache. This saves a lot of time, but can result in out-of-sync caches. It's best to regularly run `make clean` to start from a clean slate.

## Remote setup (e.g. for travis)

The basic looks something like this:

```R
language: r
sudo: required

script:
  - make
```

If you only want to build the website or pdf, use `make html` or `make pdf`. If you're building the PDF, you'll also need:

```yaml
apt-packages:
  # Compresses pngs and fixes colour space problem
  - optipng
  # Tex system with nicest typography
  - texlive-xetex
  # install my favourite code font
  - fonts-inconsolata

before_script:
  # update latex code cache
  - sudo fc-cache -fv
```

If you're deploying to a website hosted on Amazon's S3, you'll need something like this:

```R
deploy:
  provider: s3
  access_key_id: AKIAJYY6UT5EHUXEKWCA
  secret_access_key:
    secure: "Ogjfu+wBbKDtY1VJQnfGejNcxPx2iEwlSgEeTHC7M5jyuSIdYdaf0IbJ9LlDSxA/vcO/NbGOzEdPKevuiRgcU7Bj+J7tlOrvw6WC4R1RK4JQNowuxoDOwNlAvPD5O5DMiIwku+xbjcxyIwU1yPWIjCgpOmAAHMgBeYI+4+N9Ggk="
  bucket: adv-r.had.co.nz
  region: us-west-2
  local-dir: _site
  skip_cleanup: true
```

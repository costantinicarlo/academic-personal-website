#!/usr/bin/env Rscript

# =============================================================================
# build-publications.R
#
# Generate thematic Quarto publication fragments from publications.bib.
#
# Canonical metadata source:
#   bibliography/publications.bib
#
# Required custom BibTeX field:
#   webtheme
#
# Optional custom BibTeX field:
#   webtags
#
# Controlled webtheme vocabulary:
#   adaptation
#   speciation
#   behaviour
#   rhythms
#   population
#   control
#   methods
#   natural-history
#
# The script:
#   1. reads citekeys and website metadata from publications.bib;
#   2. validates the controlled webtheme vocabulary;
#   3. selects publications belonging to each theme;
#   4. asks Quarto's bundled Pandoc/citeproc to format each subset;
#   5. writes one generated .qmd fragment per theme.
#
# Bibliographic formatting remains entirely the responsibility of
# Pandoc/citeproc and the configured CSL file. The script does not rewrite
# or normalize the bibliographic records.
#
# Run from the repository root:
#
#   Rscript scripts/build-publications.R
#
# Then:
#
#   quarto preview
#
# =============================================================================


# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

bib_file <- "bibliography/publications.bib"
csl_file <- "bibliography/csl/apa-cv.csl"
fragment_dir <- "publications/fragments"

themes <- list(

  adaptation = list(
    label = "Adaptation and environmental change",
    research_anchor = "research-adaptation"
  ),

  speciation = list(
    label = "Ecological divergence, speciation and genomic architecture",
    research_anchor = "research-speciation"
  ),

  behaviour = list(
    label = "Behaviour, host choice and chemical ecology",
    research_anchor = "research-behaviour"
  ),

  rhythms = list(
    label = "Biological rhythms and temporal ecology",
    research_anchor = "research-rhythms"
  ),

  population = list(
    label = "Population ecology, demography and dispersal",
    research_anchor = "research-population"
  ),

  control = list(
    label = "Disease transmission and vector control",
    research_anchor = "research-control"
  ),

  methods = list(
    label = "Methods, quantitative and computational approaches",
    research_anchor = "research-methods"
  ),

  `natural-history` = list(
    label = "Natural history and ornithology",
    research_anchor = "research-natural-history"
  )
)


# -----------------------------------------------------------------------------
# Basic checks
# -----------------------------------------------------------------------------

if (!file.exists("_quarto.yml")) {
  stop(
    "Run this script from the root of the Quarto website repository.",
    call. = FALSE
  )
}

if (!file.exists(bib_file)) {
  stop("Bibliography not found: ", bib_file, call. = FALSE)
}

if (!file.exists(csl_file)) {
  stop("CSL file not found: ", csl_file, call. = FALSE)
}

quarto <- Sys.which("quarto")

if (!nzchar(quarto)) {
  stop(
    "The Quarto CLI is not available on PATH.",
    call. = FALSE
  )
}

dir.create(fragment_dir, recursive = TRUE, showWarnings = FALSE)

bib_file_abs <- normalizePath(bib_file, mustWork = TRUE)
csl_file_abs <- normalizePath(csl_file, mustWork = TRUE)


# -----------------------------------------------------------------------------
# Minimal BibTeX parsing
#
# We deliberately do NOT parse/rewrite the full bibliography.
# We need only:
#
#   citekey
#   webtheme
#   webtags
#
# The original .bib file is passed unchanged to Pandoc/citeproc.
# -----------------------------------------------------------------------------

read_bib_entries <- function(path) {

  text <- paste(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )

  starts <- gregexpr(
    "(?m)^\\s*@",
    text,
    perl = TRUE
  )[[1]]

  if (length(starts) == 1L && starts[1] == -1L) {
    return(character())
  }

  ends <- c(
    starts[-1L] - 1L,
    nchar(text)
  )

  entries <- substring(text, starts, ends)

  trimws(entries)
}


extract_entry_type <- function(entry) {

  match <- regexec(
    "^\\s*@([[:alnum:]_:-]+)",
    entry,
    perl = TRUE
  )

  value <- regmatches(entry, match)[[1]]

  if (length(value) < 2L) {
    return(NA_character_)
  }

  tolower(value[2])
}


extract_citekey <- function(entry) {

  match <- regexec(
    "^\\s*@[[:alnum:]_:-]+\\s*[\\{(]\\s*([^,]+?)\\s*,",
    entry,
    perl = TRUE
  )

  value <- regmatches(entry, match)[[1]]

  if (length(value) < 2L) {
    return(NA_character_)
  }

  trimws(value[2])
}


extract_field <- function(entry, field) {

  # Supports the ordinary forms:
  #
  #   field = {value}
  #   field = "value"
  #   field = value

  pattern <- sprintf(
    '(?is)\\b%s\\s*=\\s*(?:\\{([^}]*)\\}|"([^"]*)"|([^,\\r\\n]+))',
    field
  )

  match <- regexec(
    pattern,
    entry,
    perl = TRUE
  )

  value <- regmatches(entry, match)[[1]]

  if (length(value) == 0L) {
    return(NA_character_)
  }

  candidates <- value[-1L]

  candidates <- candidates[
    !is.na(candidates) &
      nzchar(candidates)
  ]

  if (length(candidates) == 0L) {
    return(NA_character_)
  }

  trimws(candidates[1])
}


entries <- read_bib_entries(bib_file)

# Ignore BibTeX structural records if ever present.
entry_types <- vapply(
  entries,
  extract_entry_type,
  character(1)
)

keep <- !entry_types %in% c(
  "string",
  "preamble",
  "comment"
)

entries <- entries[keep]


metadata <- data.frame(
  citekey = vapply(entries, extract_citekey, character(1)),
  webtheme = vapply(
    entries,
    extract_field,
    character(1),
    field = "webtheme"
  ),
  webtags = vapply(
    entries,
    extract_field,
    character(1),
    field = "webtags"
  ),
  stringsAsFactors = FALSE
)


# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

if (anyNA(metadata$citekey) || any(metadata$citekey == "")) {

  stop(
    "At least one BibTeX entry has no readable citekey.",
    call. = FALSE
  )
}


duplicate_keys <- unique(
  metadata$citekey[
    duplicated(metadata$citekey)
  ]
)

if (length(duplicate_keys) > 0L) {

  stop(
    "Duplicate citekeys found:\n  ",
    paste(duplicate_keys, collapse = "\n  "),
    call. = FALSE
  )
}


missing_theme <- metadata[
  is.na(metadata$webtheme) |
    metadata$webtheme == "",
  ,
  drop = FALSE
]

if (nrow(missing_theme) > 0L) {

  stop(
    "The following publications have no webtheme:\n  ",
    paste(missing_theme$citekey, collapse = "\n  "),
    call. = FALSE
  )
}


allowed_themes <- names(themes)

unknown_theme <- metadata[
  !metadata$webtheme %in% allowed_themes,
  ,
  drop = FALSE
]

if (nrow(unknown_theme) > 0L) {

  bad <- paste0(
    unknown_theme$citekey,
    " -> ",
    unknown_theme$webtheme
  )

  stop(
    "Unknown webtheme values found:\n  ",
    paste(bad, collapse = "\n  "),
    "\n\nAllowed values:\n  ",
    paste(allowed_themes, collapse = "\n  "),
    call. = FALSE
  )
}


missing_tags <- metadata[
  is.na(metadata$webtags) |
    metadata$webtags == "",
  ,
  drop = FALSE
]

if (nrow(missing_tags) > 0L) {

  warning(
    "Publications without webtags:\n  ",
    paste(missing_tags$citekey, collapse = "\n  "),
    call. = FALSE
  )
}


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

yaml_quote <- function(x) {
  encodeString(x, quote = '"')
}


highlight_author <- function(html) {

  # CSL styles can represent the same author in several ways.
  # These substitutions are deliberately literal rather than regex-based.

  replacements <- c(
    "Costantini, C." = "<strong>Costantini, C.</strong>",
    "Costantini, Carlo" = "<strong>Costantini, Carlo</strong>",
    "C. Costantini" = "<strong>C. Costantini</strong>",
    "Carlo Costantini" = "<strong>Carlo Costantini</strong>"
  )

  for (pattern in names(replacements)) {

    html <- gsub(
      pattern,
      replacements[[pattern]],
      html,
      fixed = TRUE
    )
  }

  html
}


render_bibliography <- function(keys, slug) {

  input <- tempfile(
    pattern = paste0("publications-", slug, "-"),
    fileext = ".md"
  )

  output <- tempfile(
    pattern = paste0("publications-", slug, "-"),
    fileext = ".html"
  )

  on.exit(
    unlink(c(input, output)),
    add = TRUE
  )

  source <- c(
    "---",
    paste0(
      "bibliography: ",
      yaml_quote(bib_file_abs)
    ),
    paste0(
      "csl: ",
      yaml_quote(csl_file_abs)
    ),
    "nocite: |",
    paste0("  @", keys),
    "---",
    "",
    "::: {#refs}",
    ":::"
  )

  writeLines(
    source,
    input,
    useBytes = TRUE
  )

  command_output <- system2(
    quarto,
    args = c(
      "pandoc",
      shQuote(input),
      "--citeproc",
      "--from=markdown",
      "--to=html",
      "--output",
      shQuote(output)
    ),
    stdout = TRUE,
    stderr = TRUE
  )

  status <- attr(command_output, "status")

  if (!is.null(status) && status != 0L) {

    stop(
      "Pandoc/citeproc failed for theme '",
      slug,
      "':\n",
      paste(command_output, collapse = "\n"),
      call. = FALSE
    )
  }

  if (!file.exists(output)) {

    stop(
      "Pandoc produced no output for theme '",
      slug,
      "'.",
      call. = FALSE
    )
  }

  html <- paste(
    readLines(
      output,
      warn = FALSE,
      encoding = "UTF-8"
    ),
    collapse = "\n"
  )

  # A single assembled Publications page must not contain eight
  # different elements all called id="refs".
  html <- sub(
    'id="refs"',
    sprintf('id="refs-%s"', slug),
    html,
    fixed = TRUE
  )

  highlight_author(html)
}


write_theme_fragment <- function(slug, definition) {

  rows <- metadata[
    metadata$webtheme == slug,
    ,
    drop = FALSE
  ]

  keys <- rows$citekey

  output_file <- file.path(
    fragment_dir,
    paste0(slug, ".qmd")
  )

  header <- c(
    "<!--",
    "  AUTO-GENERATED FILE.",
    "  Source: bibliography/publications.bib",
    "  Generator: scripts/build-publications.R",
    "  DO NOT EDIT THIS FILE MANUALLY.",
    "-->",
    "",
    sprintf(
      "## %s {#pub-%s}",
      definition$label,
      slug
    ),
    "",
    sprintf(
      "[Research theme →](/research/index.qmd#%s){.publication-theme-link}",
      definition$research_anchor
    ),
    ""
  )

  if (length(keys) == 0L) {

    body <- "_No publications are currently assigned to this theme._"

  } else {

    body <- render_bibliography(
      keys = keys,
      slug = slug
    )
  }

  writeLines(
    c(header, body, ""),
    output_file,
    useBytes = TRUE
  )

  message(
    sprintf(
      "%-16s %3d publications -> %s",
      slug,
      length(keys),
      output_file
    )
  )
}


# -----------------------------------------------------------------------------
# Generate all fragments
# -----------------------------------------------------------------------------

message("")
message("Generating thematic publication fragments")
message("----------------------------------------")

for (slug in names(themes)) {

  write_theme_fragment(
    slug,
    themes[[slug]]
  )
}


# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

message("")
message("Theme summary")
message("-------------")

counts <- table(
  factor(
    metadata$webtheme,
    levels = names(themes)
  )
)

for (slug in names(themes)) {

  message(
    sprintf(
      "%-16s %3d",
      slug,
      counts[[slug]]
    )
  )
}

message("")
message(
  sprintf(
    "Total publications: %d",
    nrow(metadata)
  )
)

message("")
message("Done.")
library(mosaicCalc)
library(LSTbook)
library(ggformula)
library(dplyr)
library(gt)
library(devoirs)
library(ggplot2)
library(ggformula)
# Home brewed
library(QRA) # for core functions and some utilities
library(xref)  # for cross references
library(QAfigs)

theme_set(theme_minimal(base_size=11))


# facilities for cross references in the web-site version

# Read in the index. See xref.R
if (file.exists("XREFS.rda")) {
  load("XREFS.rda")
} else {
  message("No cross-reference file XREFS.rda available.")
}


.bigger_text <- function(P, size=24) {
  P |> gf_theme(theme_minimal(base_size = 24))
  # P |> gf_theme(
  #       axis.text = element_text(size = 2*size/3),
  #       axis.title = element_text(size = size)
  # )
}

add_anchor_file("XREFS.rda")

devoirs::push_answer_style("block")

# Put a QR code for a URL in the margin. Only active for PDF mode.
qr_margin_note <- function(url, description) {
  if (!knitr::is_latex_output()) {
    return("")
  }

  stopifnot(length(url) == 1, is.character(url), nzchar(url))
  stopifnot(length(description) == 1, is.character(description))

  qr_dir <- file.path("www", "qr")
  dir.create(qr_dir, recursive = TRUE, showWarnings = FALSE)
  qr_id <- digest::digest(url, algo = "md5")
  png_path <- file.path(qr_dir, paste0("qr-", qr_id, ".png"))

  if (!file.exists(png_path)) {
    svg_path <- file.path(qr_dir, paste0("qr-", qr_id, ".svg"))
    qrcode::generate_svg(qrcode::qr_code(url), filename = svg_path,
                         size = 600, show = FALSE)
    magick::image_read(svg_path) |>
      magick::image_write(path = png_path, format = "png")
    unlink(svg_path)
  }

  paste0(
    "::: {.column-margin}\n",
    description, "\n\n",
    "![](", png_path, "){width=0.8in}\n",
    ":::"
  )
}


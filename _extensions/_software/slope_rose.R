# Revised version of add_slope_rose()
#
# You can specify the "nice slopes" you want displayed by hand.

slope_rose <- function(P, x=NULL, y=NULL, nice_slopes = NULL, scale=1/4,
                       color="red",
                       keepers=c("both", "pos", "neg")) {
  keepers <- match.arg(keepers)
  xy <- layer_scales(P)
  xrange <- xy$x$range$range
  yrange <- xy$y$range$range
  if (is.null(x)) x <- mean(xrange)
  if (is.null(y)) y <- mean(yrange)
  width <- diff(xrange)*scale
  height <- diff(yrange)*scale
  center <- height / width
  # define this function to avoid dependency on grDevices
  extendrange <- function (x, r = range(x, na.rm = TRUE), f = 0.05)
  {
    if (!missing(r) && length(r) != 2)
      stop("'r' must be a \"range\", hence of length 2")
    f <- if (length(f) == 1L)
      c(-f, f)
    else c(-f[1L], f[2L])
    r + f * diff(r)
  }
  if (is.null(nice_slopes)) {
      nice_slopes <- 
        pretty(extendrange(c(-center, center),f=.75 ), 
               n=10) %>% setdiff(0)
  }
  if (keepers == "pos") nice_slopes <- nice_slopes[nice_slopes > 0]
  if (keepers == "neg") nice_slopes <- nice_slopes[nice_slopes < 0]
  
  nice_x <- rep(width, length(nice_slopes))
  nice_y <- nice_slopes*nice_x
  
  Lines <- tibble(xend=nice_x+x, yend=nice_y + y, x=x, y=y, label=as.character(nice_slopes))
  
  P + geom_segment(data=Lines, aes(x=x, y=y, xend=xend, yend=yend), color=color) + geom_label(data=Lines, aes(x=xend, y=yend, label=label), hjust=0, color=color)
  
  
}

slice_plot(sin(x) ~ x, domain(x = 0:pi)) |>
  slope_rose(keepers = "pos", y = 0, nice_slopes = seq(.2, 1.3, by = .2))

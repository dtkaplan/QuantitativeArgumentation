# Define simple rgl vector/plane drawing functions.
rgl_vec <- function(vecs = rbind(0,1,-1), origins=0, 
                    colors = rainbow(5), alpha = 1) {
  if (origins == 0) origins <- 0 * vecs
  nvecs <- ncol(vecs)
  if (length(colors) != nvecs) colors <- rep_len(colors, nvecs)
  for (k in 1:ncol(vecs)) {
    this_one <- cbind(origins[, k], vecs[, k])
    segments3d(t(this_one), col = colors[k], lwd=2, alpha = alpha)
    points3d(t(this_one[,2]), col = colors[k], size=6, alpha = alpha)
  }
}
rgl_frame <- function(len = 1, color = "red") {
  points <- len * diag(3)
  points <- cbind(points, -points)
  points3d(t(points), col = color)
}

rgl_plane <- function(normal = rbind(0, 0, 1), offset=0, color = "green", alpha = 0.1){
  planes3d(t(normal), alpha = alpha, col = color)
}

cross_product <- function(x, y) {
  rbind(x[2]*y[3] - x[3]*y[2],
        x[3]*y[1] - x[1]*y[3],
        x[1]*y[2] - x[2]*y[1])
}

# Draw the plane spanning two vectors.
rgl_span2 <- function(vecs, color = "green", alpha = 0.1) {
  normalvec <- cross_product(vecs[,1], vecs[,2])
  rgl_plane(normalvec, color = color, alpha = alpha)
}

rgl_vscene <- function(
    vecs = cbind(
      rbind(1,0,.5), 
      rbind(0,.5, -.2)
    ),
    plane = TRUE,
    box = TRUE,
    axes = FALSE,
    color = c("blue", "magenta", "brown"),
    alpha = 1) {
  rgl_frame(color = NA)
  rgl_vec(vecs = vecs, 
          color = color, alpha = alpha)
  
  if (box) box3d(col="black")
  if (axes) axes3d(col = "black", labels = c("x", "y", "z"), lwd = 1, nticks=5)

  if (plane && ncol(vecs) > 1) rgl_span2(vecs[, 1:2])
  view3d(fov=0)
  #close3d()
}

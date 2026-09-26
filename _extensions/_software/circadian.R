circadian <- function(
    human = 25.6,  #parameters
    pulse = 0.9, 
    shift = 0) {

r <- 1
theta <- 3*pi/2 + pi * shift/180
time <- 0L
timestep <- 1L
thetastep <- -(2*pi)/human 
# human cycle length is 25.6 hours
daylength <- 24L # must be multiple of timestep
# theta <- -2*pi/3
# 1.3 pulse settles at 7 o'clock
# 0.75 settles at 6 o'clock
buffer_length <- 5
xhist <- rep(1, buffer_length)
yhist <- rep(0, buffer_length)

circle <- seq(0, 2*pi, length = 100)
plot(0.9*cos(circle),0.9*sin(circle), 
     type = "l",
     axes = FALSE,
     col="blue", ylim=c(-2, 2), 
     xlim = c(-2,2),
     xlab = "", ylab = "", asp = 1)

for (k in 1:10000) {
  time <- time + timestep
  
  if ((time %% daylength) == 0) {
    newx <- x - pulse
    theta <- atan2(y, newx)
    r <- sqrt(y^2 + newx^2)
    lines(c(x, newx), c(y, y), 
          col = rgb(.2,.2,.2))
    points(xhist, yhist,  
           col = rgb(1,1, 1), pch=19)
  } else {
    theta <- theta + thetastep
  }
  
  r <- r + 0.3 * (1 - r) # update radius
  x <- r*cos(theta)
  y <- r*sin(theta)
  
  
  
  points(xhist, yhist,  col = rgb(1,1, 1,.1), pch=19)
  points(xhist[1], yhist[1],  col = rgb(1,1,1), pch=19)
  # update the buffer
  xhist <- c(xhist[-1], x)
  yhist <- c(yhist[-1], y)
  
  points(x, y, pch = 16)
  character <- readline()
  if (character == "e") time <- time + 6
  else if (character == "w") time <- time - 6
  else if (nchar(character) > 0) break
}

}
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION split to three parts
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This function takes spatial object (loaded with terra::vect) and splits
# its extent into three separate extent returned in the list.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

split_into_thirds <- function(x, direction = c("vertical", "horizontal")) {
  direction <- match.arg(direction)
  e <- terra::ext(x)
  
  if (direction == "horizontal") {
    h <- (ymax(e) - ymin(e)) / 3
    ee1 <- ext(xmin(e), xmax(e), ymin(e),        ymin(e) + h)
    ee2 <- ext(xmin(e), xmax(e), ymin(e) + h,    ymin(e) + 2*h)
    ee3 <- ext(xmin(e), xmax(e), ymin(e) + 2*h,  ymax(e))
  } else { # "vertical"
    w <- (xmax(e) - xmin(e)) / 3
    ee1 <- ext(xmin(e),        xmin(e) + w,      ymin(e), ymax(e))
    ee2 <- ext(xmin(e) + w,    xmin(e) + 2*w,    ymin(e), ymax(e))
    ee3 <- ext(xmin(e) + 2*w,  xmax(e),          ymin(e), ymax(e))
  }
  
  list(
    crop(x, ee1),
    crop(x, ee2),
    crop(x, ee3)
  )
}

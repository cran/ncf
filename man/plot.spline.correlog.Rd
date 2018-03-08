\name{plot.spline.correlog}
\alias{plot.spline.correlog}
\title{Plots spline correlograms}
\description{
  `plot' method for class "spline.correlog".  
}

\usage{
    \method{plot}{spline.correlog}(x, xmax = 0, ylim=c(-1,1), \dots)
}
\arguments{
  \item{x}{an object of class "spline.correlog", usually,
  as a result of a call to \code{spline.correlog}.}
  \item{xmax}{The maximal distance to be plotted on the x-axis. 
  If set to zero the maximum distance in the data will be used.}
  \item{ylim}{Limits for the y-axis (default: -1, 1).}
  \item{\dots}{other arguments}
}

\value{
A plot of the spline correlogram function against distance is 
produced. 95\% 
pointwise confidence (or null) envelopes are superimposed (if available).
} 

\seealso{\code{\link{spline.correlog}} 
\code{\link{summary.spline.correlog}} 
}

\keyword{smooth}
\keyword{regression}

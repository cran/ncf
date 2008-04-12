\name{plot.spline.correlog}
\alias{plot.spline.correlog}
\title{Plots spline correlograms}
\description{
  `plot' method for class "spline.correlog".  
}

\usage{
    \method{plot}{spline.correlog}(x, xmax = 0, text = TRUE, \dots)
}
\arguments{
  \item{x}{an object of class "spline.correlograms", usually,
  as a result of a call to \code{spline.correlog}.}
  \item{xmax}{The maximal distance to be plotted on the x-axis. 
  If set to zero the maximum distance in the data will be used.}
  \item{text}{if TRUE the y-label summarizes the y-intercept 
  and the x-label summarizes the x-intercept.}
  \item{\dots}{other arguments}
}

\value{
A plot of the spline correlogram function against distance is 
produced. 95\% 
pointwise confidence (or null) envelopes are superimposed.
} 

\seealso{\code{\link{spline.correlog}} 
\code{\link{summary.spline.correlog}} 
}

\keyword{smooth}
\keyword{regression}

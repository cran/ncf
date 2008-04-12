\name{summary.spline.correlog}
\alias{summary.spline.correlog}
\title{Summarizing spline correlograms}
\description{
  `Summary' method for class "spline.correlog".  
}

\usage{
    \method{summary}{spline.correlog}(object, \dots)
}
\arguments{
  \item{object}{an object of class "spline.correlog", usually,
  as a result of a call to \code{\link{spline.correlog}}.}
  \item{\dots}{other arguments}
}

\details{
}

\value{
A list summarizing spline correlograms is returned.

\item{estimates}{a vector of benchmark statistics:}
\item{$x}{is the lowest value at which the function is = 0. 
  If correlation is initially negative, the distance 
  calculated appears as a negative measure.}
\item{$e}{is the lowest value at which the 
  function is <= 1/e.}
\item{$y}{is the extrapolated value at x=0.} 
  
\item{quantiles}{A matrix summarizing the quantiles in the 
  bootstrap (or null) distributions of the benchmark statistics.}
} 

\seealso{
\code{\link{spline.correlog}} 
\code{\link{plot.spline.correlog}} 
}

\keyword{smooth}
\keyword{regression}

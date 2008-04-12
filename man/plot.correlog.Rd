\name{plot.correlog}
\alias{plot.correlog}
\title{Plots spatial correlograms}
\description{
  `plot' method for class "correlog".  
}

\usage{
    \method{plot}{correlog}(x, \dots)
}
\arguments{
  \item{x}{an object of class "correlog", usually, as a result of
    a call to \code{correlog} or \code{correlog.nc}.}
  \item{\dots}{other arguments}
}

\value{
 A spatial or Mantel (cross-correlogram) is plotted.
 
 If a permutation test was performed, values significant at a nominal
 (two-sided) 5\%-level will be respresented by filled circles and non-significant
 values by open circles.
} 

\seealso{
\code{\link{correlog}} 
\code{\link{correlog.nc}}
}

\keyword{spatial}

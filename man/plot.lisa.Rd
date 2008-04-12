\name{plot.lisa}
\alias{plot.lisa}
\title{Plots local indicators of spatial association}
\description{
  `plot' method for class "lisa".  
}

\usage{
    \method{plot}{lisa}(x, ctr = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "lisa", ususally, as a result of
    a call to \code{\link{lisa}} or \code{\link{lisa.nc}}.}
  \item{ctr}{if TRUE correlations will be centered between
       plotting (reference line is the average synchrony)}
  \item{\dots}{other arguments}
}

\value{
 A bubble-plot of the LISA against spatial coordinates is produced. 
 Negative (or below mean) values are signified by circles. 
 Positive (or above mean) values are signified by squares.
 
 If a permutation test was performed, values significant at a nominal
 (two-sided) 5\%-level will be respresented by filled symbols and non-significant
 values by open symbols.

} 

\seealso{
\code{\link{lisa}}
\code{\link{lisa.nc}}
}

\keyword{spatial}

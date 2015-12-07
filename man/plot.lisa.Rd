\name{plot.lisa}
\alias{plot.lisa}
\title{Plots local indicators of spatial association}
\description{
  `plot' method for class "lisa".  
}

\usage{
    \method{plot}{lisa}(x, negh.mean = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "lisa", ususally, as a result of
    a call to \code{\link{lisa}}.}
  \item{negh.mean}{if TRUE size of symbols represents average observation 
    in each neighborhood, if FALSE size of symbols represents the original 
    observation}
  \item{\dots}{other arguments}
}

\value{
 A bubble-plot of observations against spatial coordinates is produced. 
 Below mean values are signified by squares. 
 Above mean values are signified by squares.
 
 If a permutation test was performed, observations for which the associated LISA 
 statistic is positive and significant at a nominal
 (two-sided) 5\%-level will be respresented by filled symbols and non-significant
 values by open symbols. Thus spatial hot-spots are represented by red filled circles and 
 cold-spots by black filled squares.
} 

\seealso{
\code{\link{lisa}}
\code{\link{lisa.nc}}
}

\keyword{spatial}

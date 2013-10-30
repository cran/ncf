\name{plot.Sncf}
\alias{plot.Sncf}
\title{Plots nonparametric spatial correlation-functions}
\description{
  `plot' method for class "Sncf".  
}

\usage{
    \method{plot}{Sncf}(x, xmax = 0, text = TRUE, add = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "Sncf", usually, as
  a result of a call to \code{Sncf} (or \code{Sncf.srf}).}
  \item{xmax}{The maximal distance to be plotted on the 
  x-axis. If set to zero the maximum distance in the data 
  will be used.}
  \item{text}{if TRUE a summary of the regional average 
  correlation makes the plot title; the y-label summarizes 
  the y-intercept; the x-label summarizes the x-intercept 
  and the cbar-intercept (denoted "r:").}
  \item{add}{if TRUE the plot is added on to 
           the previous graph.}
  \item{\dots}{other arguments}
}

\value{
A plot of the correlation function against distance is produced. 95\% 
pointwise confidence (or null) envelopes are superimposed.
} 

\seealso{
\code{\link{Sncf}}
\code{\link{Sncf.srf}}
\code{\link{summary.Sncf}}
}

\keyword{smooth}
\keyword{regression}

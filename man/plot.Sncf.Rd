\name{plot.Sncf}
\alias{plot.Sncf}
\title{Plots nonparametric spatial correlation-functions}
\description{
  The `plot' method for class "Sncf".  
}

\usage{
    \method{plot}{Sncf}(x, xmax = 0, ylim=c(-1,1), add = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "Sncf", usually, as
  a result of a call to \code{Sncf} (or \code{Sncf.srf}).}
  \item{xmax}{The maximal distance to be plotted on the 
  x-axis. If set to zero the maximum distance in the data 
  will be used.}
  \item{ylim}{Limits for the y-axis (default: -1, 1).}
  \item{add}{if TRUE the plot is added on to 
           the previous graph.}
  \item{\dots}{other arguments}
}

\value{
A plot of the Nonparametric spatial covariance function (with CI's if boostrapps are available)
} 

\seealso{
\code{\link{Sncf}}
\code{\link{plot.Sncf}}
\code{\link{Sncf.srf}}
\code{\link{summary.Sncf}}
}

\keyword{smooth}
\keyword{regression}

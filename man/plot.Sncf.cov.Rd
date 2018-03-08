\name{plot.Sncf.cov}
\alias{plot.Sncf.cov}
\title{Plots nonparametric spatial covariance-functions}
\description{
  'plot' method for class "Sncf.cov".  
}

\usage{
    \method{plot}{Sncf.cov}(x, xmax = 0, \dots)
}
\arguments{
  \item{x}{an object of class "Sncf.cov", usually,
  as a result of a call to \code{Sncf.srf} (with \code{corr} = FALSE).}
  \item{xmax}{The maximal distance to be plotted on the
  x-axis. If set to zero the maximum distance in the data
  will be used.}
  \item{\dots}{other arguments}
}

\seealso{\code{\link{Sncf.srf}} 
\code{\link{plot.Sncf}} 
}

\keyword{smooth}
\keyword{regression}

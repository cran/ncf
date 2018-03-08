\name{plot.Sncf2D}
\alias{plot.Sncf2D}
\title{Plots anisotropic spatial correlation-functions}
\description{
  `plot' method for class "Sncf2D".  
}

\usage{
    \method{plot}{Sncf2D}(x, xmax = 0, ylim=c(-1,1), detail = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "Sncf2D", ususally, as
  a result of a call to \code{Sncf2D}.}
  \item{xmax}{The maximal distance to be plotted on the x-axis. 
  If set to zero the maximum distance in the data will be used.}
  \item{ylim}{Limits for the y-axis (default: -1, 1).}
  \item{detail}{if TRUE a separate plot is made for each direction 
  (including confidence envelopes; see \code{\link{plot.Sncf}} for details. 
  If FALSE all correlation functions are superimposed on the same plot.}
\  \item{\dots}{other arguments}
}

\value{
 A plot or panel-plot results. These represents the xy-plot of distance 
 against spatial (cross-)correlation for each cardinal direction.
} 

\seealso{\code{\link{Sncf2D}} 
\code{\link{plot.Sncf}} 
}

\keyword{smooth}
\keyword{regression}

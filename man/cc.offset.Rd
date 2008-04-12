\name{cc.offset}
\alias{cc.offset}
\title{function to calculate the distance at which the cross-correlation peaks for Sncf objects}
\description{
  Alternative `Summary' method for class "Sncf2D".  
}

\usage{
    cc.offset(obj, xmax)
}
\arguments{
  \item{obj}{an object of class "Sncf2D", usually, as a 
  result of a call to \code{Sncf2D} or \code{spline.correlog.2D}.}
  \item{xmax}{The maximum distance to 
  consider (default is no upper limit).}
}

\value{
An matrix of class "cc.offset" is returned with columns:
  \item{angle}{the cardinal angle (in degrees).}
  \item{distance}{the distances (in the positive direction) to 
     the mode of the (cross-) correlation function (with 95\%
      confidence bounds).}
  \item{correlation}{the correlation at the mode (with CI) for each 
     of the cardinal angles.}
} 

\seealso{
\code{\link{Sncf2D}}
\code{\link{summary.Sncf2D}} 
\code{\link{plot.cc.offset}} 
}

\keyword{smooth}
\keyword{regression}

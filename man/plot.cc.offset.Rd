\name{plot.cc.offset}
\alias{plot.cc.offset}
\title{Plots the cc.offset summary of the anisotropic spatial correlation-functions}
\description{
  `plot' method for class "cc.offset".  
}

\usage{
    \method{plot}{cc.offset}(x, dmax = NULL, inches = NULL, \dots)
}
\arguments{
  \item{x}{an object of class "cc.offset", ususally, as
  a result of applying \code{cc.offset} to an object of class \code{Sncf2D}.}
  \item{dmax}{The maximal distance for radial plot. 
  If NULL the maximum distance in the data will be used.}
  \item{inches}{The size of the symbols, if NULL default is 0.1.}
  \item{\dots}{other arguments}
}

\value{
 A radial 'symbol' plot results. The radius represents the distance to peak 
 correlation (the mode) of the correlation function (in the positive 
 direction). The size of the symbol represents the magnitude of the 
 correlation at the mode for the given cardinal direction.
} 

\seealso{
\code{\link{cc.offset}} 
\code{\link{Sncf2D}} 
\code{\link{plot.Sncf2D}} 
}

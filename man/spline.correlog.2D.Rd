\name{spline.correlog.2D}
\alias{spline.correlog.2D}
\title{Anisotropic nonparametric (cross-)correlation function 
  for univariate spatial data}
\description{spline.correlog.2D is the function to estimate 
  the anisotropic nonparametric correlation function 
  in 8 (or arbitrary) directions (North - Southeast) for 
  univariate data. Correlation functions are 
  calculated for each different bearing. The function 
  assumes univariate observations at each location. 
  (use \code{\link{Sncf2D}} otherwise).  

}

\usage{
spline.correlog.2D(x, y, z, w = NULL, df = NULL, type = "boot", 
resamp = 1000, npoints = 300, save = FALSE, max.it = 25, xmax = FALSE, 
na.rm = FALSE, jitter = FALSE, quiet = FALSE,
angle = c(0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5))
    }

\arguments{
  \item{x}{vector of length n representing the x coordinates.}
  \item{y}{vector of length n representing the y coordinates.}
  \item{z}{vector of length n representing the observation at each location.}
  \item{w}{an optional second vector of length n for variable 2 
    (to estimate spatial or lagged cross-correlation functions).}
  \item{df}{degrees of freedom for the spline. Default is sqrt(n).}
  \item{type}{takes the value "boot" (default) to generate a bootstrap
    distribution or "perm" to generate a null distribution for the estimator}
  \item{resamp}{the number of resamples for the bootstrap or the
    null distribution. }
  \item{npoints}{the number of points at which to save the
           value for the spline function (and confidence
           envelope / null distribution). }
  \item{save}{if TRUE the whole matrix of output from the
           resampling is saved (an resamp x npoints
           dimensional matrix). }
  \item{max.it}{the maximum iteration for the Newton method
           used to estimate the intercepts.}
  \item{xmax}{if FALSE the max observed in the data is used.
       Otherwise all distances greater than xmax is
       omitted.}
  \item{na.rm}{if TRUE, NA's will be dealt with through
           pairwise deletion of missing values for each
           pair of time series -- it will dump if any one
           pair has less than two (temporally) overlapping
           observations.}
  \item{jitter}{if TRUE, jitters the distance matrix, to avoid problems associated
    with fitting the function to data on regular grids}
  \item{quiet}{if TRUE the counter is supressed during execution.}
  \item{angle}{specifies number of cardinal directions and angles for which to
  calculate correlation functions. Default are 8 directions between 0 and 180.}
}

\details{
  see \code{\link{Sncf2D}}
}

\value{
  An object of class "Sncf2D" is returned. 
  See \code{\link{Sncf2D}} for details.
} 

\note{
The function to estimate the UNIvariate anisotropic nonparametric 
(cross-)correlation function in arbitrary directions. In particular 
it was developed to calculate the univariate lagged cross-correlation 
function used in (Humston et al. 2005).
}

\references{
    Humston, R., Mortensen, D. and Bjornstad, O.N. 2005. Anthropogenic
    forcing on the spatial dynamics of an agricultural weed:
    the case of the common sunflower. Journal of Applied Ecology 42: 863-872.
}

\seealso{
\code{\link{Sncf2D}}
}

\examples{
}

\keyword{smooth}
\keyword{regression}

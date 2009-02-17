\name{lisa}
\alias{lisa}
\title{Local inidcator of spatial association}
\description{
  lisa is a function to estimate the local indicators of
  spatial association. The function assumes univariate data at each location.
  For multivariate data use \code{\link{lisa.nc}}
}

\usage{
    lisa(x, y, z, neigh, resamp, latlon, quiet = FALSE)
    }

\arguments{
  \item{x}{vector of length n representing the x coordinates (or latitude; see latlon).}
  \item{y}{vector of length n representing the y coordinates (or longitude).}
  \item{z}{vector of n representing p (>1) observation at each location.}
  \item{neigh}{neighborhood size.}
  \item{resamp}{number of resamples under the NULL to generate p-values}
  \item{latlon}{Not yet implemented: if TRUE, coordinates are latitude and
          longitude.}
  \item{quiet}{if TRUE the counter is supressed during execution.}
}

\details{
  This is the function to estimate the local indicators of spatial
  association modified form Anselin (1995). The statistic is the average
  autocorrelation within a neighborhood.
}

\value{
  An object of class "lisa" is returned, consisting of
  the following components:
  \item{n}{the number of pairs within each neighborhood.}
  \item{dmean}{the actual mean of distance within each neighborhood.}
  \item{correlation}{the mean autocorrelation within the neighborhood (neigh).}
  \item{p}{the permutation two-sided p-value for each distance-class.}
  \item{coord}{a list with the x and y coordinates.}
}

\references{
Anselin, L. 1995. Local indicators of spatial association - LISA. Geographical Analysis 27:93-115.
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{
\code{\link{plot.lisa}} 
}

\examples{
#first generate some sample data
    x <- expand.grid(1:20, 1:5)[,1]
    y <- expand.grid(1:20, 1:5)[,2]

#z data from an exponential random field
    z <- rmvn.spa(x=x, y=y, p=2, method="exp")
    
#lisa analysis
    fit1 <- lisa(x=x, y=y, z=z, neigh=3, resamp=100)
    \dontrun{plot.lisa(fit1)}
}

\keyword{spatial}


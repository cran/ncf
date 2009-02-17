\name{correlog.nc}
\alias{correlog.nc}
\title{Non-cenetered spatial (cross-)correlogram}
\description{
  correlog.nc is the function to estimate the non-centred (cross-)correlogram.
  The noncentred correlogram provides estimates of the spatial correlation 
  for discrete distance classes. The function requires multiple observations 
  at each location (use \code{\link{correlog}} otherwise).
}

\usage{
    correlog.nc(x, y, z, w = NULL, increment, resamp = 1000, na.rm = FALSE, latlon=FALSE, quiet = FALSE)
    }

\arguments{
  \item{x}{vector of length n representing the x coordinates (or longitude; see latlon).}
  \item{y}{vector of length n representing the y coordinates (or latitude).}
  \item{z}{a matrix of dimension n x p 
        representing p (>1) observation at each location.}
  \item{w}{an optional second variable with idenitical dimension to z 
    (to estimate cross-correlograms).}
  \item{increment}{increment for the uniformly distributed
              distance classes.}
  \item{resamp}{the number of permutations under the null to assess level
          of significance.}
  \item{latlon}{if TRUE, coordinates are latitude and
          longitude.}
  \item{na.rm}{if TRUE, NA's will be dealt with through
           pairwise deletion of missing values.}
  \item{quiet}{if TRUE the counter is supressed during execution.}
}

\details{
  The non-centred correlogram estimates spatial dependence at discrete 
  distance classes. The method corresponds to the modified correlogram 
  of Koenig & Knops(1998), but augumented to potentially estimate the 
  cross-correlogram). The function requires multiple observations at 
  each location. Missing values is allowed in the multivariate case 
  (pairwise deletion will be used).  
  
  Missing values are allowed -- values are assumed missing at 
  random.
}

\value{
  An object of class "correlog" is returned, consisting of
  the following components:
  \item{correlation}{the value for the moran (or Mantel) similarity.}
  \item{mean.of.class}{the actual average of the distances within each 
    distance class.}
  \item{nlok}{the number of pairs within each distance class.}
  \item{x.intercept}{the interpolate x.intercept of Epperson (1993).}
  \item{p}{the permutation p-value for each distance-class.}
  \item{corr0}{if a cross-correlogram is calculated, corr0 gives the
    empirical within-patch cross-correlation.}
} 

\references{
Bjornstad, O.N., Ims, R.A. & Lambin, X. (1999) Spatial population 
dynamics: Analysing patterns and processes of population synchrony. 
Trends in Ecology and Evolution, 11, 427-431.

Koenig, W.D. & Knops, J.M.H. (1998) Testing for spatial autocorrelation 
in ecological studies. Ecography, 21, 423-429.
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{
\code{\link{plot.correlog}} 
\code{\link{correlog}}
}

\examples{
#first generate some sample data
    x <- expand.grid(1:20, 1:5)[,1]
    y <- expand.grid(1:20, 1:5)[,2]

#z data from an exponential random field
    z <- cbind(
        rmvn.spa(x=x, y=y, p=2, method="exp"),
        rmvn.spa(x=x, y=y, p=2, method="exp")
        )

#w data from a gaussian random field
    w <- cbind(
        rmvn.spa(x=x, y=y, p=2, method="gaus"),
        rmvn.spa(x=x, y=y, p=2, method="gaus")
        )

#noncentered (Mantel) correlogram 
    fit1 <- correlog.nc(x=x, y=y, z=z, increment=2)
    \dontrun{plot.correlog(fit1)}
}

\keyword{spatial}

\name{correlog}
\alias{correlog}
\title{Uni- and multivariate spatial correlograms}
\description{
  correlog is the function to estimate spatial 
  (cross-)correlograms. Either univariate or 
  multivariate (time seres) for each site can be used.  
}

\usage{
correlog(x, y, z, w = NULL, increment, resamp = 1000, 
latlon = FALSE, na.rm = FALSE, quiet = TRUE)
}

\arguments{
  \item{x}{vector of length n representing the x coordinates (or longitude; see latlon).}
  \item{y}{vector of length n representing the y coordinates (or latitude).}
  \item{z}{vector of length n or matrix of dimension n x p 
        representing p observation at each location.}
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
  The spatial (cross-)correlogram and Mantel (cross-)correlogram 
  estimates the spatial dependence at discrete distance classes.

  The regionwide similarity forms the reference line (the 
  zero-line); the x-intercept is thus the distance at which 
  object are no more similar than that expected 
  by-chance-alone across the region.
  
  If the data are univariate, the spatial dependence is measured
  by Moran's \emph{I}, if it is multivariate it is measured by 
  the \emph{centred} Mantel statistic. (Use \code{\link{correlog.nc}} if
  the non-centered multivariate correlogram is desired).

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
  \item{p}{the permutation two-sided p-value for each distance-class.}
  \item{corr0}{if a cross-correlogram is calculated, corr0 gives the
    empirical cross-correlation at distance zero.}
} 

\references{
Bjornstad, O.N., Ims, R.A. & Lambin, X. (1999) Spatial population
dynamics: Analysing patterns and processes of population synchrony.
Trends in Ecology and Evolution, 11, 427-431.

Bjornstad, O.N. & Falck, W. (2001) Nonparametric spatial covariance 
functions: estimation and testing. Environmental and Ecological Statistics, 8:53-70.

Epperson, B.K. (1993) Recent advances in correlation studies of spatial 
patterns of genetic variation. Evolutionary Biology, 27, 95-155.
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{
\code{\link{plot.correlog}} 
\code{\link{spline.correlog}}
\code{\link{correlog.nc}}
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

#Spatial correlogram 
    fit1 <- correlog(x=x, y=y, z=z[,1], increment=2, resamp=0) 
    \dontrun{plot(fit1)}

#Mantel correlogram 
    fit2 <- correlog(x=x, y=y, z=z, increment=2, resamp=0) 
    \dontrun{plot(fit2)}

#Mantel cross-correlogram 
    fit3 <- correlog(x=x, y=y, z=z, w=w, increment=2, resamp=0) 
    \dontrun{plot(fit3)}
}

\keyword{spatial}

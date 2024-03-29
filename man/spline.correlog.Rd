% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spline-correlog.r
\name{spline.correlog}
\alias{spline.correlog}
\title{Uni- and multivariate spline correlograms}
\usage{
spline.correlog(
  x,
  y,
  z,
  w = NULL,
  df = NULL,
  type = "boot",
  resamp = 1000,
  npoints = 300,
  save = FALSE,
  filter = FALSE,
  fw = 0,
  max.it = 25,
  xmax = FALSE,
  latlon = FALSE,
  na.rm = FALSE,
  quiet = FALSE
)
}
\arguments{
\item{x}{vector of length n representing the x coordinates (or longitude; see latlon).}

\item{y}{vector of length n representing the y coordinates (or latitude).}

\item{z}{vector of length n or matrix of dimension n x p representing p observation at each location.}

\item{w}{an optional second variable with identical dimension to z (to estimate cross-correlograms).}

\item{df}{degrees of freedom for the spline. Default is sqrt(n).}

\item{type}{takes the value "boot" (default) to generate a bootstrap distribution or "perm" to generate a null distribution}

\item{resamp}{the number of resamples for the bootstrap or the null distribution.}

\item{npoints}{the number of points at which to save the value for the spline function (and confidence envelope / null distribution).}

\item{save}{If TRUE, the whole matrix of output from the resampling is saved (a resamp x npoints dimensional matrix).}

\item{filter}{If TRUE, the Fourier filter method of Hall and coworkers is applied to ensure positive semidefiniteness of the estimator.}

\item{fw}{If filter is TRUE, it may be useful to truncate the function at some distance fw sets the truncation distance. When set to zero, no truncation is done.}

\item{max.it}{the maximum iteration for the Newton method used to estimate the intercepts.}

\item{xmax}{If FALSE, the max observed in the data is used. Otherwise all distances greater than xmax is omitted.}

\item{latlon}{If TRUE, coordinates are latitude and longitude.}

\item{na.rm}{If TRUE, NA's will be dealt with through pairwise deletion of missing values.}

\item{quiet}{If TRUE, the counter is suppressed during execution.}
}
\value{
An object of class "spline.correlog" is returned, consisting of the following components: 
\item{real}{the list of estimates from the data.}
\item{$x.intercept}{the lowest value at which the function is = 0. If correlation is initially negative, the distance is given as negative.}
\item{$e.intercept}{the lowest value at which the function 1/e.}
\item{$y.intercept}{the extrapolated value at x=0 (nugget).}
\item{$predicted$x}{the x-axes for the fitted covariance function.}
\item{$predcited$y}{the values for the covariance function.}
\item{boot}{a list with the analogous output from the bootstrap or null distribution.} 
\item{$summary}{gives the full vector of output for the x.intercept, y.intercept, e.intercept, and a quantile summary for the resampling distribution.}
\item{$boot}{If save=TRUE, the full raw matrices from the resampling is saved.}
\item{max.distance}{the maximum spatial distance considered.}
}
\description{
\code{spline.correlog} is the function to estimate the spline (cross-)correlogram from spatial data. Either univariate or multivariate (time seres) for each site can be used.
}
\details{
If observations are univariate the spline (cross-)correlogram represents the generalization of the spatial (cross-)correlogram; if observations are multivariate the spline (cross-)correlogram represents the generalization of the Mantel (cross-)correlogram.

  The spline (cross-)correlogram differs from the spatial correlogram (and Mantel correlogram) in that it estimated spatial dependence as a continuous functions of distance (rather than binning into distance classes). The spline correlogram differs from the nonparametric (cross-)correlation function in that the zero-correlation reference line in the former corresponds to the region-wide correlation reference line in the latter. The x-intercept in the spline correlogram is the distance at which object are no more similar than that expected by-chance-alone across the region. 
  
  Missing values are allowed -- values are assumed missing at random.
}
\examples{
# first generate some sample data
x <- expand.grid(1:20, 1:5)[, 1]
y <- expand.grid(1:20, 1:5)[, 2]

# z data from an exponential random field
z <- cbind(
  rmvn.spa(x = x, y = y, p = 2, method = "exp"), 
  rmvn.spa(x = x, y = y, p = 2, method = "exp")
  )

# w data from a gaussian random field
w <- cbind(
  rmvn.spa(x = x, y = y, p = 2, method = "gaus"), 
  rmvn.spa(x = x, y = y, p = 2, method = "gaus")
  )

# univariate spline correlogram
fit1 <- spline.correlog(x = x, y = y, z = z[, 1], resamp = 100)
\dontrun{plot.spline.correlog(fit1)}
summary(fit1)

# multivariate spline correlogram
fit2 <- spline.correlog(x = x, y = y, z = z, resamp = 100)
\dontrun{plot.spline.correlog(fit2)}
summary(fit2)

# multivariate spline cross-correlogram
fit3 <- spline.correlog(x = x, y = y, z = z, w = w, resamp = 100)
\dontrun{plot.spline.correlog(fit3)}
summary(fit3)
}
\references{
Bjornstad, O.N. & Falck, W. (2001) Nonparametric spatial covariance functions: estimation and testing. Environmental and Ecological Statistics, 8:53-70. <doi:10.1023/A:1009601932481>
}
\seealso{
\code{\link{summary.spline.correlog}}, \code{\link{plot.spline.correlog}}, \code{\link{Sncf}}, \code{\link{spline.correlog2D}}, \code{\link{correlog}}
}
\author{
Ottar N. Bjornstad \email{onb1@psu.edu}
}
\keyword{smooth}
\keyword{spatial}

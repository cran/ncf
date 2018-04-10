\name{Sncf.srf}
\alias{Sncf.srf}
\title{Nonparametric (Cross-)Covariance Function from stationary random fields}
\description{
  Sncf.srf is the function to estimate the nonparametric for spatio-temporal 
  data from fully stationary random fields (i.e. marginal expectation and 
  variance identical for all locations; use \code{\link{Sncf}} otherwise).  
}

\usage{
   Sncf.srf(x, y, z, w = NULL, avg = NULL, avg2 = NULL, corr = TRUE,
    df = NULL, type = "boot", resamp = 0, npoints = 300, save = FALSE,
    filter = FALSE, fw = 0, max.it = 25, xmax = FALSE, jitter = FALSE,
    quiet = FALSE)
}
\arguments{
  \item{x}{vector of length n representing the x coordinates (or longitude; see latlon).}
  \item{y}{vector of length n representing the y coordinates (or latitude).}
  \item{z}{matrix of dimension n x p representing p observation at each location.}
  \item{w}{an optional second matrix of dimension n x p for variable 2 
    (to estimate the spatial cross-correlation function).}
  \item{avg}{supplies the marginal expectation of the Markov
         random field; if TRUE the sample mean (across 
         the markovian field) is used.}
  \item{avg2}{Optionally supplies the marginal expectation of
         the Markov random field for optional variable 2;
         if TRUE the sample mean is used.}
  \item{corr}{if TRUE, the covariance function is standardized 
         by the marginal variance (across the markovian 
         field) to return a correlation function 
         (alternatively the covariance function is 
         returned).}
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
  \item{filter}{if TRUE the Fourier filter method of Hall and
           coworkers is applied to ensure positive
           semidefiniteness of the estimator.
       (more work may be needed on this.)}
  \item{fw}{if filter is TRUE, it may be useful to
           truncate the function at some distance w sets
           the truncation distance. when set to zero no
           truncation is done.}
  \item{max.it}{the maximum iteration for the Newton method
           used to estimate the intercepts.}
  \item{xmax}{if FALSE the max observed in the data is used.
       Otherwise all distances greater than xmax is
       omitted.}
  \item{jitter}{if TRUE, jitters the distance matrix, to avoid problems associated
    with fitting the function to data on regular grids}
    \item{quiet}{if TRUE the counter is supressed during execution.}
}

\details{
  if \code{corr = F}, an object of class "Sncf.cov" is returned. Otherwise the class is "Sncf".

  Sncf.srf is a function to estimate the nonparametric (cross-)covariance 
  function (as discussed in Bjornstad and Bascompte 2001) for data from a fully stationary
  random fields. I have found it useful to estimate the (cross-)covariance functions in synthetic data. 
}

\value{
    an object of class "Sncf" (or "Sncf.cov") is returned see \code{\link{Sncf}} for details.
  } 

\references{
Bjornstad, O. N., and J. Bascompte. (2001) Synchrony and second order 
spatial correlation in host-parasitoid systems. Journal of Animal Ecology 70:924-933. \url{https://doi.org/10.1046/j.0021-8790.2001.00560.x}
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{
\code{\link{Sncf}}
\code{\link{summary.Sncf}} 
\code{\link{plot.Sncf}} 
\code{\link{plot.Sncf.cov}}
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

#multivariate nonparametric covariance function
    fit1 <- Sncf.srf(x=x, y=y, z=z, avg=NULL, corr=TRUE, resamp = 0) 
    \dontrun{plot(fit1)} 
    summary(fit1)

#multivariate nonparametric cross-covariance function (with known
#marginal expectation of zero for both z and w
    fit2 <- Sncf.srf(x=x, y=y, z=z, w=w, avg=0, avg2=0, corr=FALSE, resamp = 0)
    \dontrun{plot(fit2)} 
    summary(fit2)

}

\keyword{smooth}
\keyword{regression}

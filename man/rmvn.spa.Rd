% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilities.R
\name{rmvn.spa}
\alias{rmvn.spa}
\title{Simulate spatially correlated data}
\usage{
rmvn.spa(x, y, p, method = "exp", nugget = 1)
}
\arguments{
\item{x}{vector of length n representing the x coordinates (or latitude; see latlon).}

\item{y}{vector of length n representing the y coordinates (or longitude).}

\item{p}{the range of the spatial models.}

\item{method}{correlation function "exp" (exponential) or "gaus" (gaussian). Exponential is the default.}

\item{nugget}{correlation at the origin (defaults to one)}
}
\value{
A vector of spatially correlated random normal variates with zero mean and unit variance is returned
}
\description{
Function to generate spatially autocorrelated random normal variates using the eigendecomposition method. Spatial covariance can follow either and exponential or Gaussian model.
}
\details{
A target covariance matrix A between the n units is generated by calculating the distances between the locations and thereafter evaluating the covariance function in each pairwise distance. A vector, Z, of spatially correlated normal data with the target covariance is subsequently generated using the eigendecomposition method (Ripley, 1987).
}
\references{
Ripley, B.D. (1987). Stochastic Simulation. Wiley.
}
\seealso{
\code{\link{mSynch}}
}
\author{
Ottar N. Bjornstad \email{onb1@psu.edu}
}
\keyword{regression}
\keyword{smooth}

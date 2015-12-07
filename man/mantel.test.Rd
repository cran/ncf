\name{mantel.test}
\alias{mantel.test}
\title{Mantel Test}
\description{
  A simple function to do a permutation-based Mantel test. The 
  data can either be two distance/similarity matrices or (x, y, z) data.
}

\usage{
mantel.test(M1 = NULL, M2 = NULL, x = NULL, y = NULL, z = NULL,
    resamp = 1000, latlon = FALSE, quiet = FALSE)
}

\arguments{
  \item{M1, M2}{similarity/distance matrix 1, and 
    similarity/distance matrix 2}
  \item{x}{vector of length n representing the x coordinates (or longitude; see latlon).}
  \item{y}{vector of length n representing the y coordinates (or latitude).}
  \item{z}{matrix of dimension n x p representing p observation at each location.}
  \item{resamp}{the number of resamples for the null distribution. }
  \item{latlon}{if TRUE, coordinates are latitude and 
           longitude.}
  \item{quiet}{if TRUE the counter is supressed during execution.}
}

\details{
 Typical usages are
\preformatted{
mantel.test(M1, M2, x = NULL, y = NULL, z = NULL,
resamp = 1000, latlon = FALSE, quiet = FALSE)

mantel.test(x, y, z, M1=NULL, M2=NULL, resamp = 1000,
latlon = FALSE, quiet = FALSE)
}


  Missing values are are treated through pairwise deletion.
}

\value{
  An object of class "Mantel" is returned, consisting of a list with
  two components:
  \item{correlation}{is the value for the Mantel correlation.}
  \item{p}{the randomization-based two-sided p-value.}
}


\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\examples{
#first generate some sample data
    x <- expand.grid(1:20, 1:5)[,1]
    y <- expand.grid(1:20, 1:5)[,2]
#z data from an exponential random field
    z <- cbind(
        rmvn.spa(x=x, y=y, p=2, method="exp"),
        rmvn.spa(x=x, y=y, p=2, method="exp")
        )

#the Mantel test
    mantel.test(x=x, y=y, z=z[,1], resamp=500)
}

\keyword{spatial}

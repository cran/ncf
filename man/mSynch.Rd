\name{mSynch}
\alias{mSynch}
\title{the mean (cross-)correlation (with bootstrapp CI) for a panel of spatiotemporal data}
\description{
  mSynch is the function to estimate the mean (cross-)correlation in a 
  spatiotemporal dataset as discussed in Bjornstad et al. (1999). 
  The function requires multiple observations at each location.  
}

\usage{
    mSynch(x, y = NULL, resamp = 1000, na.rm = FALSE, circ = FALSE, quiet = FALSE)
}
\arguments{
  \item{x}{matrix of dimension n x p representing p 
           observation at each location (i.e. each
           row is a time series).}
  \item{y}{optional matrix of dimension m x p representing
          p observation at each location (i.e. each row
          is a time series). If provided, the mean cross-
          correlation between the two panels is computed.}
  \item{resamp}{the number of resamples for the bootstrap or the 
           null distribution. }
  \item{na.rm}{if TRUE, NA's will be dealt with through 
           pairwise deletion of missing values for each
           pair of time series -- it will dump if any one
           pair has less than two (temporally) overlapping
           observations.}
  \item{circ}{if TRUE, the observations are assumed to be 
           angular (in radians), and circular correlation is used.}
  \item{quiet}{if TRUE the counter is supressed during execution.}
}

\details{
  Missing values are allowed -- values are assumed missing at 
  random.

  The circ argument computes a circular version of the Pearson's product 
  moment correlation (see \code{\link{cor2}}). 
}

\value{
  An object of class "mSynch" is returned, consisting of a list with
  two components:
  \item{real}{the regional average correlation.}
  \item{boot}{A vector of bootstrap resamples.} 
} 

\references{
Bjornstad, O.N., Ims, R.A. & Lambin, X. (1999) Spatial 
population dynamics: Analysing patterns and processes of 
population synchrony. Trends in Ecology and Evolution, 11:427-431.
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{
\code{\link{print.mSynch}} 
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

#mean correlation analysis
    fit1 <- mSynch(x=z, resamp=10)
    print(fit1)
}

\keyword{spatial}

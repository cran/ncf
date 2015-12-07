\name{partial.mantel.test}
\alias{partial.mantel.test}
\title{Partial Mantel test}
\description{
  A simple function to calculate permutation-based partial mantel tests for three matrices,
  the partial mantel test is calculated to test for relationships between M1
  and M2 (M3) cotrolling for M3 (M2). syntax and logic follows Legendre and Legendre (1998) pp 557-558
}

\usage{
partial.mantel.test(M1, M2, M3, resamp = 1000, 
method = "pearson", quiet = FALSE)
}

\arguments{
  \item{M1, M2, M3}{similarity/distance matrices 1, 2 and 3.}
  \item{resamp}{the number of resamples for the 
    null distribution. }
  \item{method}{The method to be used for calculating the correlations.}
  \item{quiet}{if TRUE the counter is supressed during execution.}
}


\details{
  Missing values are are treated through pairwise deletion.
  The method must be one of pearson (default), spearman or kendall
}

\value{
  An object of class "partial.Mantel" is returned, consisting of a list with
  two components:
  \item{MantelR}{the vector of observed Mantel and partial Mantel correlations.}
  \item{p}{is the vector of two-sided p-value under randomization (of M1).}
} 


\references{
  Legendre, P., and L. Legendre. 1998. Numerical Ecology, 2nd edition.
  Elsevier, Amsterdam
}

\author{Ottar N. Bjornstad \email{onb1@psu.edu}}

\seealso{\code{\link{mantel.test}} 
}


\examples{
#first generate some sample data and dissimilarity matrices
    x <- rnorm(10)
    y <- rnorm(10)
    z <- rnorm(10)
    M1 <- sqrt(outer(x, x, "-")^2)
    M2 <- sqrt(outer(y, y, "-")^2)
    M3 <- sqrt(outer(z, z, "-")^2)

    partial.mantel.test(M1=M1, M2=M2, M3=M3, resamp=500)
}

\keyword{spatial}

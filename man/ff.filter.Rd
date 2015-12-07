\name{ff.filter}
\alias{ff.filter}
\title{Fourier filter for c'fns}
\description{
   Fourier filter to ensure positive semi-definite correlation fnctions.  Called by various functions.
}

\usage{
    ff.filter(x)
}
\arguments{
  \item{x}{a vector.}
}

\value{
 A vector is returned whose Fourier-transform has no non-negative coeficients.
} 

\seealso{
\code{\link{Sncf}}
}

\keyword{misc}

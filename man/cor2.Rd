\name{cor2}
\alias{cor2}
\title{Utility function}
\description{
  Called by various functions to calculate 
  Pearson or angular correlation matrixes.
}

\usage{
    cor2(x, y = NULL, circ=FALSE)
}
\arguments{
  \item{x}{a matrix.}
  \item{y}{an optional second matrix.}
  \item{circ}{if TRUE, the observations are assumed to be 
           angular (in radians), and circular correlation 
	   is used. If FALSE, Pearson product moment correlations
	   is returned.}
}

\details{
An auxilliary function to ease the maintenance.
}

\value{
A correlation matrix is returned.
} 

\references{
Jammalamadaka, S. Rao and SenGupta, A. (2001). Topics in Circular 
Statistics, Section 8.2, World Scientific Press, Singapore. 
}

\keyword{misc}

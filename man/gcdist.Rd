\name{gcdist}
\alias{gcdist}
\title{Greater circle distance}
\description{
  Greater circle distance function to calculate spatial distance from lat-long data.  Called by various functions.
}

\usage{
    gcdist(x1, y1, x2, y2)
}
\arguments{
  \item{x1}{longitude 1.}
  \item{x2}{longitude 2.}
  \item{y1}{latitude 1.}
  \item{y2}{latitude 2.}
}

\details{
Function for great circle distance -- due to T. Keitt.
}

\value{
The distance in km is returned
} 

\author{Tim H. Keitt}

\keyword{misc}

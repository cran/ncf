\name{summary.Sncf2D}
\alias{summary.Sncf2D}
\title{Summarizing anisotropic spatial correlation-functions}
\description{
  `Summary' method for class "Sncf2D".  
}

\usage{
    \method{summary}{Sncf2D}(object, \dots)
}
\arguments{
  \item{object}{an object of class "Sncf2D", usually, as
  a result of a call to \code{Sncf2D}.}
  \item{\dots}{other arguments}
}

\value{
A list summarizing the Nonparametric covariance function in 
each cardinal direction results, each with the entires as 
in \code{\link{summary.Sncf}}.
} 

\seealso{
\code{\link{Sncf2D}}
\code{\link{cc.offset}} 
\code{\link{summary.Sncf}} 
}

\keyword{smooth}
\keyword{regression}

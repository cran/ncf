\name{print.mSynch}
\alias{print.mSynch}
\title{Print function for mSynch objects}
\description{
  `Print' method for class "mSynch".  
}

\usage{
    \method{print}{mSynch}(x, verbose = FALSE, \dots)
}
\arguments{
  \item{x}{an object of class "mSynch", usually, as
  a result of a call to mSynch).}
  \item{verbose}{if TRUE a raw listing of the object is produced. 
  if FALSE a summary list is produced}
  \item{\dots}{other arguments}
}


\details{
}

\value{
If verbose is FALSE a list summarizing the regional correlation 
is produced:
\item{mean}{the regional mean correlation.} 
\item{Squantile}{the quantile distribution from the 
  resampling for the regional correlation.}
} 

\seealso{
\code{\link{mSynch}} 
}

\keyword{smooth}
\keyword{regression}

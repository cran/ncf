##############################################################################################
Sncf<-function(x, y, z, w=NULL, df = NULL, type = "boot", resamp = 1000, npoints = 300, save = FALSE,
	filter = FALSE, fw = 0, max.it=25, xmax = FALSE, na.rm = FALSE, latlon = FALSE, circ=FALSE, quiet=FALSE){
##############################################################################################
	NAO <- FALSE

#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
			warning("Missing values exist; Pairwise deletion will be used")
			NAO <- TRUE
			}
		else {
			stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
		}
	}

	if(is.null(w)){
	#This generates correlations
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0
		moran <- cor2(t(z), circ=circ)
	}

	else {
	#This generates cross-correlations
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0
		w <- as.matrix(w)+0
		moran <- cor2(t(z), t(w), circ=circ)
	}

	if(is.null(df)){
		df <- sqrt(n)
	}


	#then generating geographic distances
	if(latlon){
                #these are geographic distances from lat-lon coordinates
                xdist <- gcdist(x,y)
        }

	else{
		#these are geographic distances from euclidian coordinates
		xdist <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}

	maxdist <- ifelse(!xmax, max(na.omit(xdist)), xmax)

#The spline function
	if(is.null(w)){
		triang <- lower.tri(xdist)
	}

	else {
		triang <- is.finite(xdist)
	}

	u <- xdist[triang]
	v <- moran[triang]
	sel <- is.finite(v) & is.finite(u)
	u <- u[sel]
	v <- v[sel]
	v <- v[u <= maxdist]
	u <- u[u <= maxdist]

xpoints=seq(0, maxdist, length=npoints)
out=gather(u=u,v=v,w=w, moran=moran, df=df, xpoints=xpoints, filter=filter, fw=fw)
#End of spline fit
real <- list(cbar = out$cbar, x.intercept = out$xint, e.intercept = out$eint, y.intercept = out$yint, cbar.intercept = out$cint,
		predicted = list(x = matrix(out$x, nrow = 1),
		y = matrix(out$y, nrow = 1)))

###
	boot <- list(NULL)
	boot$boot.summary <- list(NULL)
	if(resamp != 0) {
	#here is the bootstrapping/randomization
		boot$boot.summary$x.intercept <- matrix(NA, nrow = resamp, ncol = 1)
		boot$boot.summary$y.intercept <- matrix(NA, nrow = resamp, ncol = 1)
		boot$boot.summary$e.intercept <- matrix(NA, nrow = resamp, ncol = 1)
		boot$boot.summary$cbar.intercept <- matrix(NA, nrow = resamp, ncol = 1)
		boot$boot.summary$cbar <- matrix(NA, nrow = resamp, ncol = 1)
		predicted <- list(x = matrix(NA, nrow = 1, ncol = npoints), y = matrix(NA, nrow = resamp, ncol = npoints))
		type <- charmatch(type, c("boot", "perm"),
			nomatch = NA)
		if(is.na(type))
			stop("method should be \"boot\", or \"perm\"")
		for(i in 1:resamp) {
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn))	{
		cat(i, " of ", resamp, "\r")
		flush.console()}
		if(type == 1) {
			trekkx <- sample(1:n, replace = TRUE)
			trekky <- trekkx
		}

		if(type == 2) {
			trekky <- sample(1:n, replace = FALSE)
			trekkx <- 1:n
		}

		xdistb <- xdist[trekkx, trekkx]

		if(is.null(w)){
			triang <- lower.tri(xdistb)
		}

		else {
			triang <- is.finite(xdistb)
		}

		xdistb <- xdistb[triang]
		moranb <- moran[trekky, trekky][triang]

		if(type == 1&is.null(w)) {
			moranb <- moranb[!(xdistb == 0)]
			xdistb <- xdistb[!(xdistb == 0)]
		}

		u <- xdistb
		v <- moranb
		sel <- is.finite(v) & is.finite(u)
		u <- u[sel]
		v <- v[sel]
		v <- v[u <= maxdist]
		u <- u[u <= maxdist]

		out=gather(u=u,v=v,w=w, moran=moranb, df=df, xpoints=xpoints, filter=filter, fw=fw)
		
		boot$boot.summary$cbar[i,1] =out$cbar
		boot$boot.summary$y.intercept[i,1] <- out$yint
		boot$boot.summary$x.intercept[i,1] <- out$xint
		boot$boot.summary$e.intercept[i,1] <- out$eint
		boot$boot.summary$cbar.intercept[i,1] <- out$cint
		predicted$x[1,] <- out$x
		predicted$y[i,] <- out$y

	}
#end of bootstrap loop!

	if(save == TRUE) {
		boot$boot <- list(predicted = predicted)
		}
	else {
		boot$boot <- NULL
		}

	ty <- apply(predicted$y, 2, quantile, probs = c(0, 0.025, 0.05, 0.1, 0.25, 0.5,
			0.75, 0.9, 0.95, 0.975, 1), na.rm = TRUE)
		dimnames(ty) <- list(c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 1), NULL)
		tx <- predicted$x
		boot$boot.summary$predicted <- list(x = tx,y = ty)
	}

#The following else is if resamp=0

	else {
		boot <- NULL
		boot.summary <- NULL
	}

	res <- list(real = real, boot = boot, max.distance = maxdist, call=deparse(match.call()))
	class(res) <- "Sncf"
	res
}

gather=function(u,v,w, moran, df, xpoints, filter, fw){
cbar <- mean(v, na.rm= TRUE)
sobj=smooth.spline(u,v, df=df)
x <- xpoints
y <- predict(sobj, x = x)$y
if(filter == TRUE) {
		if(fw > 0){y[x > fw] <- 0}
		y <- ff.filter(y)
	}
#if(is.null(w)){
	yint <- y[1]
#	}
#else {
#	 yint <- mean(diag(moran), na.rm= TRUE)
#	# yint <- ifelse(is.finite(mean(diag(moran), na.rm= TRUE)), mean(diag(moran), na.rm= TRUE),  y[1])
#	}
x2=x[x>=0]
y2=y[x>=0]
konst=ifelse(y2[1]>0,1,-1)
xint=eint=cint=NA
wh=(1:length(x2))[y2<0][1]
int=c(x2[wh],x2[wh-1])
if(length(int)==2 & all(is.finite(int))){
#xi=nleqslv(0, fn=function(x) predict(sobj, x)$y)$x
xi=uniroot(f=function(x) predict(sobj, x)$y, interval=int)$root
xint=c(0,xi*konst, NA)[findInterval(xi, range(xpoints))+1]
}
wh=(1:length(x2))[(y2-1/exp(1))<0][1]
int=c(x2[wh],x2[wh-1])
if(length(int)==2 & all(is.finite(int))){
ei=uniroot(f=function(x) {predict(sobj, x)$y-1/exp(1)}, interval=int)$root
eint=c(0,ei, NA)[findInterval(ei, range(xpoints))+1]
}
wh=(1:length(x2))[(y2-cbar)<0][1]
int=c(x2[wh],x2[wh-1])
if(length(int)==2 & all(is.finite(int))){
ci=uniroot(f=function(x) {predict(sobj, x)$y-cbar}, interval=int)$root
cint=c(0,ci, NA)[findInterval(ci, range(xpoints))+1]
}
list(x=x, y=y, yint=yint, cbar=cbar, xint=xint, eint=eint, cint=cint)
}

##############################################################################################
plot.Sncf=function (x, xmax = 0, ylim=c(-1,1), add = FALSE, ...) 
##############################################################################################
{
    xmax <- ifelse(xmax == 0, x$max.distance, xmax)
    cbar <- x$real$cbar
    if (!add) {
        plot(x$real$predicted$x, x$real$predicted$y, xlim = c(0, 
            xmax), ylim = ylim, type = "l", xlab = "Distance", 
            ylab = "Correlation")
    }
    if (!is.null(x$boot$boot.summary)) {
 polygon(c(x$boot$boot.summary$predicted$x,rev(x$boot$boot.summary$predicted$x)), c(x$boot$boot.summary$predicted$y["0.025",], rev(x$boot$boot.summary$predicted$y["0.975",])), col=gray(0.8), lty=0)
 }
    lines(x$real$predicted$x, x$real$predicted$y)
    lines(c(0, max(x$real$predicted$x)), c(0, 0))
    lines(c(0, max(x$real$predicted$x)), c(cbar, cbar))
}

##############################################################################################
print.Sncf=function(x, ...){
##############################################################################################
cat("This is an object of class Sncf produced by the call:\n\n", x$call, "\n\n Use summary() or plot() for inspection,  (or print.default() to see all the gory details).")}

##############################################################################################
summary.Sncf<-function(object, ...){
##############################################################################################
#this is the generic summary function for Sncf objects
##############################################################################################
	xy <- cbind(object$real$x.intercept, object$real$e.intercept,object$real$y.intercept,object$real$cbar.intercept)
	dimnames(xy) <- list(c("intercepts"), c("x", "e","y", "cbar"))
	if(!is.null(object$boot$boot.summary)){
	yd <- apply(object$boot$boot.summary$y.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	xd <- apply(object$boot$boot.summary$x.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	ed <- apply(object$boot$boot.summary$e.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	synchd <- quantile(object$boot$boot.summary$cbar[,1], probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	cbard <- quantile(object$boot$boot.summary$cbar.intercept[,1], probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	xyd <- cbind(xd, ed, yd, cbard)
	dimnames(xyd) <- list(c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1), c("x", "e", "y", "cbar"))}
	if(is.null(object$boot$boot.summary)){
	synchd <- NULL
	xyd <- NULL	
	}
	res <- list(call = object$call, Regional.synch = object$real$cbar, Squantile = synchd, estimates = xy, quantiles = xyd)
	resquiet=FALSE
}

##############################################################################################
Sncf.srf <- function(x, y, z, w=NULL, avg=NULL, avg2=NULL, corr= TRUE, df = NULL, type = "boot", resamp = 0, 
	npoints = 300, save = FALSE, filter = FALSE, fw = 0, max.it=25, xmax = FALSE, jitter = FALSE, quiet=FALSE){
##############################################################################################
#Sncf.srf is the function to estimate the nonparametric covariance function for a 
#stationary random field (expectation and variance identical). The function uses a
#smoothing spline as an equivalent kernel) as discussed in 
#Bjornstad et al. (1999; Trends in Ecology and Evolution 14:427-431)
############################################################################################

	p <- dim(z)[2]
	n <- dim(z)[1]


	if(is.null(df)){
		df <- sqrt(n)
	}


	if(is.null(avg)){
		avg <- mean(as.vector(z), na.rm= TRUE)

		if(!is.null(w)){
			avg2 <- mean(as.vector(w), na.rm= TRUE)
		}
	}

	sca <- 1
	sca2 <- 1
	if(corr == TRUE){
		sca <- sqrt(var(as.vector(z)))

		if(!is.null(w)){
			sca2 <- sqrt(var(as.vector(w)))
		}

	}

#generates distance matrices
	xdist <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	
	if(jitter == TRUE) {
		#xdist <- jitter(xdist)
		xdist<-apply(xdist,2,jitter)
	}

	if(is.null(w)){
		moran <- crossprod((t(z) - avg)/(sca))/p
	}

	else {
		moran <- crossprod((t(z) - avg)/(sca), (t(w) - avg2)/(sca2))/p
	}

	maxdist <- ifelse(!xmax,max(xdist),xmax)

#Spline fit

#The spline function
	if(is.null(w)){
		triang <- lower.tri(xdist)
	}

	else {
		triang <- is.finite(xdist)
	}

	u <- xdist[triang]
	v <- moran[triang]
	v <- v[u<=maxdist]	
	u <- u[u<=maxdist]

xpoints=seq(0, maxdist, length=npoints)
out=gather(u=u,v=v,w=w, moran=moran, df=df, xpoints=xpoints, filter=filter, fw=fw)
#End of spline fit
real <- list(cbar = out$cbar, x.intercept = out$xint, e.intercept = out$eint, y.intercept = out$yint, cbar.intercept = out$cint,
		predicted = list(x = matrix(out$x, nrow = 1),
		y = matrix(out$y, nrow = 1)))

####
boot <- list(NULL)
boot$boot.summary <- list(NULL)
if(resamp != 0) {
#here is the bootstrapping/randomization
	boot$boot.summary$x.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$y.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$e.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$cbar.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$cbar <- matrix(NA, nrow = resamp, ncol = 1)
	predicted <- list(x = matrix(NA, nrow = 1, ncol = npoints), y = matrix(NA, nrow = resamp, ncol = npoints))
	type <- charmatch(type, c("boot", "perm"), 
		nomatch = NA)
	if(is.na(type))
		stop("method should be \"boot\", or \"perm\"")
	for(i in 1:resamp) {
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn))	{
		cat(i, " of ", resamp, "\r")
		flush.console()}

	if(type == 1) {
		trekkx <- sample(1:n, replace = TRUE)
		trekky <- trekkx
	}

	if(type == 2) {
		trekky <- sample(1:n, replace = FALSE)
		trekkx <- 1:n
	}

	xdistb <- xdist[trekkx, trekkx]

	if(is.null(w)){
		triang <- lower.tri(xdistb)
	}

	else {
		triang <- is.finite(xdistb)
	}

	xdistb <- xdistb[triang]
	moranb <- moran[trekky, trekky][triang]

	if(type == 1&is.null(w)) {
		moranb <- moranb[!(xdistb == 0)]
		xdistb <- xdistb[!(xdistb == 0)]
	}

	u <- xdistb
	v <- moranb
	v <- v[u<=maxdist]	
	u <- u[u<=maxdist]
		out=gather(u=u,v=v,w=w, moran=moranb, df=df, xpoints=xpoints, filter=filter, fw=fw)
		
		boot$boot.summary$cbar[i,1] =out$cbar
		boot$boot.summary$y.intercept[i,1] <- out$yint
		boot$boot.summary$x.intercept[i,1] <- out$xint
		boot$boot.summary$e.intercept[i,1] <- out$eint
		boot$boot.summary$cbar.intercept[i,1] <- out$cint
		predicted$x[1,] <- out$x
		predicted$y[i,] <- out$y

	}
#end of bootstrap loop!

	if(save == TRUE) {
	boot$boot <- list(predicted = predicted)
		}
	else {boot$boot <- NULL}
	ty <- apply(predicted$y, 2, quantile, probs = c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 
			0.75, 0.9, 0.95, 0.975, 1), na.rm = TRUE)
		dimnames(ty) <- list(c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 1), NULL)
		tx <- predicted$x
		boot$boot.summary$predicted <- list(x = tx,y = ty)
	}

#The following else is if resamp=0

	else {
		boot <- NULL
		boot.summary <- NULL
	}
	res <- list(real = real, boot = boot, max.distance = maxdist, call=deparse(match.call()))
if(corr){
	class(res) <- "Sncf"
	}
else {
	class(res) <- "Sncf.cov"
	}

	res
}


##############################################################################################
plot.Sncf=function (x, xmax = 0, ylim=c(-1,1), add = FALSE, ...) 
##############################################################################################
{
    xmax <- ifelse(xmax == 0, x$max.distance, xmax)
    cbar <- x$real$cbar
    if (!add) {
        plot(x$real$predicted$x, x$real$predicted$y, xlim = c(0, 
            xmax), ylim = ylim, type = "l", xlab = "Distance", 
            ylab = "Correlation")
    }
    if (!is.null(x$boot$boot.summary)) {
 polygon(c(x$boot$boot.summary$predicted$x,rev(x$boot$boot.summary$predicted$x)), c(x$boot$boot.summary$predicted$y["0.025",], rev(x$boot$boot.summary$predicted$y["0.975",])), col=gray(0.8), lty=0)
 }
    lines(x$real$predicted$x, x$real$predicted$y)
    lines(c(0, max(x$real$predicted$x)), c(0, 0))
    lines(c(0, max(x$real$predicted$x)), c(cbar, cbar))
}


##############################################################################################
plot.Sncf.cov <- function(x, xmax = 0, ...){
##############################################################################################
	xmax <- ifelse(xmax == 0, max(x$real$predicted$x), xmax)
	plot(x$real$predicted$x, x$real$predicted$y, xlim = c(0, xmax), 
		type = "l", xlab = "Distance", ylab = "Covariance")
    if (!is.null(x$boot$boot.summary)) {
 polygon(c(x$boot$boot.summary$predicted$x,rev(x$boot$boot.summary$predicted$x)), c(x$boot$boot.summary$predicted$y["0.025",], rev(x$boot$boot.summary$predicted$y["0.975",])), col=gray(0.8), lty=0)
 }
	lines(x$real$predicted$x, x$real$predicted$y)
	lines(c(0, max(x$real$predicted$x)), c(0, 0))
}

##############################################################################################
spline.correlog<-function(x, y, z, w=NULL, df = NULL, type = "boot", resamp = 1000, npoints = 300, save = FALSE, 
	 filter = FALSE, fw=0, max.it=25, xmax = FALSE, latlon = FALSE, na.rm = FALSE, quiet=FALSE){
##############################################################################################
#spline.correlog is the function to estimate the spline correlogram discussed in 
#Bjornstad & Falck (2001, Evironmental and Ecological Statistics 8:53-70)
#Bjornstad et al. (1999, Trends in Ecology and Evolution 14:427-431)
#Bjornstad et al. (1999, Ecology 80:622-637)
##############################################################################################

multivar <- !is.null(dim(z))		#test whether z is univariate or multivariate

NAO <- FALSE

#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
			warning("Missing values exist; Pairwise deletion will be used")
			NAO <- TRUE
			}
		else {
			stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
		}
	}


#This generates the distance matrices
#first generating the moran distances
	zx <- NULL
	if(multivar == TRUE) {
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0
		zscal <- (t(apply(z, 2, scale, center= TRUE, scale= TRUE)))/(sqrt((n-1)/n))

		if(is.null(w)){
			moran <- cor2(t(z), circ=FALSE)
			moran <- moran - mean(moran[lower.tri(moran)], na.rm= TRUE)
		}

		else {
			w <- as.matrix(w)+0
			moran <- cor2(t(z), t(w), circ=FALSE)
			moran <- moran - mean(moran, na.rm= TRUE)
		}
	}
	else {
		n <- length(z)
		z <- as.vector(z)+0
		zscal <- (scale(z, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))

		if(is.null(w)){
			moran <- t(outer(zscal, zscal))
		}

		else {
			wscal <- (scale(w, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))
			zw <- c(zscal,wscal)
			moran <- t(outer(zw, zw))[1:n,(n+1):(2*n)]
		}
	}


	if(is.null(df)){
		df <- sqrt(n)
	}


#then generating geographic distances
	if(latlon){
                #these are geographic distances from lat-lon coordinates
                xdist <- gcdist(x,y)
        }

	else{
		#these are geographic distances from euclidian coordinates
		xdist <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}
	maxdist <- ifelse(!xmax, max(na.omit(xdist)), xmax)

#The spline function
	if(is.null(w)){
		triang <- lower.tri(xdist)
	}

	else {
		triang <- is.finite(xdist)
	}

	u <- xdist[triang]
	v <- moran[triang]
	sel <- is.finite(u) & is.finite(v)
	u <- u[sel]
	v <- v[sel]

	v <- v[u<=maxdist]	
	u <- u[u<=maxdist]

xpoints=seq(0, maxdist, length=npoints)
out=gather(u=u,v=v,w=w, moran=moran, df=df, xpoints=xpoints, filter=filter, fw=fw)
real <- list(x.intercept = out$xint, e.intercept = out$eint, y.intercept = out$yint,
		predicted = list(x = matrix(out$x, nrow = 1),
		y = matrix(out$y, nrow = 1)))

#End of spline fit
boot <- list(NULL)
boot$boot.summary <- list(NULL)
if(resamp != 0) {
#here is the bootstrapping/randomization
	boot$boot.summary$x.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$e.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	boot$boot.summary$y.intercept <- matrix(NA, nrow = resamp, ncol = 1)
	predicted <- list(x = matrix(NA, nrow = 1, ncol = npoints), y = matrix(NA, nrow = resamp, ncol = npoints))
	type <- charmatch(type, c("boot", "perm"), 
		nomatch = NA)
	if(is.na(type))
		stop("method should be \"boot\", or \"perm\"")
	for(i in 1:resamp) {
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}

	if(type == 1) {
		trekkx <- sample(1:n, replace = TRUE)
		trekky <- trekkx
	}
	#if(type == 2) {
	#	trekky <- sample(1:n, replace = FALSE)
	#	trekkx <- 1:n
	#}
	xdistb <- xdist[trekkx, trekkx]

	if(is.null(w)){
		triang <- lower.tri(xdist)
	}

	else {
		triang <- is.finite(xdist)
	}

	xdistb <- xdistb[triang]
	moranb <- moran[trekky, trekky][triang]
	if(type == 1&is.null(w)) {
		moranb <- moranb[!(xdistb == 0)]
		xdistb <- xdistb[!(xdistb == 0)]
	}
	u <- xdistb
	v <- moranb
	sel <- is.finite(u) & is.finite(v)
	u <- u[sel]
	v <- v[sel]

	v <- v[u<=maxdist]	
	u <- u[u<=maxdist]
	xpoints=seq(0, maxdist, length=npoints)
	out=gather(u=u,v=v,w=w, moran=moranb, df=df, xpoints=xpoints, filter=filter, fw=fw)

		boot$boot.summary$y.intercept[i,1] <- out$yint
		boot$boot.summary$x.intercept[i,1] <- out$xint
		boot$boot.summary$e.intercept[i,1] <- out$eint
		predicted$x[1,] <- out$x
		predicted$y[i,] <- out$y

	}
#end of bootstrap loop!
	
	if(save == TRUE) {
	boot$boot <- list(predicted = predicted)
		}
	else {boot$boot <- NULL}
	ty <- apply(predicted$y, 2, quantile, probs = c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 
			0.75, 0.9, 0.95, 0.975, 1), na.rm = TRUE)
		dimnames(ty) <- list(c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 1), NULL)
		tx <- predicted$x
		boot$boot.summary$predicted <- list(x = tx,y = ty)
	}

#The following else is if resamp=0
	else {
		boot <- NULL
		boot.summary <- NULL
	}
	res <- list(real = real, boot = boot, max.distance = maxdist, call=deparse(match.call()))
	class(res) <- "spline.correlog"
	res
}


##############################################################################################
plot.spline.correlog<-function(x, xmax = 0, ylim=c(-1,1), ...){
##############################################################################################
#this is the generic plot function for spline.correlog objects
##############################################################################################
	xmax <- ifelse(xmax == 0, x$max.distance, xmax)
	plot(x$real$predicted$x, x$real$predicted$y, xlim = c(0, xmax), ylim
		 = ylim, type = "l", xlab = "Distance", ylab = "Correlation")
	   if (!is.null(x$boot$boot.summary)) {
		 polygon(c(x$boot$boot.summary$predicted$x,rev(x$boot$boot.summary$predicted$x)), c(x$boot$boot.summary$predicted$y["0.025",], rev(x$boot$boot.summary$predicted$y["0.975",])), col=gray(0.8), lty=0)
 }
	lines(x$real$predicted$x, x$real$predicted$y)
	lines(c(0, max(x$real$predicted$x)), c(0, 0))
}

##############################################################################################
summary.spline.correlog<-function(object, ...){
##############################################################################################
#this is the generic summary function for spline.correlog objects
##############################################################################################
  	xy <- cbind(object$real$x.intercept, object$real$e.intercept, object$real$y.intercept)
	dimnames(xy) <- list(c("estimate"), c("x", "e", "y"))
	yd <- apply(object$boot$boot.summary$y.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	xd <- apply(object$boot$boot.summary$x.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	ed <- apply(object$boot$boot.summary$e.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	xyd <- cbind(xd, ed, yd)
	dimnames(xyd) <- list(c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1), c("x", "e", "y"))
	res <- list(call = object$call, estimate = xy, quantiles = xyd)
	res
}

##############################################################################################
print.spline.correlog<-function(x, ...){
##############################################################################################
cat("This is an object of class spline.correlog produced by the call:\n\n", x$call, "\n\n Use summary() or plot() for inspection,  (or print.default() to see all the gory details).")}


##############################################################################################
correlog<-function(x, y, z, w=NULL, increment, resamp = 1000, latlon = FALSE, na.rm = FALSE, quiet=FALSE){
##############################################################################################
#correlog estimates the spatial correlogram (if z is univariate)
#or the Mantel correlogram (if z is multivariate), or the (uni-/multivariate)
#cross-correlogram (if the optional w data set is given).
#######################################################################################

NAO <- FALSE

#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
			warning("Missing values exist; Pairwise deletion will be used")
			NAO <- TRUE
			}
		else {
			stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
		}
	}


	multivar <- !is.null(dim(z))		#test whether z is univariate or multivariate

	if(multivar == TRUE) {
    warning("Response is multivariate: the correlation matrix will be centered on zero. Use correlog.nc() for the non-centered correlogram")
		n <- length(z[, 1])
		p <- length(z[1,  ])
		z <- as.matrix(z)+0

		if(is.null(w)){
			moran <- cor2(t(z), circ=FALSE)
			moran <- moran[lower.tri(moran)]
			moran <- moran - mean(moran, na.rm= TRUE)
		}

		else {
			w <- as.matrix(w)+0
			moran <- cor2(t(z), t(w), circ=FALSE)
			zero <- mean(diag(moran), na.rm= TRUE)
			moran <- moran[row(moran)!=col(moran)]
			moran <- moran - mean(moran, na.rm= TRUE)
		}
	}

	else {
		n <- length(z)
		z <- as.vector(z)+0
		zscal <- (scale(z, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))

		if(is.null(w)){
			moran <- t(outer(zscal, zscal))
			moran <- moran[lower.tri(moran)]
		}

		else {
			wscal <- (scale(w, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))
			zw <- c(zscal,wscal)
			#this may be a slight hack
			moran <- t(outer(zw, zw))[1:n,(n+1):(2*n)]
			zero <- mean(diag(moran), na.rm= TRUE)
			moran <- moran[row(moran)!=col(moran)]
		}
	}


	#then generating geographic distances
	if(latlon){
                #these are geographic distances from lat-lon coordinates
                dmat <- gcdist(x,y)
        }

	else{
		#these are geographic distances from euclidian coordinates
		dmat <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}

	if(resamp != 0){
		dmat2 <- dmat
		moran2 <- moran
	}

	if(is.null(w)){
		dmat <- dmat[lower.tri(dmat)]
	}
	else {
		dmat <- dmat[row(dmat)!=col(dmat)]
	}

        dkl <- ceiling(dmat/increment) 	#generates the distance matrices
        nlok <- sapply(split(moran, dkl), length)
        dmean <- sapply(split(dmat, dkl), mean, na.rm = TRUE)
        moran <- sapply(split(moran, dkl), mean, na.rm = TRUE)
	ly <- 1:length(dmean)
	x <- c(dmean[ly[moran < 0][1]], dmean[ly[moran < 0][1] - 1])
	y <- c(moran[ly[moran < 0][1] - 1], moran[ly[moran < 0][1]])
	if(moran[1] < 0) {
		tmp <- 0
	}
	else {
		tmp <- lm(x ~ y)[[1]][1]
	}

  p<-NULL

	if(resamp != 0){

		perm <- matrix(NA, ncol = length(moran), nrow = resamp)

		for(i in 1:resamp){
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}


			trekk <-sample(1:n)
			dma <- dmat2[trekk,trekk]
			mor <- moran2

			if(is.null(w)){
				dma <- dma[lower.tri(dma)]
			}
			else {
				dma <- dma[row(dma)!=col(dma)]
			}

			dkl <- ceiling(dma/increment)	#generates the distance matrices
			perm[i,] <- sapply(split(mor, dkl), mean, na.rm = TRUE)
		}

  p=(apply(moran<=t(perm),1,sum))/(resamp+1)
  p=apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)
	}

	res <- list(n = nlok, mean.of.class = dmean, correlation = moran,
  x.intercept = tmp, p=p, call=deparse(match.call()))

	if(!is.null(w)){
		res$corr0 <- zero
	}
	class(res) <- "correlog"
	res
}

#########################################################################################
plot.correlog<-function(x, ...){
##############################################################################################
#this is the generic plot function for correlog objects
#sigificant values are represented by filled cirles
##############################################################################################
	plot(x$mean.of.class, x$correlation, ylab='correlation', xlab='distance (mean-of-class)')
	lines(x$mean.of.class, x$correlation)
	if(!is.null(x$p)){
       points(x$mean.of.class[x$p<0.025], x$correlation[x$p<0.025], pch=21, bg="black")
       }
	title("Correlogram")
}
##############################################################################################
correlog.nc<-function(x, y, z, w=NULL, increment, resamp = 1000, na.rm = FALSE, latlon=FALSE, quiet=FALSE){
##############################################################################################
#correlog.nc estimates the noncentred correlogram
#and cross-correlogram. Bjornstad et al. (1999; Trends in Ecology and
#Evolution 14:427-431)
#The function requires mulitple observations at each location (use
#correlog otherwise).
#######################################################################################

	NAO <- FALSE

	#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
			warning("Missing values exist; Pairwise deletion will be used")
		NAO <- TRUE
		}
	else {
		stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
		}
	}

#then generating geographic distances
	if(latlon){
                #these are geographic distances from lat-lon coordinates
                dmat <- gcdist(x,y)
        }

	else{
		#these are geographic distances from euclidian coordinates
		dmat <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}

if(is.null(w)){
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0

		moran <- cor2(t(z), circ=FALSE)
	}

	else {
		#This generates the moran distances for cross-correlation
		#the odd adding of zero is just to ensure that all vectors
		#are treated as numeric
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0
		w <- as.matrix(w)+0

		moran <- cor2(t(z), t(w), circ=FALSE)
	}

 	if(resamp != 0){
		dmat2 <- dmat
		#moran2 <- moran
	}

	if(is.null(w)){
		dmat <- dmat[lower.tri(dmat)]
		moran <- moran[lower.tri(moran)]
	}
	else {
		dmat <- dmat[row(dmat)!=col(dmat)]
		zero <- mean(diag(moran), na.rm= TRUE)
		moran <- moran[row(moran)!=col(moran)]
	}

 	if(resamp != 0){
		#dmat2 <- dmat
		moran2 <- moran
	}

   	dkl <- ceiling(dmat/increment) 	#generates the distance matrices
  	nlok <- sapply(split(moran, dkl), length)
    dmean <- sapply(split(dmat, dkl), mean, na.rm = TRUE)
    moran <- sapply(split(moran, dkl), mean, na.rm = TRUE)
    ly <- 1:length(dmean)
    x <- c(dmean[ly[moran < 0][1]], dmean[ly[moran < 0][1] - 1])
    y <- c(moran[ly[moran < 0][1] - 1], moran[ly[moran < 0][1]])

  if(moran[1] < 0) {
		tmp <- 0
	}
	else {
		if(sum(moran<0)>0){
			tmp <- lm(x ~ y)[[1]][1]
		}
		else{
			tmp <- NA
		}
	}

  p<-NULL

	if(resamp != 0){
		perm <- matrix(NA, ncol = length(moran), nrow = resamp)

		for(i in 1:resamp){
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}



			trekk <-sample(1:n)
			dma <- dmat2[trekk,trekk]
			mor <- moran2

			if(is.null(w)){
				dma <- dma[lower.tri(dma)]
			}
			else {
				dma <- dma[row(dma)!=col(dma)]
			}

			dkl <- ceiling(dma/increment)	#generates the distance matrices
			perm[i,] <- sapply(split(mor, dkl), mean, na.rm = TRUE)
		}

  p=(apply(moran<=t(perm),1,sum))/(resamp+1)
  p=apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)
	}

	res <- list(n = nlok, mean.of.class = dmean, correlation = moran,
		x.intercept = tmp, p = p, call=deparse(match.call()))
	if(!is.null(w)){
		res$corr0 <- zero
	}
	class(res) <- "correlog"
	res
}

##############################################################################################
mSynch<-function(x, y=NULL, resamp = 1000, na.rm = FALSE, circ=FALSE, quiet=FALSE){
##############################################################################################
#mSynch is a function to estimate the mean (cross-)correlation with bootstrapp CI for one
#or two panels of spatiotemporal data
############################################################################################

NAO <- FALSE

#check for missing values
if(any(!is.finite(x))) {
	if(na.rm){
		warning("Missing values exist; Pairwise deletion will be used")
		NAO <- TRUE
	}
	else {
	stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
	}
}

#the following sets up the output:
	Sbar <- list(real = NA)

#first generates the correlations
#the odd adding of zero is just to ensure that all vectors 
#are treated as numeric
	n <- dim(x)[1]
	p <- dim(x)[2]
	x <- as.matrix(x)+0

	if(!is.null(y)){
		m <- dim(y)[1]
		y <- as.matrix(y)+0
	}

	if(!is.null(y)){
		synch <- cor2(t(x), t(y), circ=circ)
	}
	else{
		synch <- cor2(t(x), circ=circ)
	}

	if(is.null(y)){
		triang <- lower.tri(synch)
		v <- synch[triang]
	}
	else{
		v <- synch
	}

	Sbar$real <- mean(v, na.rm= TRUE)

#End of real fit

Sbar$boot <- NULL

if(resamp != 0) {
	Sbar$boot<-matrix(NA, nrow = resamp, ncol = 1)
	for(i in 1:resamp) {
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}

	#here is the bootstrapping/randomization
	trekkx <- sample(1:n, replace = TRUE)
	
	if(!is.null(y)){
		trekky <- sample(1:m, replace = TRUE)
		synchb <- synch[trekkx,trekky]
	}
	
	else{
		trekky <- trekkx
		synchb <- synch[trekkx,trekkx][diag(n)[trekkx,trekkx]!=1]
	}

	Sbar$boot[i,1] <- mean(synchb, na.rm= TRUE)
}
#end of bootstrap loop!
}
	res <- Sbar
	class(res) <- "mSynch"
	res
}

##############################################################################################
"print.mSynch" <- function(x, verbose = FALSE, ...){
##############################################################################################
#this is the generic print function for mSynch objects
#
#ARGUMENTS
#verbose   If TRUE, the raw list is echoed
##############################################################################################
  if(!verbose) {
	Sbard <- quantile(x$boot, probs = c(0, 0.025, 0.25, 0.5,
		0.75, 0.975, 1), na.rm= TRUE)
	out <- list(mean=x$real, Squantile = Sbard)
	print(out)
	cat("\n\nFor a raw listing use print(x, verbose= TRUE)\n")
	}
	if(verbose) {
		print.default(x)
	}
}


##############################################################################################
mantel.test<-function(M1=NULL, M2=NULL, x=NULL, y=NULL, z=NULL, resamp = 1000, latlon = FALSE, quiet=FALSE){
##############################################################################################
#mantel.test is a function to calculate the mantel test for two matrices,
#or for {x, y, z} data.
#######################################################################################
	if(is.null(M1)&is.null(x)){
			stop("you must provide either distance/similarity\nmatrices OR vectors of x-/y-coordinates and observations")
			}
if(!is.null(x)){
	multivar <- !is.null(dim(z))		#test whether z is univariate or multivariate

	if(multivar == TRUE) {
		n <- length(z[, 1])
		p <- length(z[1,  ])
		z <- as.matrix(z)+0

		M2 <- cor2(t(z), circ=FALSE)
	}

	else {
		n <- length(z)
		z <- as.vector(z)+0
		zscal <- (scale(z, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))

		M2 <- t(outer(zscal, zscal))

	}

	#then generating geographic distances
	if(latlon){
                #these are geographic distances from lat-lon coordinates
               M1 <- gcdist(x,y)
        }

	else{
		#these are geographic distances from euclidian coordinates
		M1 <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}
}

else{	#if x is null
	n<-dim(M1)[1]
}

	if(resamp != 0){
		M12 <- M1
	}

	M1<-M1[row(M1)!=col(M1)]
	M2<-M2[row(M2)!=col(M2)]


	MantelR <- cor2(M1, M2, circ=FALSE)

	if(resamp != 0){
		perm <- rep(NA, resamp)		

		for(i in 1:resamp){
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}

			trekk <-sample(1:n)
			d <- M12[trekk,trekk]
			m <- M2

			d <- d[row(d)!=col(d)]

			perm[i]<-cor2(d, M2, circ=FALSE)
		}
    p=(sum(MantelR>=perm))/(resamp+1)
    p=min(c(p, 1-p)) + 1/(resamp+1)
 	}

	else{		#if resamp == 0
		p <- NA
	}

	res <- list(correlation = MantelR, p=p, call=deparse(match.call()))

	class(res) <- "Mantel"
	res
}

##############################################################################################
partial.mantel.test<-function(M1, M2, M3, resamp = 1000, method='pearson', quiet=FALSE){
##############################################################################################
#partial.mantel.tets is a simple function to calculate Mantel and partial mantel tests for three matrices,
#the partial mantel test is calculated to test for relationships between M1 and M2 (or M3) cotrolling for M3 (M2).
#syntax and logic follows Legendre & Legendre (1998) pp 557-558
#######################################################################################
#check for missing values
if(any(!is.finite(M1))||any(!is.finite(M2))||any(!is.finite(M3))) {
	warning("Missing values exist; Pairwise deletion will be used")
}

if(any(outer(c(dim(M1),dim(M2),dim(M3)), c(dim(M1),dim(M2),dim(M3)), "-")!=0)){
	stop("All matrices must be square and of the same size")
}


n<-dim(M1)[1]

r12<-cor(M1[upper.tri(M1)], M2[upper.tri(M2)], use="pairwise.complete.obs", method=method)
r13<-cor(M1[upper.tri(M1)], M3[upper.tri(M3)], use="pairwise.complete.obs", method=method)
r23<-cor(M2[upper.tri(M2)], M3[upper.tri(M3)], use="pairwise.complete.obs", method=method)

r12.3<-(r12-r13*r23)/(sqrt(1-r13^2)*sqrt(1-r23^2))
r13.2<-(r13-r12*r23)/(sqrt(1-r12^2)*sqrt(1-r23^2))

perm<-matrix(NA, ncol=5, nrow=resamp)



for(i in 1:resamp){
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}


	trekk <-sample(1:n)
	M1r <- M1[trekk,trekk]
	r12r<-cor(M1r[upper.tri(M1)], M2[upper.tri(M2)], use="pairwise.complete.obs", method=method)
	r13r<-cor(M1r[upper.tri(M1)], M3[upper.tri(M3)], use="pairwise.complete.obs", method=method)

	perm[i,1]<-r12r
	perm[i,2]<-r13r

	perm[i,4]<-(r12r-r13r*r23)/(sqrt(1-r13r^2)*sqrt(1-r23^2))
	perm[i,5]<-(r13r-r12r*r23)/(sqrt(1-r12r^2)*sqrt(1-r23^2))
	
	M2r <- M2[trekk,trekk]
	r23r<-cor(M2r[upper.tri(M2)], M3[upper.tri(M3)], use="pairwise.complete.obs", method=method)
	perm[i,3]<-r23r
		
}

res<-c(r12, r13, r23, r12.3, r13.2)
names(res)<-c("r12", "r13", "r23", "r12.3", "r13.2")

p<-(apply(t(res>=t(perm)),2,sum))/(resamp+1)
p<-apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)


out<-list(MantelR=res, p=p, call=deparse(match.call()))
class(out)<-"partial.Mantel"

return(out)
}

##############################################################################################
lisa<-function(x, y, z, neigh, resamp=1000, latlon = FALSE, quiet=FALSE){
##############################################################################################
#lisa is a function to estimate the local indicators
#of spatial association.
#######################################################################################

  if(!is.null(dim(z))){
    stop("\n z is multivariate. Use lisa.nc()")
  }

	n <- length(z)

#then generating geographic distances

	if(latlon){
                #these are geographic distances from lat-lon coordinates
                dmat <- gcdist(x,y)
        }

	else{
		dmat <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}

	zscal <- (scale(z, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))

	zx <- t(outer(zscal, zscal))

	dkl <- ifelse(dmat>0&dmat<neigh,1,NA)	#flaggs obs within the neigh
  
#calculate mean value of z within neigh
  negz=dkl*z
  diag(negz)=z
  zmean=apply(negz,2,mean, na.rm=TRUE)

	nlok <- apply(dkl, 2, sum, na.rm= TRUE)
	dmean <- apply(dmat*dkl, 2, mean, na.rm= TRUE)
	moran <- apply(zx*dkl, 2, mean, na.rm= TRUE)

  p<-NULL

  if(resamp>0){
     perm<-matrix(NA, nrow=resamp, ncol=n)
 
    for(i in 1:resamp){
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}


    trekk<-sample(1:n)
    zx2<-zx[trekk, trekk]
	  perm[i,]<-apply(zx2*dkl, 2, mean, na.rm= TRUE)
    }
    p<-(apply(moran<t(perm),1,sum))/(resamp+1)
    p<-apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)


  }
	res <- list(correlation = moran, p=p, mean=zmean, dmean = dmean, n = nlok, z=z,coord=list(x=x, y=y), call=deparse(match.call()))

	class(res) <- "lisa"
	res
}


##############################################################################################
plot.lisa<-function(x, neigh.mean=FALSE, add=FALSE, inches=0.2, ...){
##############################################################################################
if(neigh.mean){
z <- x$mean
}
else{
  z<-x$z
}

x <- x$coord$x
y <- x$coord$y

if(add==FALSE){
	plot(x,y,type="n")
}
sel <- is.finite(z)
x <- split(x,z-mean(z, na.rm=TRUE)>0)
y <- split(y,z-mean(z, na.rm=TRUE)>0)
sel <- split(sel, z-mean(z, na.rm=TRUE)>0)
z2 <- split(z-mean(z, na.rm=TRUE),z-mean(z, na.rm=TRUE)>0)

bgc<-rep(0, length(z))
bgc <- split(bgc,z-mean(z, na.rm=TRUE)>0)

   if(!is.null(x$p)){
     bgc<-rep(0, length(z))
     bgc<-ifelse(x$p<0.025, 1, 0)
     bgc[x$p<0.025 & z-mean(z, na.rm=TRUE)>0]<-2
     bgc <- split(bgc,z-mean(z, na.rm=TRUE)>0)
   }


if(!is.null(length(z2[[1]][sel[[1]]]))){
  symbols(x[[1]][sel[[1]]],y[[1]][sel[[1]]],squares=-z2[[1]][sel[[1]]], inches=inches, add= TRUE, fg=1, bg=bgc[[1]][sel[[1]]])}

if(!is.null(length(z2[[1]][sel[[2]]]))){
  symbols(x[[2]][sel[[2]]],y[[2]][sel[[2]]],circles=z2[[2]][sel[[2]]], inches=inches, add= TRUE, fg=2, bg=bgc[[2]][sel[[2]]])}
}


##############################################################################################
lisa.nc<-function(x, y, z, neigh, na.rm = FALSE, resamp=1000, latlon = FALSE, quiet=FALSE){
##############################################################################################

  if(is.null(dim(z))){
    stop("\n z is univariate. Use lisa()")
  }

	NAO <- FALSE
	#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
		warning("Missing values exist; Pairwise deletion will be used")
		NAO <- TRUE
		}
		else {
		stop("Missing values exist; use na.rm = TRUE for pairwise deletion")
		}
	}
	n <- dim(z)[1]
	p <- dim(z)[2]

	#then generating geographic distances

	if(latlon){
                #these are geographic distances from lat-lon coordinates
                dmat <- gcdist(x,y)
        }

	else{
		dmat <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	}

	z <- as.matrix(z)+0

	zx <- cor2(t(z), circ=FALSE)

	dkl <- ifelse(dmat>0&dmat<neigh,1,NA)	#flaggs obs within the neigh
	nlok <- apply(dkl, 2, sum, na.rm= TRUE)
	dmean <- apply(dmat*dkl, 2, mean, na.rm= TRUE)
	moran <- apply(zx*dkl, 2, mean, na.rm= TRUE)

  p<-NULL

  if(resamp>0){
     perm<-matrix(NA, nrow=resamp, ncol=n)

    for(i in 1:resamp){
 		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}


    trekk<-sample(1:n)
    zx2<-zx[trekk, trekk]
	  perm[i,]<-apply(zx2*dkl, 2, mean, na.rm= TRUE)
    }
    p<-(apply(moran<t(perm),1,sum))/(resamp+1)
    p<-apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)
  }



	res <- list(correlation = moran, p=p, n = nlok, dmean = dmean, coord=list(x=x, y=y), call=deparse(match.call()))
	class(res) <- "lisa.nc"
	res
}

##############################################################################################
plot.lisa.nc<-function(x, ctr = FALSE, add=FALSE, inches=0.2, ...){
##############################################################################################
if(ctr){
	z <- x$correlation-mean(x$correlation, na.rm= TRUE)}
else{z <- x$correlation}

x <- x$coord$x
y <- x$coord$y

if(add==FALSE){
	plot(x,y,type="n")
	}
sel <- is.finite(z)
x <- split(x,z>0)
y <- split(y,z>0)
sel <- split(sel, z>0)
z2 <- split(z,z>0)

bgc<-rep(0, length(z))
bgc <- split(bgc,z>0)

   if(!is.null(x$p)){
     bgc<-rep(0, length(z))
     bgc<-ifelse(x$p<0.025, 1, 0)
     bgc[x$p<0.025 & z >0]<-2
     bgc <- split(bgc,z>0)
   }


if(!is.null(length(z2[[1]][sel[[1]]]))){
  symbols(x[[1]][sel[[1]]],y[[1]][sel[[1]]],squares=-z2[[1]][sel[[1]]], inches=inches, add= TRUE, fg=1, bg=bgc[[1]][sel[[1]]])}

if(!is.null(length(z2[[1]][sel[[2]]]))){
  symbols(x[[2]][sel[[2]]],y[[2]][sel[[2]]],circles=z2[[2]][sel[[2]]], inches=inches, add= TRUE, fg=2, bg=bgc[[2]][sel[[2]]])}
}


##############################################################################################
spatial.plot<-function(x, y, z, ctr=TRUE, add=FALSE, inches=0.2, ...){
##############################################################################################
if(ctr){
  z <- z-mean(z, na.rm= TRUE)}

if(add==FALSE){
	plot(x,y,type="n")
}
sel <- is.finite(z)
x <- split(x,z>0)
y <- split(y,z>0)
sel <- split(sel, z>0)
z2 <- split(z,z>0)


if(!is.null(length(z2[[1]][sel[[1]]]))){
  symbols(x[[1]][sel[[1]]],y[[1]][sel[[1]]],squares=-z2[[1]][sel[[1]]], inches=inches, add= TRUE, fg=1, bg=1)}

if(!is.null(length(z2[[1]][sel[[2]]]))){
  symbols(x[[2]][sel[[2]]],y[[2]][sel[[2]]],circles=z2[[2]][sel[[2]]], inches=inches, add= TRUE, fg=2, bg=2)}
}

##############################################################################################
rmvn.spa <- function(x, y, p, method = "exp", nugget = 1){
##############################################################################################
#Function to generate spatially autocorrelated random normal variates using the 
#eigendecomposition method. Spatial covariance can follow either and exponential 
#or Gaussian model. 
##############################################################################################

imeth <- charmatch(method, c("exp", "gaus"), nomatch = NA)
if(is.na(imeth)) stop("method should be \"exp\", or \"gaus\"")

	ch.fn<-function(n, mu, vmat, tol = 1e-007){
		p <- ncol(vmat)
		vs <- svd(vmat)
		vsqrt <- t(vs$v %*% (t(vs$u) * sqrt(vs$d)))
		ans <- matrix(rnorm(n * p), nrow = n) %*% vsqrt
		ans <- sweep(ans, 2, mu, "+")
		dimnames(ans) <- list(NULL, dimnames(vmat)[[2]])
		ans
		}

n <- length(x)
z <- matrix(0, ncol = 1, nrow = n)
tmpmat <- cbind(x + 0, y + 0)
xy <- tmpmat[, 1:2] + 0
dmat <- sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)
	if(imeth == 1) {
		covmat <- nugget * exp( - dmat/p)
	}
	else {
	if(imeth == 2) {
		covmat <- nugget * exp( - (dmat/p)^2)
	}
	}
	z <- ch.fn(1, mu = rep(0, n), vmat = covmat)
	t(z)[, 1]
}

##############################################################################################
gcdist=function(x,y){
#vecotorized gcdist function
##############################################################################################
    r <- 360/(2 * pi)
    lon <- x/r
    lat <- y/r
    dlon <- outer(lon, lon, "-")
    dlat <- outer(lat,lat,"-")
    a <- (sin(dlat/2))^2 + outer(cos(lat), cos(lat), "*") * (sin(dlon/2))^2
    c <- 2 * atan2(sqrt(a), sqrt(1 - a))
    return(6370 * c)
}


##############################################################################################
Sncf2D <- function(x, y, z, w=NULL, df = NULL, type = "boot", resamp = 1000, npoints = 300,
  save = FALSE, max.it=25, xmax= FALSE, na.rm = FALSE, jitter= FALSE, quiet=FALSE,
  angle=c(0,22.5,45,67.5,90,112.5,135,157.5)){
##############################################################################################
#Sncf2D is the function to estimate the anisotropic nonparametric covariance function 
#(using a smoothing spline as an equivalent kernel) in 8 (or arbitrary) directions (North - Southeast) 
#through calculateing projected distances onto the different bearings (i.e. all data are used for each 
#direction = 0,22.5,45,67.5,90,112.5,135,157.5)
############################################################################################

#the following sets up the output:

real<-lapply(unlist(lapply(angle, as.name)),as.null)
names(real)<-unlist(lapply(angle, as.name))

for(i in 1:length(angle)){
	real[[i]]<-list(x.intercept = NA, e.intercept = NA, y.intercept = NA, 
	cbar.intercept = NA, predicted = list(x = matrix(NA, nrow = 1, 
	ncol = npoints), y = matrix(NA, nrow = 1, ncol = npoints)))
}

real$cbar<-NA

if(resamp==0){
	boot<-lapply(unlist(lapply(angle, as.name)),as.null)
	names(boot)<-unlist(lapply(angle, as.name))
}

else{
	boot<-lapply(unlist(lapply(angle, as.name)),as.null)
	names(boot)<-unlist(lapply(angle, as.name))

	for(i in 1:length(angle)){
		boot[[i]]<-list(boot.summary=list(
		cbar = matrix(NA, ncol=1, nrow=resamp),
		x.intercept = matrix(NA, ncol=1, nrow=resamp),
	        e.intercept = matrix(NA, ncol=1, nrow=resamp),
		y.intercept = matrix(NA, ncol=1, nrow=resamp),
		cbar.intercept = matrix(NA, ncol=1, nrow=resamp)),
		predicted= list(x = matrix(NA, nrow = 1, ncol = npoints),
		 y = matrix(NA, nrow = resamp, ncol = npoints)))
		}
	}

	type <- charmatch(type, c("boot", "perm"), 
		nomatch = NA)
	if(is.na(type))
		stop("method should be \"boot\", or \"perm\"")

	NAO <- FALSE

	#check for missing values
	if(any(!is.finite(unlist(z)))) {
		if(na.rm){
			warning("Missing values exist; Pairwise deletion will be used")
			NAO <- TRUE
		}
		else {
			stop("Missing values exist; use na.rm = TRUE for pariwise deletion")
		}
	}

	if(is.null(w)){
	#This generates the moran distances for cross-correlation
		#the odd adding of zero is just to ensure that all vectors 
		#are treated as numeric
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0

		moran <- cor2(t(z), circ=FALSE)
	}

	else {
	#This generates the moran distances for cross-correlation
		#the odd adding of zero is just to ensure that all vectors 
		#are treated as numeric
		n <- dim(z)[1]
		p <- dim(z)[2]
		z <- as.matrix(z)+0
		w <- as.matrix(w)+0

		moran <- cor2(t(z), t(w), circ=FALSE)
	}

	if(is.null(df)){
		df <- sqrt(n)
	}

	maxdist <- ifelse(!xmax,max(sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)),xmax)
	xpoints <- seq(-maxdist, maxdist, length = npoints)

#loop over directions
ang <- (2*pi)*angle/360
for(d in 1:length(ang)){
#The next fits the spline function
#then generating geographic distances
	y2 <- x * sin (ang[d]) + y * cos (ang[d])

	xdist <- outer(y2,y2,"-")

	if(jitter == TRUE) {
		#this is corrected to be
		#xdist <- jitter(xdist)
		xdist <- apply(xdist,2,jitter)
	}

	mdist <- max(xdist)

	if(is.null(w)){
		triang <- col(xdist)!=row(xdist)
	}

	else {
		triang <- xdist
		triang[,] <- TRUE
		triang <- triang==1
	}

	u <- xdist[triang]
	v <- moran[triang]
	sel <- is.finite(v) & is.finite(u)
	u <- u[sel]
	v <- v[sel]
	v <- v[abs(u) <= maxdist]
	u <- u[abs(u) <= maxdist]

	out=gather(u=u,v=v,w=w, moran=moran, df=df, xpoints=xpoints, filter=FALSE, fw=0)
	real$cbar <- mean(v)
	if(is.null(w)){
		real[[d]]$y.intercept <- out$yint
	}
	else{
		real[[d]]$y.intercept <-  mean(diag(moran))
	}

	real[[d]]$predicted <- list(x = out$x, y = out$y)
	real[[d]]$predicted$y[abs(real[[d]]$predicted$x)>mdist] <- NA
	real[[d]]$x.intercept <-out$xint
	real[[d]]$e.intercept <- out$eint
	real[[d]]$cbar.intercept <- out$cint
	
	
##End of spline fit

	if(resamp != 0) {
	#here is the bootstrapping/randomization
		boot[[d]]$predicted$x[1,] <- xpoints

		for(i in 1:resamp) {
		whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){cat(i, " of ", resamp, "(direction", d, "of ", length(ang),")\r")
		flush.console()}
		if(type == 1) {
			trekkx <- sample(1:n, replace = TRUE)
			trekky <- trekkx
		}

		if(type == 2) {
			trekky <- sample(1:n, replace = FALSE)
			trekkx <- 1:n
		}

		xdistb <- xdist[trekkx, trekkx]

		if(is.null(w)){
			triang <- col(xdistb)!=row(xdistb)
		}

		else {
			triang <- xdistb
			triang[,] <- TRUE
			triang <- triang==1
		}

		xdistb <- xdistb[triang]
		moranb <- moran[trekky, trekky][triang]

		if(type == 1&is.null(w)) {
			moranb <- moranb[!(xdistb == 0)]
			xdistb <- xdistb[!(xdistb == 0)]
		}

		u <- xdistb
		v <- moranb
		sel <- is.finite(v) & is.finite(u)
		u <- u[sel]
		v <- v[sel]
		v <- v[u<=maxdist]
		u <- u[u<=maxdist]

	out=gather(u=u,v=v,w=w, moran=moranb, df=df, xpoints=xpoints, filter=FALSE, fw=0)
	boot[[d]]$boot.summary$cbar[i,1] <- mean(v)		
	
		if(is.null(w)){
			boot[[d]]$boot.summary$y.intercept[i,1] <- out$yint
		}
		else {
			boot[[d]]$boot.summary$y.intercept[i,1] <- mean(diag(moran[trekky, trekky]))
		}

	boot[[d]]$predicted$y[i,] <- out$y
	boot[[d]]$predicted$y[i,][abs(boot[[d]]$predicted$x[1,])>mdist] <- NA
	boot[[d]]$boot.summary$x.intercept[i,1] <- out$xint
	boot[[d]]$boot.summary$e.intercept[i,1] <- out$eint
	boot[[d]]$boot.summary$cbar.intercept[i,1]  <- out$cint
	}

##end of bootstrap loop!

	if(save == TRUE) {
		boot[[d]]$boot <- list(predicted = boot[[d]]$predicted)
			}
	else {
		boot[[d]]$boot <- NULL
		}

	ty <- apply(boot[[d]]$predicted$y, 2, quantile, probs = c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 
			0.75, 0.9, 0.95, 0.975, 1), na.rm = TRUE)
		dimnames(ty) <- list(c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 1), NULL)
		tx <- boot[[d]]$predicted$x
		boot[[d]]$boot.summary$predicted <- list(x = tx,y = ty)
	}

}	
	res <- list(real = real, boot = boot, max.distance = maxdist, angle=angle, call=deparse(match.call()))
	class(res) <- "Sncf2D"
	res
}

##############################################################################################
print.Sncf2D=function(x, ...){
##############################################################################################
cat("This is an object of class Sncf2D produced by the call:\n\n", x$call, "\n\n Use summary() or plot() for inspection,  (or print.default() to see all the gory details).")}

##############################################################################################
plot.Sncf2D <- function(x, xmax = 0, ylim=c(-1,1), detail = FALSE, ...){
##############################################################################################
#this is the generic plot function for Sncf2D objects
##############################################################################################
	L<-length(x$angle)

	xmax <- ifelse(xmax == 0, x$max.distance, xmax)
	plot(x$real[[1]]$predict$x, x$real[[1]]$predict$y, xlim = c(-xmax, xmax), ylim
			 = ylim, type = "n", xlab = "", ylab = "")
	lines(c(-max(x$real[[1]]$predict$x), max(x$real[[1]]$predict$x)), c(0, 0))
	lines(c(-max(x$real[[1]]$predict$x), max(x$real[[1]]$predict$x)), c(x$real$cbar, x$real$cbar))

	if(detail){
	
	par(mfrow=c(ceiling(sqrt(L)),ceiling(sqrt(L))))

	for(i in 1:L){
		plot(x$real[[i]]$predict$x, x$real[[i]]$predict$y, xlim = c(-xmax, xmax), ylim
			 = ylim, type = "l", xlab = "Distance", ylab = "Correlation")

	if(!is.null(x$boot[[i]]$boot.summary)){
 polygon(c(x$boot[[i]]$boot.summary$predicted$x,rev(x$boot[[i]]$boot.summary$predicted$x)), c(x$boot[[i]]$boot.summary$predicted$y["0.025",], rev(x$boot[[i]]$boot.summary$predicted$y["0.975",])), col=gray(0.8), lty=0)
         }	
	lines(x$real[[i]]$predict$x, x$real[[i]]$predict$y)
	lines(c(-max(x$real[[i]]$predict$x), max(x$real[[i]]$predict$x)), c(0, 0))
	lines(c(-max(x$real[[i]]$predict$x), max(x$real[[i]]$predict$x)), c(x$real$cbar, x$real$cbar))
	}
	}
}

##############################################################################################
summary.Sncf2D<-function(object, ...){
##############################################################################################
#this is the generic summary function for Sncf objects
##############################################################################################
	L<-length(object$angle)

	xy <- matrix(NA, ncol=L, nrow=4)
	dimnames(xy) <- list(c("x", "e", "cbar", "y"),
		unlist(lapply(object$angle, as.name)))
	xyd <- lapply(unlist(lapply(object$angle, as.name)),as.null)
	names(xyd)<-unlist(lapply(object$angle, as.name))

	for(i in 1:L){
		xyd[[i]]<-matrix(NA, ncol=7, nrow=4)
	}

	cbar <- round(object$real$cbar, 2)

	for(i in 1:L){
		xy[1,i] <- round(object$real[[i]]$x.intercept, 2)
		xy[2,i] <- round(object$real[[i]]$e.intercept, 2)
		xy[3,i] <- round(object$real[[i]]$cbar.intercept, 2)
		xy[4,i] <- round(object$real[[i]]$y.intercept, 2)
		if(!is.null(object$boot[[i]]$boot.summary)){
		yd <- apply(object$boot[[i]]$boot.summary$y.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
			0.75, 0.975, 1), na.rm= TRUE)
		xd <- apply(object$boot[[i]]$boot.summary$x.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
			0.75, 0.975, 1), na.rm= TRUE)
		ed <- apply(object$boot[[i]]$boot.summary$e.intercept, 2, quantile, probs = c(0, 0.025, 0.25, 0.5,
			0.75, 0.975, 1), na.rm= TRUE)
		synchd <- quantile(object$boot[[i]]$boot.summary$cbar[,1], probs = c(0, 0.025, 0.25, 0.5,
			0.75, 0.975, 1), na.rm= TRUE)
		cbard <- quantile(object$boot[[i]]$boot.summary$cbar.intercept[,1], probs = c(0, 0.025, 0.25, 0.5,
			0.75, 0.975, 1), na.rm= TRUE)
		xyd[[i]] <- cbind(xd, ed, yd, cbard)
		dimnames(xyd[[i]]) <- list(c(0, 0.025, 0.25, 0.5, 0.75, 0.975, 1), c("x", "e", "y", "cbar"))}
		if(is.null(object$boot[[i]]$boot.summary)){
			synchd <- NULL
			xyd <- NULL	
		}
	}
	res <- list(call = object$call, Regional.synch = object$real$cbar, Squantile = synchd, estimates = xy, quantiles = xyd)
	res
}


##############################################################################################
cc.offset<-function(object, xmax=NULL){
##############################################################################################
#calculates offsets in Sncf2D cross-correltions
##############################################################################################

	L<-length(object$angle)

	if(is.null(xmax)){
		xmax<-object$max.distance
	}

	if(is.null(object$boot[[1]]$boot.summary)){
		xy <- matrix(NA, ncol=3, nrow=L)
		dimnames(xy) <- list(unlist(lapply(object$angle, as.name)),
			c("angle", "distance", "correlation"))
	}
	if(!is.null(object$boot[[1]]$boot.summary)){
		xy <- matrix(NA, ncol=7, nrow=L)
		dimnames(xy) <- list(unlist(lapply(object$angle, as.name)),
			c("angle", "distance", "correlation", "dL", "dU", "cL", "cU"))
	}

	xy[,1]<-object$angle

	for(i in 1:L){
		sel<-object$real[[i]]$predict$x>=0&object$real[[i]]$predict$x<xmax
		D<-object$real[[i]]$predict$x[sel]
		D2<-object$real[[i]]$predict$y[sel]
		xy[i,2]<-na.omit(D[D2==max(D2, na.rm= TRUE)])[1]
		xy[i,3]<-na.omit(D2[D2==max(D2, na.rm= TRUE)])[1]
		if(!is.null(object$boot[[i]]$boot.summary)){
			xy[i,4:5]<-range(object$boot[[i]]$boot.summary$predict$x[sel][(object$boot[[i]]$boot.summary$predict$y["0.975", sel]-max(D2, na.rm= TRUE))>0], na.rm= TRUE)
			xy[i, 7]<-object$boot[[i]]$boot.summary$predict$y["0.975", sel][rev(order(na.omit(D2)))[1]]
			xy[i, 6]<-object$boot[[i]]$boot.summary$predict$y["0.025", sel][rev(order(na.omit(D2)))[1]]
		}
	}
	class(xy)<-"cc.offset"
	return(xy)
}

##############################################################################################
plot.cc.offset <- function(x, dmax=NULL, inches=NULL, ...){
##############################################################################################
#this is the generic plot function for cc.offset objects
##############################################################################################
	theta <- 2*pi*x[,"angle"]/360
	x2 <- x[,"distance"]*sin(theta)
	y <- x[,"distance"]*cos(theta)
	inc=inches
	if(is.null(dmax)) dmax=max(abs(c(x2,y)))
	if(is.null(inches)) inc=.1
	#tmp<-rep(0, length(theta))
	tmp<-x[,"correlation"]
  	axs=pretty(c(0, dmax), n=4)
  	yl=xl=c(-max(axs), max(axs))
	symbols(x2,y, circles= ifelse(tmp>0,tmp,0), inches=inc, xlim=xl, ylim=yl, xlab="", ylab="", fg=1, bg=2, asp=1, xaxt="n", yaxt="n", bty="n")
	symbols(rep(0,length(axs)), rep(0,length(axs)), circles=axs, inches=FALSE, xlab="", 
        ylab="", xaxt="n", yaxt="n", bty="n", add=TRUE)	
	lines(c(0,0), yl)
	lines(yl, c(0,0))
	text(axs[-1], rep(0,length(axs))[-1], axs[-1], cex=0.6, pos=1)
	symbols(x2,y, circles= ifelse(tmp>0,tmp,0), inches=inc, xlim=xl, ylim=yl, xlab="", ylab="", fg=1, bg=2, asp=1, xaxt="n", yaxt="n", add=TRUE, bty="n")
}

##############################################################################################
spline.correlog.2D <- function(x, y, z, w=NULL, df = NULL, type = "boot", resamp = 1000, npoints = 300,
  save = FALSE, max.it=25, xmax=FALSE, na.rm = FALSE, jitter=FALSE, quiet=FALSE,
  angle=c(0,22.5,45,67.5,90,112.5,135,157.5)){
##############################################################################################
#spline.correlog.2D is the function to estimate the anisotropic nonparametric covariance function
#(using a smoothing spline as an equivalent kernel) in 8 (or arbitrary) directions (North - Southeast) 
#through calculateing projected distances onto the different bearings (i.e. all data are used for each 
#direction = 0,22.5,45,67.5,90,112.5,135,157.5)
############################################################################################

#the following sets up the output:

real<-lapply(unlist(lapply(angle, as.name)),as.null)
names(real)<-unlist(lapply(angle, as.name))

for(i in 1:length(angle)){
	real[[i]]<-list(x.intercept = NA, e.intercept = NA, y.intercept = NA, 
	cbar.intercept = NA, predicted = list(x = matrix(NA, nrow = 1, 
	ncol = npoints), y = matrix(NA, nrow = 1, ncol = npoints)))
}

real$cbar<-NA

if(resamp==0){
	boot<-lapply(unlist(lapply(angle, as.name)),as.null)
	names(boot)<-unlist(lapply(angle, as.name))
}

else{
	boot<-lapply(unlist(lapply(angle, as.name)),as.null)
	names(boot)<-unlist(lapply(angle, as.name))

	for(i in 1:length(angle)){
		boot[[i]]<-list(boot.summary=list(
		cbar = matrix(NA, ncol=1, nrow=resamp),
		x.intercept = matrix(NA, ncol=1, nrow=resamp),
	        e.intercept = matrix(NA, ncol=1, nrow=resamp),
		y.intercept = matrix(NA, ncol=1, nrow=resamp),
		cbar.intercept = matrix(NA, ncol=1, nrow=resamp)
		),
		predicted= list(x = matrix(NA, nrow = 1, ncol = npoints),
		 y = matrix(NA, nrow = resamp, ncol = npoints)))
	}
}

type <- charmatch(type, c("boot", "perm"), 
	nomatch = NA)
if(is.na(type))
	stop("method should be \"boot\", or \"perm\"")

NAO <- FALSE

#check for missing values
if(any(!is.finite(z))) {
	if(na.rm){
		warning("Missing values exist; Pairwise deletion will be used")
		NAO <- TRUE
	}
	else {
		stop("Missing values exist; use na.rm = TRUE for pariwise deletion")
	}
}

#This generates the moran distances for cross-correlation
#the odd adding of zero is just to ensure that all vectors 
#are treated as numeric
n <- length(z)
#p <- dim(z)[2]
#z <- as.matrix(z)+0

#moran <- cor2(t(z), circ=FALSE)

zscal <- (scale(z, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))

if(is.null(w)){
	moran <- t(outer(zscal, zscal))
}
else {
	wscal <- (scale(w, center = TRUE, scale = TRUE)[, 1])/(sqrt((n-1)/n))
	zw <- c(zscal,wscal)
	moran <- t(outer(zw, zw))[1:n,(n+1):(2*n)]
}


if(is.null(df)){
	df <- sqrt(n)
}

maxdist <- ifelse(!xmax,max(sqrt(outer(x,x, "-")^2+outer(y,y,"-")^2)),xmax)
xpoints <- seq(-maxdist, maxdist, length = npoints)

#loop over directions
ang <- (2*pi)*angle/360
for(d in 1:length(ang)){
#The next fits the spline function
#then generating geographic distances
	y2 <- x * sin (ang[d]) + y * cos (ang[d])

	xdist <- outer(y2,y2,"-")

	if(jitter == TRUE) {
		#xdist <- jitter(xdist)
		xdist<-apply(xdist,2,jitter)
	}

	mdist <- max(xdist)

	if(is.null(w)){
		triang <- col(xdist)!=row(xdist)
	}

	else {
		triang <- xdist
		triang[,] <- TRUE
		triang <- triang==1
	}

	u <- xdist[triang]
	v <- moran[triang]
	sel <- is.finite(v) & is.finite(u)
	u <- u[sel]
	v <- v[sel]
	v <- v[abs(u) <= maxdist]
	u <- u[abs(u) <= maxdist]

	out=gather(u=u,v=v,w=w, moran=moran, df=df, xpoints=xpoints, filter=FALSE, fw=0)
	real$cbar <- mean(v)
	if(is.null(w)){
		real[[d]]$y.intercept <- out$yint
	}
	else{
		real[[d]]$y.intercept <-  mean(diag(moran))
	}

	real[[d]]$predicted <- list(x = out$x, y = out$y)
	real[[d]]$predicted$y[abs(real[[d]]$predicted$x)>mdist] <- NA
	real[[d]]$x.intercept <-out$xint
	real[[d]]$e.intercept <- out$eint
	real[[d]]$cbar.intercept <- out$cint

##End of spline fit

	if(resamp != 0) {
	#here is the bootstrapping/randomization
		boot[[d]]$predicted$x[1,] <- xpoints

		for(i in 1:resamp) {
				whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
			cat(i, " of ", resamp, "(direction", d, "of ", length(ang),")\r")
		flush.console()}
		if(type == 1) {
			trekkx <- sample(1:n, replace = TRUE)
			trekky <- trekkx
		}

		if(type == 2) {
			trekky <- sample(1:n, replace = FALSE)
			trekkx <- 1:n
		}

		xdistb <- xdist[trekkx, trekkx]

		if(is.null(w)){
			triang <- col(xdistb)!=row(xdistb)
		}

		else {
			triang <- xdistb
			triang[,] <- TRUE
			triang <- triang==1
		}

		xdistb <- xdistb[triang]
		moranb <- moran[trekky, trekky][triang]

		if(type == 1&is.null(w)) {
			moranb <- moranb[!(xdistb == 0)]
			xdistb <- xdistb[!(xdistb == 0)]
		}

		u <- xdistb
		v <- moranb
		sel <- is.finite(v) & is.finite(u)
		u <- u[sel]
		v <- v[sel]
		v <- v[u<=maxdist]
		u <- u[u<=maxdist]

	out=gather(u=u,v=v,w=w, moran=moranb, df=df, xpoints=xpoints, filter=FALSE, fw=0)
	boot[[d]]$boot.summary$cbar[i,1] <- mean(v)		
	
		if(is.null(w)){
			boot[[d]]$boot.summary$y.intercept[i,1] <- out$yint
		}
		else {
			boot[[d]]$boot.summary$y.intercept[i,1] <- mean(diag(moran[trekky, trekky]))
		}

	boot[[d]]$predicted$y[i,] <- out$y
	boot[[d]]$predicted$y[i,][abs(boot[[d]]$predicted$x[1,])>mdist] <- NA
	boot[[d]]$boot.summary$x.intercept[i,1] <- out$xint
	boot[[d]]$boot.summary$e.intercept[i,1] <- out$eint
	boot[[d]]$boot.summary$cbar.intercept[i,1]  <- out$cint
	}

##end of bootstrap loop!

	if(save == TRUE) {
		boot[[d]]$boot <- list(predicted = boot[[d]]$predicted)
			}
	else {
		boot[[d]]$boot <- NULL
		}

	ty <- apply(boot[[d]]$predicted$y, 2, quantile, probs = c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 
			0.75, 0.9, 0.95, 0.975, 1), na.rm = TRUE)
		dimnames(ty) <- list(c(0, 0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 0.975, 1), NULL)
		tx <- boot[[d]]$predicted$x
		boot[[d]]$boot.summary$predicted <- list(x = tx,y = ty)
	}

}	
	res <- list(real = real, boot = boot, max.distance = maxdist, angle=angle, call=deparse(match.call()))
	class(res) <- "Sncf2D"
	res
}


##############################################################################################
mantel.correlog<-function(dmat, zmat, wmat=NULL, increment, resamp = 1000, quiet=FALSE){
##############################################################################################

if(is.null(wmat)){
	moran <- zmat[lower.tri(zmat)]
	}

else {
    moran <- (zmat-mean(zmat))*(wmat-mean(wmat))/(sd(zmat)*sd(wmat))
	zero <- mean(diag(moran), na.rm= TRUE)
	moran <- moran[row(moran)>col(moran)]
}

if(resamp != 0){
	dmat2 <- dmat
	moran2 <- moran
}

if(is.null(wmat)){
	dmat <- dmat[lower.tri(dmat)]
}
else {
	dmat <- dmat[row(dmat)>col(dmat)]
}


dkl <- ceiling(dmat/increment)
nlok <- sapply(split(moran, dkl), length)
dmean <- sapply(split(dmat, dkl), mean, na.rm = TRUE)
moran <- sapply(split(moran, dkl), mean, na.rm = TRUE)

ly <- 1:length(dmean)
x <- c(dmean[ly[moran < 0][1]], dmean[ly[moran < 0][1] - 1])
y <- c(moran[ly[moran < 0][1] - 1], moran[ly[moran < 0][1]])
if(moran[1] < 0) {
		tmp <- 0
	}
	else {
		if(sum(moran<0)>0){
			tmp <- lm(x ~ y)[[1]][1]
		}
		else{
			tmp <- NA
		}
	}

  p<-NULL

	if(resamp != 0){
		perm <- matrix(NA, ncol = length(moran), nrow = resamp)

    n<-dim(zmat)[1]
		for(i in 1:resamp){
			trekk <-sample(1:n)
			dma <- dmat2[trekk,trekk]
			mor <- moran2

			if(is.null(wmat)){
				dma <- dma[lower.tri(dma)]
			}
			else {
				dma <- dma[row(dma)>col(dma)]
			}

			dkl <- ceiling(dma/increment)	#generates the distance matrices
			perm[i,] <- sapply(split(mor, dkl), mean, na.rm = TRUE)
			
			whn=pretty(c(1,resamp), n=10)
		if(! quiet & any(i==whn)){
		cat(i, " of ", resamp, "\r")
		flush.console()}
		}

  p=(apply(moran<=t(perm),1,sum))/(resamp+1)
  p=apply(cbind(p, 1-p), 1, min) + 1/(resamp+1)
	}

	res <- list(n = nlok, mean.of.class = dmean, correlation = moran,
  x.intercept = tmp, p=p, call=deparse(match.call()))

	if(!is.null(wmat)){
		res$corr0 <- zero
	}
	class(res) <- "correlog"
	res
}

############################################################################################
circ.cor2<-function (x, y=NULL){
#Fast vectorized circular correlation 
############################################################################################
		circ.mean<-function (x){
 		    x=na.omit(x)
 		    sinr <- sum(sin(x))
 		    cosr <- sum(cos(x))
 		    circmean <- atan2(sinr, cosr)
 		    circmean
 		}
		
			if(is.vector(x) & is.vector(y)){
			x=as.matrix(x)
			y=as.matrix(y)
			}
 		        x.bar <- apply(x, 2, circ.mean)
 		        	y.bar <- apply(y, 2, circ.mean)
			num <- tcrossprod(sin(t(x) - x.bar), sin(t(y) - y.bar))
	                 den <- sqrt(outer(
    			apply(t(sin(t(x) - x.bar))^2,2,sum),
			    apply(t(sin(t(y) - y.bar))^2, 2,sum), "*"))
 		        r <- num/den
 		return(r)
 	}


############################################################################################
cor2<-function(x, y = NULL, circ=FALSE){
############################################################################################
	circ.cor<-function (x, y){
		circ.mean<-function (x){
		    sinr <- sum(sin(x))
		    cosr <- sum(cos(x))
		    circmean <- atan2(sinr, cosr)
		    circmean
		}
		ok <- (is.finite(x) & is.finite(y))
		x <- x[ok]
		y <- y[ok]
		n <- length(x)
		r<-NA
		if(n >= 2){
		        x.bar <- circ.mean(x)
	        	y.bar <- circ.mean(y)
		        num <- sum(sin(x - x.bar) * sin(y - y.bar))
		        den <- sqrt(sum(sin(x - x.bar)^2) * sum(sin(y - y.bar)^2))
		        r <- num/den
		}
		return(r)
	}

    if (is.data.frame(x))
        x <- as.matrix(x)
    if (is.data.frame(y))
        y <- as.matrix(y)
    if (!is.matrix(x) && is.null(y))
        stop("supply both x and y or a matrix-like x")
    if(!circ){
	    cor<-cor(x=x, y=y, use="pairwise.complete.obs", method = "pearson")
    }

    if(circ){
      if(is.null(y)){
		  y<-x
  	}

	if(all(is.finite(x)&is.finite(y))){
	cor<-circ.cor2(x,y)
	}
	
	if(!all(is.finite(x)&is.finite(y))){	
	cat("Missing values with circular data: calculations may take some time.")
	m<-dim(x)[2]
	#this part (for circular correlations is likely to be SLOW (it's a double loop)
	#I should use distm() from geosphere instead
	cor <- matrix(NA, nrow = m, ncol = m)
	for(i in 1:m) {
		for(j in i:m) {
			tmp <- circ.cor(as.vector(x[,i]), as.vector(y[,j]))
			cor[j, i] <- tmp
			cor[i, j] <- tmp
			}
		}
	}
    }
    return(cor)
}

############################################################################################
ff.filter<-function(x){
############################################################################################
#Fourier filter function
############################################################################################
	n<-length(x)
	x2<-c(x, rev(x[-c(1, n)]))
	fo<-Re(fft(x2))
	fo[fo<0]<-0
	ny<-Re(fft(fo, inverse=TRUE)/length(x2))
	return(ny[1:n])
}


#Def function colVars
colVars <- function(x, na.rm=FALSE, dims=1, unbiased=TRUE, SumSquares=FALSE,
                    twopass=FALSE) {
  if (SumSquares) return(colSums(x^2, na.rm, dims))
  N <- colSums(!is.na(x), FALSE, dims)
  Nm1 <- if (unbiased) N-1 else N
  if (twopass) {x <- if (dims==length(dim(x))) x - mean(x, na.rm=na.rm) else
    sweep(x, (dims+1):length(dim(x)), colMeans(x,na.rm,dims))}
  (colSums(x^2, na.rm, dims) - colSums(x, na.rm, dims)^2/N) / Nm1
}


#Read data
dat <- read.csv("1.csv")

loop <- as.integer(nrow(dat)/500)

for(b in 1:(loop-5)){
  contact <- 500*(2+b)
  off<- contact+100

  #Order: preFC, postFC, preFO, postFO
  AnalysisWindow <- list()
  AnalysisWindow[[1]] <- dat[c((contact-19):contact),]
  AnalysisWindow[[2]] <- dat[c((contact+1):(contact+20)),]
  AnalysisWindow[[3]] <- dat[c((off-19):off),]
  AnalysisWindow[[4]] <- dat[c((off+1):(off+20)),]

  #Modify the zero-variance columns
  for(j in 1:4){
    tmp <- colVars(AnalysisWindow[[j]])
    for(i in 2:9){
      if(tmp[i] == 0){
        AnalysisWindow[[j]][,i][20] = AnalysisWindow[[j]][,i][19] + 1
      }
    }
  }

  #Change to time series
  Inter <- list()
  for(j in 1:4){
    x <- list()
    # Order: L toe, inner, outer, heel R
    for(i in 1:8){
      x[[i]] <- as.ts(AnalysisWindow[[j]][,i+1], start=min(AnalysisWindow[[j]]$T), end=max(AnalysisWindow[[j]]$T))
    }
    Inter[[j]] <-x
  }

  #Calculate F1 for each analysis window
  F1 <-list()
  for(j in 1:4){
    y <- matrix(0, ncol = 3, nrow = 8)
    for(i in 1:8){
      y[i,] <- ar(Inter[[j]][[i]], aic = FALSE, 3)$ar
    }
    F1[[j]] <- y
  }

  #Calculate F2 for each analysis window
  F2 <- list()
  for(k in 1:4){
    z <- NULL
    for(i in 1:4){
      for(j in 2:4){
        if(j > i){
          z <- c(z, cor(AnalysisWindow[[k]][,i+1], AnalysisWindow[[k]][,j+1], method = "pearson"))
        }
      }
    }
    
    for(i in 1:4){
      for(j in 2:4){
        if(j > i){
          z <- c(z, cor(AnalysisWindow[[k]][,i+5], AnalysisWindow[[k]][,j+5], method = "pearson"))
        }
      }
    }
    F2[[k]] <- z
  }

  #Calculate F3 for each analysis window
  F3 <- list()
  for(k in 1:4){
    s = 0
    for(i in 2:9){
      s = s + var(AnalysisWindow[[k]][,i])
    }
    F3[[k]] <- s
  }

  #Write to file
  a <- as.vector(t(F1[[1]]))
  a <- c(a, as.vector(t(F2[[1]])))
  a <- c(a, F3[[1]])
  res <- paste(a,collapse=",")
  write.table(res, file="parameter.csv", append = TRUE,eol ="\n", row.names=FALSE, col.names = FALSE, quote=FALSE)
}

#Clean up a bit
rm(a, b, i, j, k, s, x, y, z, dat, off, tmp, res, contact, Inter, AnalysisWindow)
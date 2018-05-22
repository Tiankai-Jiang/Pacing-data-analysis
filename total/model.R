setwd("~/Documents/Repertory/Advanced CS Experiment/DMonPacing/total/gaits")

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

tbl = list.files(pattern="*.csv")
for(file in tbl){
  
  #Read data
  dat <- read.csv(file)
  
  #Find threshold, use both left or right is OK
  dat["Sum_L"] <- NA
  dat$Sum_L <- rowSums(dat[,c(2:5)])
  total_variance <- var(dat$Sum_L)
  
  ###################################################################if static
  if(total_variance<3000){
    loop <- as.integer(nrow(dat)/300)
    
    #total_pressure
    total_pressure <- mean(rowSums(dat[,c(2:9)]))
    
    for(b in 2:(loop-1)){
      contact <- 300*b
      off<- contact+100
      a <- total_pressure
      s = 0
      for(i in 2:9){
        s = s + var(dat[contact:off,i])
      }
      a <- c(a, s)
      a <- c(a, substr(file, 1, nchar(file)-5))
      res <- paste(a,collapse=",")
      write.table(res, file="../static_parameter.csv", append = TRUE,eol ="\n", row.names=FALSE, col.names = FALSE, quote=FALSE)
    }
    rm(list=setdiff(ls(), "colVars"))
    next
  }
  
  ###################################################################else, it is dynamic
  
  threshold_L <- mean(dat$Sum_L)/3
  
  #total_pressure
  total_pressure <- mean(rowSums(dat[,c(2:9)]))
  
  pair_points <- list()
  ths = 2000
  l = 1
  dat2 <- dat
  dat2["Ind"] <- NA
  dat2[, "Ind"] <- as.numeric(rownames(dat2))
  cut <- subset(dat2, Sum_L > (threshold_L-10) & Sum_L < (threshold_L+10))
  
  for(i in 1:(nrow(cut)-1)){
    st <- as.integer(cut[i, "Ind"])
    ed <- as.integer(cut[i+1, "Ind"])
    if(var(dat[st:ed,]$Sum_L) > ths){
      pair_points[[l]] <- list(st, ed)
      l = l+1
    }
  }
  
  for(b in 2:(length(pair_points)-1)){
    contact <- pair_points[[b]][[1]]
    off<- pair_points[[b]][[2]]
    
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
    a <- c(a, total_pressure)
    a <- c(a, substr(file, 1, nchar(file)-5))
    res <- paste(a,collapse=",")
    write.table(res, file="../dynamic_parameter.csv", append = TRUE,eol ="\n", row.names=FALSE, col.names = FALSE, quote=FALSE)
  }
  
  #Clean up a bit
  rm(list=setdiff(ls(), "colVars"))
}

dat_static <- read.csv("../static_parameter.csv", header = FALSE)
static_separator <- mean(tapply(dat_static[,1], dat_static[,3], mean))
#static_separator <- mean(dat_static[,1])

require(MASS)
dat_dynamic <- read.csv("../dynamic_parameter.csv", header = FALSE)
data <- dat_dynamic[, 1:36]
label <- dat_dynamic[,39]
(lda.sol = lda(data, label))

rm(dat_static, dat_dynamic, colVars, data, label)
#Read data
dat <- read.csv("2.csv")

#Find threshold, use both left or right is OK
dat["Sum_L"] <- NA
dat$Sum_L <- rowSums(dat[,c(2:5)])
threshold_L <- mean(dat$Sum_L)/3

#############################################
##IMPORTANT! Find contact and off manually##
############################################
subset(dat, Sum_L > (threshold_L-5) & Sum_L < (threshold_L+5))
contact <- 588
off <- 683

#Order: preFC, postFC, preFO, postFO
AnalysisWindow <- list()
AnalysisWindow[[1]] <- dat[c((contact-19):contact),]
AnalysisWindow[[2]] <- dat[c((contact+1):(contact+20)),]
AnalysisWindow[[3]] <- dat[c((off-19):off),]
AnalysisWindow[[4]] <- dat[c((off+1):(off+20)),]

#Modify the zero-variance columns
for(j in 1:4){
  tmp <- colSums(AnalysisWindow[[j]])
  for(i in 2:9){
    if(tmp[i] == 0){
      AnalysisWindow[[j]][,i][20] = 1
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

#Clean up a bit
rm(i, j, k, s, x, y, z, dat, off, tmp, contact, threshold_L, Inter, AnalysisWindow)
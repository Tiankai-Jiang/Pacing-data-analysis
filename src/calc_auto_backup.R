#Read data
dat <- read.csv("7.csv")

#Find threshold, use both left or right is OK
dat["Sum_L"] <- NA
dat$Sum_L <- rowSums(dat[,c(2:5)])
threshold_L <- mean(dat$Sum_L)/3

pair_points <- list()
ths = 1000
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

contact <- pair_points[[1]][[1]]
off<- pair_points[[1]][[2]]

#if(length(pair_points))
#contact <- 588
#off <- 683

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

#Write to file
a <- as.vector(t(F1[[1]]))
a <- c(a, as.vector(t(F2[[1]])))
a <- c(a, F3[[1]])
res <- paste(a,collapse=",")
write.table(res, file="parameter.csv", append = TRUE,eol ="\n", row.names=FALSE, col.names = FALSE, quote=FALSE)

#Clean up a bit
rm(a, i, j, k, l, s, x, y, z, st, ed, cut, dat, dat2, off, tmp, res, ths, contact, threshold_L, Inter, AnalysisWindow)
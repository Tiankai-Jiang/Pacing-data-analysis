tbl = list.files(pattern="*.csv")
for(file in tbl){
  #Read data
  dat <- read.csv(file)
  
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

  #Clean up a bit
  rm(list=ls())
}
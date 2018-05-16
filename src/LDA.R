##dynamic
require(MASS)
require(ggplot2)

dat <- read.csv("../dynamic_parameter.csv", header = FALSE)
Gait_data <- dat[, 1:36]
Gait_label <- dat[,39]
(lda.sol = lda(Gait_data, Gait_label))
#result = predict(lda.sol, Gait_data)
#table(Gait_label, result$class)

p_dat <- read.csv("d_predict.csv")
p_Gait_data <- p_dat[, 1:36]
p_Gait_label <- p_dat[,39]
p = predict(lda.sol, p_Gait_data)
table(p_Gait_label, p$class)
qplot(p$x[,"LD1"], p$x[,"LD2"], color = p$class, xlab = "LD1", ylab = "LD2")

##static
dat <- read.csv("s_source.csv")
Gait_data <- dat[, c(4:12, 16:36)]
Gait_label <- dat[,38]
(lda.sol = lda(Gait_data, Gait_label))

p_dat <- read.csv("s_predict.csv")
p_Gait_data <- p_dat[, c(4:12, 16:36)]
p_Gait_label <- p_dat[,38]
p = predict(lda.sol, p_Gait_data)
table(p_Gait_label, p$class)
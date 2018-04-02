library(tidyverse)
library(reshape2)
dat <- read_csv("2.csv")
data_L <- dat[, c(1, 2, 3, 4, 5)]
data_R <- dat[, c(1, 6, 7, 8, 9)]
data_L["Sum"] <- NA
data_R["Sum"] <- NA
data_L$Sum <- data_L$L_Toe + data_L$L_Inner + data_L$L_Outer + data_L$L_Heel
data_R$Sum <- data_R$R_Toe + data_R$R_Inner + data_R$R_Outer + data_R$R_Heel
data_L_trans <- melt(data_L, id.vars = c("T"))
data_R_trans <- melt(data_R, id.vars = c("T"))

plot_L <- ggplot(data = data_L_trans) + 
  geom_line(mapping = aes(x = T, y = value, color = variable), lwd = 0.7) + 
  scale_color_manual(values= c("#d11141", "#00b159", "#00aedb", "#f37735", "#000000")) +
  ggtitle("Left") + xlab("Time(ms)") + ylab("Pressure")
ggsave("plot_L.png", width = 25, height = 10, units = "cm", dpi = 1000, path = "../")

plot_R <- ggplot(data = data_R_trans) + 
  geom_line(mapping = aes(x = T, y = value, color = variable), lwd = 0.7) + 
  scale_color_manual(values= c("#d11141", "#00b159", "#00aedb", "#f37735", "#000000")) +
  ggtitle("Right") + xlab("Time(ms)") + ylab("Pressure")
ggsave("plot_R.png", width = 25, height = 10, units = "cm", dpi = 1000, path = "../")
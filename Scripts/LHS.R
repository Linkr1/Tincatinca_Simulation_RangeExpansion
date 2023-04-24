rm(list=ls())
library(lhs)
library(colorspace)

setwd("C:/Users/thais/Documents/PhD/Chap3b_TenchCDmetapop")

# set the seed for reproducibility
set.seed(1111)

# a design with 300 samples from 5 parameters
A <- randomLHS(300,5) 

#now transform the margins to other distributions
B <- matrix(nrow = nrow(A), ncol = ncol(A))
B[,1] <- qunif(A[,1], min = 0.25, max = 0.80)#p
B[,2] <- qunif(A[,2], min = 0, max = 4.0)#alpha_sta
B[,3] <- qunif(A[,3], min = 6, max = 50)#alpha_mob
B[,4] <- qunif(A[,4], min = 0, max = 100)#phenotypicdiff
B[,5] <- floor(A[,5]*3) + 1 #landscape
B <- as.data.frame(B)
B <-  within(B,{
  landscape <- NA
  landscape[B[,5]==1] <- "Continuous"
  landscape[B[,5]==2] <- "Patchy (25%)"
  landscape[B[,5]==3] <- "Patchy (50%)"
} )

#Generate plot for manuscript
my_cols <- c("orange","blue","red")
pdf("LHS_explanatoryvar.pdf")
par(mfrow=c(2,2))
dotchart(B$V1,main="Share of stationary and mobile fish (%)",ylab="LHS #",groups=as.factor(B$landscape),gcolor=my_cols,color=my_cols[as.factor(B$landscape)],pch=19,cex=0.7)
dotchart(B$V2,main="Dispersal distance, stationary fish (Km)",ylab="LHS #",groups=as.factor(B$landscape),gcolor=my_cols,color=my_cols[as.factor(B$landscape)],pch=19,cex=0.7)
dotchart(B$V3,main="Dispersal distance, mobile fish (Km)",ylab="LHS #",groups=as.factor(B$landscape),gcolor=my_cols,color=my_cols[as.factor(B[,5])],pch=19,cex=0.7)
dotchart(B$V4,main="Difference in dispersal probability (%)",ylab="LHS #",groups=as.factor(B$landscape),gcolor=my_cols,color=my_cols[as.factor(B[,5])],pch=19,cex=0.7)
dev.off()

Toexp <- B[,-5]
colnames(Toexp) <- c("p","Disp_sta","Disp_mob","Diff_Disp","Landscape")
write.csv(Toexp,"LHS_parameters.csv", row.names = FALSE)

rm(list=ls())
setwd("C:/Users/thais/Documents/PhD/Chap5_TenchCDmetapop/Data/")

#PATH to data
dfcentralPATH <- "Metrics_2301.txt" #This is the concatenated file (across the 3 landscapes)
dfcentral <- read.table(dfcentralPATH,header=TRUE,sep=" ") 
str(dfcentral)
#note I manually corrected one of the values (LHS_37), which failed to expend towards two invasion fronts so the CV doesnt make sense


#### Data exploration ####
options(scipen = 100)
#Mean expansion rate
hist(dfcentral$Colon_rate) 
ggplot2::ggplot(data=dfcentral,aes(x=Colon_rate))+geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)
# Ho loss
hist(dfcentral$Gendiv_loss)
ggplot2::ggplot(data=dfcentral,aes(x=Gendiv_loss))+geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)
hist(dfcentral$Colon_CV) 
hist(dfcentral$cvgendivloss)
#Ae loss
hist(dfcentral$Ae_loss)
ggplot2::ggplot(data=dfcentral,aes(x=Ae_loss))+geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)
hist(dfcentral$CVAeloss)
plot(dfcentral) 

#Summary for results
pastecs::stat.desc(dfcentral)
#Number of simulation in which the landscape was never fully colonized.
sum(dfcentral[dfcentral$Landscape=="Continuous",]$Colon_npatches < 229,
    dfcentral[dfcentral$Landscape=="Patchy_25",]$Colon_npatches < 171,
    dfcentral[dfcentral$Landscape=="Patchy_50",]$Colon_npatches < 114) 
#Number of sim where there was no loss in genetic diversity 
sum(dfcentral$Gendiv_loss < 0)
subgen <- dfcentral[dfcentral$Gendiv_loss<0,]
pastecs::stat.desc(subgen$Disp_mob)
pastecs::stat.desc(subgen)
dfcentral$diff_dist <- dfcentral$Disp_mob-dfcentral$Disp_sta

#Summary for spatial var
invRate_all <- read.csv("invRate_all.csv",sep=",")
#Invasion rate
aggregate(Rate~variable, FUN=sd, data=invRate_all)
aggregate(Rate~variable, FUN=mean, data=invRate_all)

#### create testing/training sets####
library(dismo)

#create data frame with only variables of interest
df_sub <- data.frame(dfcentral$p,dfcentral$Disp_sta,dfcentral$Disp_mob,dfcentral$Diff_disp,dfcentral$Landscape,dfcentral$Colon_rate,dfcentral$Gendiv_loss,dfcentral$Colon_sdrate,dfcentral$sdgendivloss,dfcentral$Ae_loss,dfcentral$sdAeloss)

#Collinearity
#We use the vif.mer function to ensure that the continuous variables are not collinear. Due to the LHS, they should not be. 
source("vif_func.R")
vif_func(df_sub[,c(1:4,6)]) #All continuous variables have VIF < 10, max VIF 2.59.  

## Create training (70%) and test (30%) sets.
## Use set.seed for reproducibility
set.seed(123)
library(rsample)
ames_split <- initial_split(df_sub, prop = .7)
df_train <- training(ames_split) #This contains 70% of the data (210 observations)
df_test  <- testing(ames_split) #This contains 30% of the data (90 observations)

##I suggest saving these! 

#subset
df_train <- df_train[,c("p","Disp_sta","Disp_mob","Diff_disp","Landscape","Colon_rate","Gendiv_loss","Colon_sdrate","sdgendivloss","Ae_loss","sdAeloss")]
df_test <- df_test[,c("p","Disp_sta","Disp_mob","Diff_disp","Landscape","Colon_rate","Gendiv_loss","Colon_sdrate","sdgendivloss","Ae_loss","sdAeloss")]
df_train$Landscape <- as.factor(df_train$Landscape)
df_test$Landscape <- as.factor(df_test$Landscape)

#For the gendiv model; multiply gendiv by 100 (mean and sd)
df_train$Gendiv_loss <- df_train$Gendiv_loss*100
df_train$sdgendivloss <- df_train$sdgendivloss *100
df_test$Gendiv_loss <- df_test$Gendiv_loss*100
df_test$sdgendivloss <- df_test$sdgendivloss *100
df_train$diffdispmob <- df_train$Disp_mob-df_train$Disp_sta

#### Fit models####
#run simple model. 
invrate <- gbm.step(data=df_train, gbm.x = c(1:5), #predictors
                gbm.y = 6, #response
                family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                bag.fraction = 0.75)

Gendiv <- gbm.step(data=df_train, gbm.x = 1:5, #predictors
                    gbm.y = 7, #response
                    family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                    tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                    learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                    bag.fraction = 0.75)

Aediv <- gbm.step(data=df_train, gbm.x = 1:5, #predictors
                  gbm.y = 10, #response
                  family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                  tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                  learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                  bag.fraction = 0.75)

CV_invrate <- gbm.step(data=df_train, gbm.x = c(1:5), #predictors
                    gbm.y = 8, #response
                    family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                    tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                    learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                    bag.fraction = 0.75)

CV_gendiv <- gbm.step(data=df_train, gbm.x = 1:5, #predictors
                    gbm.y = 9, #response
                    family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                    tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                    learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                    bag.fraction = 0.75)

CV_Aediv <- gbm.step(data=df_train, gbm.x = 1:5, #predictors
                      gbm.y = 11, #response
                      family = "gaussian",#my data countains no zero, it is not really a binary outcome. 
                      tree.complexity = 3, #tree complexity; best to stick with 2 or 3 since the data set is relatively small (<500)
                      learning.rate = 0.01,#tradeoff with tc; try to get a combination that gives >1,000 trees.  
                      bag.fraction = 0.75)

#I suggest saving these models. 

#### Assess performance####
#Evaluate model
pred_rate  <-  dismo::predict(invrate,df_test,n.trees=invrate$gbm.call$best.trees, type="response")
pred_gendiv  <-  dismo::predict(Gendiv,df_test,n.trees=Gendiv$gbm.call$best.trees, type="response")
pred_Ae  <-  dismo::predict(Aediv,df_test,n.trees=Aediv$gbm.call$best.trees, type="response")
pred_CVrate  <-  dismo::predict(CV_invrate,df_test,n.trees=CV_invrate$gbm.call$best.trees, type="response")
pred_CVgendiv  <-  dismo::predict(CV_gendiv,df_test,n.trees=CV_gendiv$gbm.call$best.trees, type="response")
pred_CVAe  <-  dismo::predict(CV_Aediv,df_test,n.trees=CV_Aediv$gbm.call$best.trees, type="response")

Metric <- c("Mean invasion rate","Mean Ho","Mean Ae","Variation in invasion rate","variation in Ho","Variation in Ae")
Correlation<- c(cor(pred_rate,df_test$Colon_rate,method="spearman"),
         cor(pred_gendiv,df_test$Gendiv_loss,method="spearman"),
         cor(pred_Ae,df_test$Ae_loss,method="spearman"),
         cor(pred_CVrate,df_test$Colon_sdrate,method="spearman",use = "complete.obs"),
         cor(pred_CVgendiv,df_test$sdgendivloss,method="spearman",use = "complete.obs"),
         cor(pred_CVAe,df_test$sdAeloss,method="spearman")) 
Abs_error <- c(mean(abs(df_test$Colon_rate-pred_rate)),
          mean(abs(df_test$Gendiv_loss-pred_Ae)),
          mean(abs(df_test$Ae_loss-pred_gendiv)),
          mean(abs(df_test$Colon_sdrate-pred_CVrate),na.rm=T),
          mean(abs(df_test$sdgendivloss-pred_CVgendiv),na.rm=T),
          mean(abs(df_test$sdAeloss-pred_CVAe)))
Modperformance <- data.frame(Metric,Correlation,Abs_error) 
write.csv(Modperformance,"Modperformance.csv",row.names=FALSE)

#Investigae where the discrepancy lays for variation in invaison rate
predcor <- data.frame(df_test[,c(1:4,6)],pred_CVrate)
predcor <- predcor[complete.cases(predcor), ] 
Hmisc::rcorr(as.matrix(predcor),type="spearman")


#### Look at results####

#Relative influence of each explanatory variable
library(ggBRT)
ggInfluence(invrate,main="Mean invasion rate",col.bar = "red")
ggsave("Figs/Invrate_inf.pdf",scale=1)
ggInfluence(Gendiv, main="Mean Ho changes",col.bar = "blue")
ggsave("Figs/Gendiv_inf.pdf",scale=1)
ggInfluence(Aediv, main="Mean Ae changes",col.bar = "gold")
ggsave("Figs/Aediv_inf.pdf",scale=1)
ggInfluence(CV_invrate, main= "Variability in invasion rate",col.bar = "orange")
ggsave("Figs/VarInvrate_inf.pdf",scale=1)
ggInfluence(CV_gendiv,main= "Variability in Ho changes",col.bar = "grey60")
ggsave("Figs/VarGendiv_inf.pdf",scale=1)
ggInfluence(CV_Aediv,main= "Variability in Ae changes",col.bar = "grey60")
ggsave("Figs/VarAe_inf.pdf",scale=1)

####Partial dependence plots####
#Create list of predictors for bootstraping
list_pred <- plot.gbm.4list(invrate)
list_pred_gen <- plot.gbm.4list(Gendiv)
list_pred_Ae <- plot.gbm.4list(Aediv)
list_pred_CV_invrate <- plot.gbm.4list(CV_invrate)
list_pred_CVgen <- plot.gbm.4list(CV_gendiv) 
list_pred_CVAe <- plot.gbm.4list(CV_Aediv)

#Make boostrap samples
testboot_Invrate<-gbm.bootstrap.functions(invrate,list_pred,n.reps=1000)#make 1,000 bootstrap samples
testboot_Gendiv<-gbm.bootstrap.functions(Gendiv,list_pred_gen,n.reps=1000)
testboot_Aediv<-gbm.bootstrap.functions(Aediv,list_pred_Ae,n.reps=1000)
testboot_CVInrate<-gbm.bootstrap.functions(CV_invrate,list_pred,n.reps=1000)
testboot_CVGendiv<-gbm.bootstrap.functions(CV_gendiv,list_pred_CVgen,n.reps=1000)
testboot_CVAediv<-gbm.bootstrap.functions(CV_Aediv,list_pred_CVAe,n.reps=1000)

#Run this command to plot (for each predictor): 

ggPD_boot(invrate,predictor=1,list.4.preds=list_pred,booted.preds=testboot_Invrate$function.preds,cex.line=1,col.line="red",col.ci="grey",type.ci="ribbon")
ggsave("Figs/Invrate_pp1.pdf",scale=0.5)

####Look at interactions
ggInteract_list(invrate)
ggInteract_2D(gbm.object = invrate,x="Landscape",y="Disp_mob",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,24))
ggInteract_2D(gbm.object = invrate,x="Landscape",y="Disp_sta",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,16))
Interact_boot_invrate<-ggInteract_boot(c("Landscape","Disp_mob"),c("Landscape","Disp_sta"),
                                    nboots = 150,
                                    data=df_test, predictors =c(1:5), response=which(names(df_test)=="Colon_rate"),
                                    family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_invrate,column=2,obs=1482.44)#Sig
ggInteract_boot_hist(data=Interact_boot_invrate,column=3,obs=203.82)#Not sig

ggInteract_list(Gendiv,index=FALSE)
ggInteract_2D(gbm.object = Gendiv,y="dfcentral.Disp_mob",x="dfcentral.p",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,7))
ggInteract_2D(gbm.object = Gendiv,y="dfcentral.Disp_mob",x="dfcentral.Disp_sta",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,7))
Interact_boot_gendiv<-ggInteract_boot(c("dfcentral.Disp_mob","dfcentral.p"),c("dfcentral.Disp_mob","dfcentral.Disp_sta"),
                                       nboots = 100,
                                       data=df_test, predictors =c(1:5), response=which(names(df_test)=="dfcentral.Gendiv_loss"),
                                       family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_gendiv,column=2,obs=49.45)#Not Sig
ggInteract_boot_hist(data=Interact_boot_gendiv,column=3,obs=39.96)#Not sig

ggInteract_list(Aediv,index=FALSE)
ggInteract_2D(gbm.object = Aediv,y="Landscape",x="Disp_mob",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,0.25))
ggInteract_2D(gbm.object = Aediv,y="Disp_mob",x="p",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,0.25))
Interact_boot_Aediv<-ggInteract_boot(c("Landscape","Disp_mob"),c("Disp_mob","p"),
                                      nboots = 100,
                                      data=df_test, predictors =c(1:5), response=which(names(df_test)=="Ae_loss"),
                                      family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_Aediv,column=2,obs= 0.05,bindwidth=0.05)#Not Sig
ggInteract_boot_hist(data=Interact_boot_Aediv,column=3,obs=0.04,bindwidth=0.05)#Not sig

ggInteract_list(CV_invrate,index=FALSE)
ggInteract_2D(gbm.object = CV_invrate,x="dfcentral.Landscape",y="dfcentral.Disp_mob",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,8.5))
ggInteract_2D(gbm.object = CV_invrate,x="dfcentral.Disp_mob",y="dfcentral.p",col.gradient = c("white","#5576AF"),show.dot = T,col.dot = "grey20",alpha.dot = 0.5,cex.dot = 0.2,label.contour = T,col.contour = "#254376",show.axis = T,legend = T,z.range=c(0,8.5))
Interact_boot_CVinrate<-ggInteract_boot(c("dfcentral.Disp_mob","dfcentral.p"),c("dfcentral.Landscape","dfcentral.Disp_mob"),
                                      nboots = 150,
                                      data=df_test[complete.cases(df_test),], predictors =c(1:5), response=which(names(df_test[complete.cases(df_test),])=="dfcentral.Colon_sdrate"),
                                      family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_CVinrate,column=3,obs=136.49)#Not Sig
ggInteract_boot_hist(data=Interact_boot_CVinrate,column=2,obs=122.88)#not sig

ggInteract_list(CV_gendiv,index=FALSE)
Interact_boot_CVgendiv<-ggInteract_boot(c("dfcentral.Disp_mob","dfcentral.p"),c("dfcentral.Colon_rate","dfcentral.Disp_mob"),
                                        nboots = 200,
                                        data=df_test[complete.cases(df_test),], predictors =c(1:5), response=which(names(df_test[complete.cases(df_test),])=="dfcentral.sdgendivloss"),
                                        family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_CVgendiv,column=2)#Not sig
ggInteract_boot_hist(data=Interact_boot_CVgendiv,column=3)#Not sig

ggInteract_list(CV_Aediv,index=FALSE)
Interact_boot_CVAediv<-ggInteract_boot(c("Landscape","Disp_mob"),c("Disp_mob","Disp_sta"),
                                        nboots = 200,
                                        data=df_test[complete.cases(df_test),], predictors =c(1:5), response=which(names(df_test[complete.cases(df_test),])=="sdAeloss"),
                                        family = "gaussian", tc = 3, lr = 0.01, bf= 0.75,global.env=F)
ggInteract_boot_hist(data=Interact_boot_CVAediv,column=2,obs=0.15,bindwidth=0.05)#Not sig
ggInteract_boot_hist(data=Interact_boot_CVAediv,column=3,obs=0.03,bindwidth=0.05)#Not sig
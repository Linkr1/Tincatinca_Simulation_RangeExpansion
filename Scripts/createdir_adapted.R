#This script is adapted from the one Rachael wrote for the sneaker project. 
#The goal is to generate the files that will be used to run the CDmetapop simulations. 

##### import latin hypercube parameter combinations into popvars, patchvars, and classvars
### make path and file name changes in popvars, patchvars, classvars, runvars


#import LHS params
LHS_cont<-read.csv("./LHScont.csv",header=TRUE,sep=" ",check.names=FALSE)

#import popvars
popVar<-read.csv("./PopVarsS1_TB_0328.csv",header=TRUE,sep=",",check.names=FALSE)

#import patchvars
patchVar<-read.csv("./PatchvarsS1_0304_sizecont_Disp.csv",header=TRUE,sep=",",check.names=FALSE)

#import classvars
classVar<-read.csv("./ClassVars_0310_Disp_mobile.csv",header=TRUE,sep=",",check.names=FALSE)

#import runvars
runVar<-read.csv("./RunVars_0328_disp_lin.csv",header=TRUE,sep=",",check.names=FALSE)

for(x in 1:nrow(LHS_cont)){
  
  #create new directory
  dname<-paste0("LHS_",LHS_cont$Index[x]) #name the directory
  dir.create(dname) #creates a directory of "dname" within working directory
  
  #change popvars file (p, alphastat, alphamob)
  tempPopV<-popVar #a place holder while the new file is being created
  tempPopV[,28]<-LHS_cont$p[x]
  tempPopV[,29]<-LHS_cont$Disp_sta[x]
  tempPopV[,30]<-LHS_cont$Disp_mob[x]
  tempPopV[,1]<-paste("Patchvars_LHS_",LHS_cont$Index[x],".csv",sep="")
  #tempPopV[,c("mate_cdmat","migrateout_cdmat","migrateback_cdmat","stray_cdmat","disperseLocal_cdmat")]<-paste0("../../",tempPopV$mate_cdmat)
  fpath2<-paste0("./",dname,"/popvars_LHS_",LHS_cont$Index[x],".csv") #create file name with directory path
  write.csv(tempPopV,file=fpath2,row.names=FALSE,quote=FALSE) #write new file to .csv format
  
  #change classvars file (dispersal distance)
  tempClassV<-classVar
  tempClassV$Dispersal<-LHS_cont$Diff_Disp[x]
  tempClassV$Dispersal[1]=0
  fpath3<-paste0("./",dname,"/ClassVars_LHS_",LHS_cont$Index[x],".csv") #create file name with directory path
  #fpath4<-paste0("./",dname,"/Classvars_BT_distribution_LHS_",x,".csv")
  write.csv(tempClassV,file=fpath3,row.names=FALSE,quote=FALSE) #write new file to .csv format
  #write.csv(classVar_dist,file=fpath4,row.names=FALSE,quote=FALSE)
  
  #change runvar file (refers to popvar) 
  tempRunV<-runVar
  tempRunV$Popvars<-paste0("popvars_LHS_",LHS_cont$Index[x],".csv")
  fpath5<-paste0("./",dname,"/RunVars_LHS_",LHS_cont$Index[x],".csv") #create file name with directory path
  write.csv(tempRunV,file=fpath5,row.names=FALSE,quote=FALSE) #write new file to .csv format
  
  #change patchvars file (refers to patchvar)
  tempPatchV<-patchVar #a place holder while the new file is being created
  tempPatchV$`Class Vars` <- paste0("ClassVars_LHS_",LHS_cont$Index[x],".csv;../ClassVars_0310_Disp_mobile.csv")
 
  #fit<-tempPatchV$Fitness_aa[1] #the character string that needs to be modified for mature_eqn_slope
  #this is a beast of code that isolates the part of the character string, changes it to the number found in th LHS script and adds the change for all rows in patchvars
  #tempPatchV$Fitness_aa<-paste0(unlist(strsplit(fit,"~"))[1],"~",LHS$mature_eqn_slope[1],":","-6.04431","~",unlist(strsplit(fit,"~"))[3]) 
  #tempPatchV$`Genes Initialize`<-"../../Genetic_input/BT_randallele.csv;../../Genetic_input/BT_randallele_sneak.csv"
  #tempPatchV$`Class Vars`<-paste0("Classvars_BT_distribution_LHS_",x,".csv;Classvars_BT_Sneak_LHS_",x,".csv")
  #tempPatchV$N0<-round(tempPatchV$N0*LHS$N0[x]) #change the initial patch size..rounded to whole number
  fpath<-paste0("./",dname,"/Patchvars_LHS_",LHS_cont$Index[x],".csv") #create file name with directory path
  write.csv(tempPatchV,file=fpath,row.names=FALSE,quote=FALSE) #write new file to .csv format
}




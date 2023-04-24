# Tincatinca_Simulation_RangeExpansion

Description: In this paper we looked at the influence of long-distance dispersal and landscape heterogeneity on range expansion rate and the retention of genetic diversity. We used empirical data from Tench as a basis for the simulations. This study is published as "Simulating the effects of long-distance dispersal and landscape heterogeneity on the eco-evolutionary outcomes of range expansion in an invasive riverine fish, Tench (Tinca Tinca)" in Molecular Ecology. 
 
 This directory contains three folders organized as follows: 
  - Data: this folder contains the input files used to run the baseline scenarios with CDMetaPOP v2.48. 
  - Script: this folder contains the R script used to generate parameters using latin hypercube sampling (LHS.R) and the R script used to modify the CDMetaPop files for the alternative scenarios (createdir_adapted.R). It also contains a script used to run CDMetaPop simulations as a job array on the Cedar cluster (jobCDmetapop_array_cont.sh). 
  - Results: Raw data file produced from the 300 scenarios ("Metrics_2301.txt") and the R code for the boosted regression tree analysis (Tench_CDMeta_BRT_Bernos.R)

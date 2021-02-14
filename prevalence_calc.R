# Code based on R v 4.0.2
#
# This is a refactored version of the NCMP.R code, turning it into a single function: prevalence_calc()
# The function generates prevalence of stunting for children under 5, based on WHO standards of height-for-age
# Part of the output is broken down by sex and age in months, including actual counts in addition to prevalence.
# prevalence_calc() takes two arguments: the table with NCMP data and the end year the table refers to (e.g. 2019 for 2018-19).
#
# example run: 
# prevalence_calc(NCMP_data = data_201819, end_year = 2019)
#
# The function will need to be run on each year of data independently (separate csv files per year)
# The data should contain the following variables (columns): 
# AgeinMonths; Height; GenderCode; .......
# Outputs are two summary tables in .csv format, one detailed per month of age (Summary_stunting_AgeSex_year.csv), 
#                                                and one across age (<5) and sex (Summary_stunting_all_year.csv)
#
# (current cleaning removes -ves, but this step should be omitted for the final product)


prevalence_calc <- function(NCMP_data, end_year){
  # error handling and checks
  if(min(NCMP_data$AgeInMonths)<48) stop('Minimum age is less than 4 - check data')


  # rounding the age in months variable (to match WHO tables better)
  NCMP_data$AgeInMonths<-trunc(NCMP_data$AgeInMonths) #this truncates to the integer value, so similar to age in years rounding
  
  # clean up suppressions from dataset (may need to be more sophisticated, here just removing all negatives)
  # this will not be necessary when working with full data set!
  clean_NCMP <- NCMP_data[NCMP_data$Height > 0, ]
  
  # retaining only age groups of interest (under 5s, exclusing 5)
  clean_NCMP <- clean_NCMP[clean_NCMP$AgeInMonths<60, ] 
  # extract the unique ages in months (12 months in total, as we only have age 4)
  ages<- sort(unique(clean_NCMP$AgeInMonths))
  
  # loading the WHO standards (should be in the current working directory)
  who_girls <- read.csv("./height-for-age-(z-scores)-f.csv", header = T)
  who_boys <- read.csv("./height-for-age-(z-scores)-m.csv", header = T)
  
  
  # 1=boys and 2=girls in NCMP data; creating separate tables for each:
  NCMP_girls<-clean_NCMP[clean_NCMP$GenderCode==2, ]
  NCMP_boys<-clean_NCMP[clean_NCMP$GenderCode==1, ]
  # appending the -2SD cut-off from the WHO standards table to the NCMP tables
  NCMP_girls$WHO_SD <- who_girls$min2.SD[match(NCMP_girls$AgeInMonths,who_girls$Months)] 
  NCMP_boys$WHO_SD <- who_boys$min2.SD[match(NCMP_boys$AgeInMonths,who_boys$Months)] 
  
  
  # initiating an empty variables to hold the results
  deviations_girls <- NULL
  prevalence_girls <- NULL
  instances_girls <- NULL
  #main loop
  for(i in ages){
    total_age_temp<-nrow(NCMP_girls[NCMP_girls$AgeInMonths==i, ])
    deviations_temp<-nrow(NCMP_girls[NCMP_girls$AgeInMonths==i & NCMP_girls$Height < NCMP_girls$WHO_SD, ])
    prevalence_temp<-(deviations_temp/total_age_temp)*100 
    deviations_girls<-c(deviations_girls,deviations_temp)
    prevalence_girls<-c(prevalence_girls,prevalence_temp)
    instances_girls<-c(instances_girls,total_age_temp)
  }
  
  #formtting final table for girls with detailed results for age
  girls_table<-rbind(instances_girls,deviations_girls,prevalence_girls)
  colnames(girls_table)<-ages

  
  # global prevalence for under 5s girls (i.e. for 4 year olds)
  prevalence_under5_girls <- (sum(girls_table["deviations_girls", ])/sum(girls_table["instances_girls", ]))*100
  
  # same procedure, but for boys
  deviations_boys <- NULL
  prevalence_boys <- NULL
  instances_boys <- NULL
  #main loop
  for(i in ages){
    total_age_temp<-nrow(NCMP_boys[NCMP_boys$AgeInMonths==i, ])
    deviations_temp<-nrow(NCMP_boys[NCMP_boys$AgeInMonths==i & NCMP_boys$Height < NCMP_boys$WHO_SD, ])
    prevalence_temp<-(deviations_temp/total_age_temp)*100 
    deviations_boys<-c(deviations_boys,deviations_temp)
    prevalence_boys<-c(prevalence_boys,prevalence_temp)
    instances_boys<-c(instances_boys,total_age_temp)
  }
  
  #formtting final table for girls with detailed results for age
  boys_table<-rbind(instances_boys,deviations_boys,prevalence_boys)
  colnames(boys_table)<-ages
  
  # global prevalence for under 5s girls (i.e. for 4 year olds)
  prevalence_under5_boys <- (sum(boys_table["deviations_boys", ])/sum(boys_table["instances_boys", ]))*100
  
  prevalence_AgeSex <- rbind(girls_table, boys_table)
  
  
  # calculating total stunting prevalence across sex (can also be done from the table above):
  # joining girls and boys together (overwriting clean_NCMP to preserve the WHO_SD column)
  clean_NCMP <- rbind(NCMP_boys, NCMP_girls)
  stunting_prevalence_total <- (nrow(clean_NCMP[clean_NCMP$Height < clean_NCMP$WHO_SD, ])/nrow(clean_NCMP))*100
  
  # putting all summaries in one table
  prevalence_total<- rbind(prevalence_under5_boys,prevalence_under5_girls,stunting_prevalence_total)
  colnames(prevalence_total)<- end_year
  
  # outputting final tables (one directory up from current folder)
  write.csv(prevalence_total,paste("../Summary_stunting_all_",end_year,".csv", sep=""))
  write.csv(prevalence_AgeSex, paste("../Summary_stunting_AgeSex_",end_year,".csv", sep=""))
  return(paste("CSV outputs generated for year",end_year))
  
}
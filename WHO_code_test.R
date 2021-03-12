###############################################################################################
#
# The user must set the working directory to match the directory of this R script
# setwd() # uncomment this line to set the directory of the downloded script,, + csv files, keeping the folder with the data one directory above
#
###############################################################################################

# install the package and load it in your R session:
#install.packages("anthro",dependencies=TRUE, type="win.binary") #only need to do this once
library(anthro) #need to run every time you start a new session, if you want to use the package


# reading the data from 2018-19 download of the zipped file from NHS Digital, after extracting
# assuming the data csv is one level up from the current working directory
NCMP_data<-read.csv("../ncmp_1819_final_non_disclosive_published.csv")


# rounding/truncating the age in months variable
NCMP_data$AgeInMonths<-trunc(NCMP_data$AgeInMonths) 

# clean up suppressions from dataset (not necessary when working with full data set)
clean_NCMP <- NCMP_data[NCMP_data$Height > 0, ]

# retaining only age groups of interest (under 5s, exclusing 5)
clean_NCMP <- clean_NCMP[clean_NCMP$AgeInMonths<60, ]

# removing rows with suppressed imd 
clean_NCMP<-clean_NCMP[clean_NCMP$suppress_imd!="Y",]
unique(clean_NCMP$schoolindexofmultipledepriv) # checking the range is as expected (1:10)

#check how many entries were lost after all the cleaning:
nrow(clean_NCMP)-nrow(NCMP_data) #quite a lot! But this is just for testing purposes, raw data should need no cleaning (?)
(nrow(NCMP_data)-nrow(clean_NCMP))/nrow(NCMP_data)*100 # as above, in %

# regroup imd variable from deciles into quintiles (pair in twos)
# inefficient (?) nesting method - overwrite 2s with 1, 4s and 3s with 2, 5s and 6s with 3, 7s and 8s with 4, and 9s and 10s with 5
clean_NCMP$schoolindexofmultipledepriv <- ifelse(clean_NCMP$schoolindexofmultipledepriv==1, 1, 
                                                 ifelse(clean_NCMP$schoolindexofmultipledepriv==2, 1, 
                                                 ifelse(clean_NCMP$schoolindexofmultipledepriv==3, 2,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepri==4, 2,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepriv==5, 3,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepri==6, 3,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepriv==7, 4,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepri==8, 4,
                                                 ifelse(clean_NCMP$schoolindexofmultipledepriv==9, 5, 
                                                 ifelse(clean_NCMP$schoolindexofmultipledepri==10, 5, NA))))))))))

unique(clean_NCMP$schoolindexofmultipledepriv) # re-checking the range is as expected (1:5)



#main function, takes around 22 mins to run
test_NCMP<-anthro_prevalence(sex = clean_NCMP$GenderCode, 
                             age = clean_NCMP$AgeInMonths, 
                             is_age_in_month = T, 
                             weight = clean_NCMP$Weight, 
                             lenhei = clean_NCMP$Height, 
                             measure = "H",
                             wealthq = clean_NCMP$schoolindexofmultipledepriv)

#get relevant info only
rownames(test_NCMP)<-test_NCMP$Group #assigning the first column as rownames (makes is cleaner)
test_NCMP<-test_NCMP[,-1] #removing the duplicate column

#renaming the default deprivation variable to match dataset:
rownames(test_NCMP)[7:11] <- c("School IMD Q1: most deprived","School IMD Q2","School IMD Q3",
                               "School IMD Q4","School IMD Q5: least deprived")


test_NCMP<-na.omit(test_NCMP) #lots of NAs for the non-used function arguments, so getting rid of those.

#these are the columns of interest from the function output (based on the function documentation)
cols_to_keep<- c("HAZ_pop","HA_2_r", "WH2_r", "WH_2_r") 
final_result<-test_NCMP[, cols_to_keep] # keeping only the useful columns
#removing obsolete rows (we only have 1 age group, so deleting repetitions)
final_result <- final_result[-c(1,3,4), ]
#renaming the columns to more meaningful things
colnames(final_result)<-c("Sample size","HeightAge_-2SD", "WeightHeight_+2SD", "WeightHeight_-2SD")

#final result output. IMD is not available as an interaction with other variables
# sample sizes are very small, but this should not be the case for the unsuppressed data
write.csv(final_result, "../Target_2.2.csv")



# Things to look into for further disaggregations:
# raw NCMP data has urban/rural variable [PupilUrbanRuralIndicator], so could be plugged in the function as is!
# also [PupilRegionCode_ONS] could be fed into the gregion argument?

###############################################################################################
#
# The user must set the working directory to match the directory of this NCMP.R script
# setwd() # uncomment this line to set the directory of the downloded script,, + csv files, keeping the folder with the data one directory above
#
###############################################################################################

#install the package and load it in your R session:
install.packages("anthro",dependencies=TRUE, type="win.binary") #only need to do this once
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


#main function, takes around 10-15 mins to run
test_NCMP<-anthro_prevalence(sex = clean_NCMP$GenderCode, 
                             age = clean_NCMP$AgeInMonths, 
                             is_age_in_month = T, 
                             weight = clean_NCMP$Weight, 
                             lenhei = clean_NCMP$Height, 
                             measure = "H")

#get relevant info only
rownames(test_NCMP)<-test_NCMP$Group #assigning the first column as rownames (makes is cleaner)
test_NCMP<-test_NCMP[,-1] #removing the duplicate column
test_NCMP<-na.omit(test_NCMP) #lots of NAs for the non-used function arguments, so getting rid of those.

#these are the columns of interest from the function output (based on the documentation)
#(there will be more if we use the additional optional arguments)
cols_to_keep<- c("HA_2_r", "WH2_r", "WH_2_r") 
final_result<-test_NCMP[, cols_to_keep] # keeping only the useful columns
#renaming the columns to more meaningful things
colnames(final_result)<-c("HeightAge_-2SD", "WeightHeight_+2SD", "WeightHeight_-2SD")
write.csv(final_result, "../Target_2.2.csv")



# Things to look into for further disaggregations:
#typeres An optional integer or character vector representing a type of residence. Any
          #values are accepted, however, "Rural" or "Urban" are preferable for outputs
          #purposes.
#gregion An optional integer or character vector representing a geographical region.
#wealthq An optional integer or character vector representing wealth quintiles
          #where (1=poorest; 2,3,4,5=richest). 
          #All values can either be NA, or 1, 2, 3, 4, 5 or Q1, Q2, Q3,
          #Q4, Q5.
# recode IMD into wealthq variable?
# Code based on R v4.0.2
# basic tests, may need more cleaning up of suppressed values (large negatives)
# current cleaning removes -ves, but perhaps can keep values < 0.005th percentile because they are guaranteed to be < -2SD (?)
# use tidyR and dplyr for efficiency?


# reading the data from 2018-19 download of the zipped file from NHS Digital, after extracting
# assuming the data csv is one level up from the current working directory
NCMP_data<-read.csv("../ncmp_1819_final_non_disclosive_published.csv")
# some checks
head(NCMP_data)
min(NCMP_data$AgeInMonths)/12
max(NCMP_data$AgeInMonths)/12

# rounding the age in months variable (to match WHO tables better)
NCMP_data$AgeInMonths<-round(NCMP_data$AgeInMonths) # how do we round months??

# clean up suppressions from dataset (may need to be more sophisticated, here just removing all negatives)
# this will not be necessary when working with full data set
clean_NCMP <- NCMP_data[NCMP_data$Height > 0, ]
nrow(clean_NCMP)-nrow(NCMP_data) # N supressed height instances altogether

# retaining only age groups of interest (under 5s)
clean_NCMP <- clean_NCMP[clean_NCMP$AgeInMonths<=60, ] 

# loading the WHO standards (should be in the current working directory)
who_girls <- read.csv("./height-for-age-(z-scores)-f.csv", header = T)
who_boys <- read.csv("./height-for-age-(z-scores)-m.csv", header = T)


# 1=boys and 2=girls in NCMP data; creating separate tables for each:
NCMP_girls<-clean_NCMP[clean_NCMP$GenderCode==2, ]
NCMP_boys<-clean_NCMP[clean_NCMP$GenderCode==1, ]
# appending the -2SD cut-off from the WHO standards table to the NCMP tables
NCMP_girls$WHO_SD <- who_girls$min2.SD[match(NCMP_girls$AgeInMonths,who_girls$Months)] 
NCMP_boys$WHO_SD <- who_boys$min2.SD[match(NCMP_boys$AgeInMonths,who_boys$Months)] 


# test calculation of stunting prevalence for girls at 60 months:

age_60_f<-nrow(NCMP_girls[NCMP_girls$AgeInMonths==60, ])
deviations_60_f<-nrow(NCMP_girls[NCMP_girls$AgeInMonths==60 & NCMP_girls$Height < NCMP_girls$WHO_SD, ])
prevalence_60_f<-(deviations_60_f/age_60_f)*100 # % girls at age 5 under 2 SD from WHO median

# for comparison with pre-calculated SD from NCMP suppressed data (British standards)
# prevalence based on pre-calculated SD (a bit larger)
((nrow(NCMP_girls[NCMP_girls$AgeInMonths==60 & NCMP_girls$HeightZScore< -2, ]))/age_60_f)*100


# for boys
deviations_60_m<-nrow(NCMP_boys[NCMP_boys$AgeInMonths==60 & NCMP_boys$Height < NCMP_boys$WHO_SD, ])
prevalence_60_m<-(deviations_60_m/nrow(NCMP_boys[NCMP_boys$AgeInMonths==60, ]))*100
prevalence_60_m # % boys at age 5 under 2 SD from WHO median



########
#some test stuff (not relevant)
#deviations_60_f<-nrow(NCMP_girls[NCMP_girls$AgeInMonths==60 & NCMP_girls$Height<99.9, ])
#med_score<-median(NCMP_data[NCMP_data$AgeInMonths==60, 4])
#mad_score<-mad(NCMP_data[NCMP_data$AgeInMonths==60, 4],na.rm=T)
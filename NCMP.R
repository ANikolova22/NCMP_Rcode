#Code based on R v4.0.2
# basic tests, may need more cleaning up of suppressed values (large negatives)
# current cleaning removes -ves, but perhapsa can keep values < 0.005th percentile because they are guaranteed to be < -2SD (?)
# use tidyR and dplyr for efficiency?

NCMP_data<-read.csv("D:\\SDG general\\DAO stuff\\National Child Measurement Programme - England 2018-19 CSV File and Guidance\\ncmp_1819_final_non_disclosive_published.csv")
# some checks
head(NCMP_data)
min(NCMP_data$AgeInMonths)/12
max(NCMP_data$AgeInMonths)/12

# clean up suppressions from dataset (may need to be more sophisticated)
clean_NCMP <- NCMP_data[NCMP_data$Height > 0, ]
nrow(clean_NCMP)-nrow(NCMP_data) # N supressed height instances

# 1=boys and 2=girls

age_60<-nrow(clean_NCMP[clean_NCMP$AgeInMonths==60, ]) # (checked earlier, there were 27 suppressed instances for age 60 months across sex)
age_60_f <-nrow(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2, ])

# WHO standards (?):
head(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2 & clean_NCMP$Height<99.9, ])
deviations_60_f<-nrow(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2 & clean_NCMP$Height<99.9, ])
prevalence_60_f<-(deviations_60_f/age_60_f)*100 
prevalence_60_f # % girls at age 5 under 2 SD from WHO median

# for comparison with pre-calculated SD from NCMP:
head(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2 & clean_NCMP$HeightZScore< -2, ])
nrow(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2 & clean_NCMP$HeightZScore< -2, ])
# prevalence based on pre-calculated SD (a bit larger)
((nrow(clean_NCMP[clean_NCMP$AgeInMonths==60 & clean_NCMP$GenderCode==2 & clean_NCMP$HeightZScore< -2, ]))/age_60_f)*100




#####
#some test stuff (not relevant)
#med_score<-median(NCMP_data[NCMP_data$AgeInMonths==60, 4])
#mad_score<-mad(NCMP_data[NCMP_data$AgeInMonths==60, 4],na.rm=T)



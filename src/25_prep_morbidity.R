
# The aim of this code is to prepare the morbidity data
# for use in the simulation model

library(data.table)

# Read the person-specific single morbidity admission rates

# This is stored on the university's X drive 
# after having been processed into an aggregated form on the secure heta_study virtual machine

# Point to the location of the X drive
#root_dir <- "X:/"
root_dir <- "/Volumes/Shared/"

root <- "ScHARR/PR_HES_data_TA/projects/Tobacco hospitalisations/Person-specific_single-age_rates/Tobacco_person_specific_single_age_rates_"

keep_vars <- c("sex", "imd_quintile", "ageinyrs", "Cause", "Rate")

morb_rates <- rbindlist(list(
  fread(paste0(root_dir, root, "0304.csv"), select = keep_vars)[ , year := 2002],
  fread(paste0(root_dir, root, "0304.csv"), select = keep_vars)[ , year := 2003],
  fread(paste0(root_dir, root, "0405.csv"), select = keep_vars)[ , year := 2004],
  fread(paste0(root_dir, root, "0506.csv"), select = keep_vars)[ , year := 2005],
  fread(paste0(root_dir, root, "0607.csv"), select = keep_vars)[ , year := 2006],
  fread(paste0(root_dir, root, "0708.csv"), select = keep_vars)[ , year := 2007],
  fread(paste0(root_dir, root, "0809.csv"), select = keep_vars)[ , year := 2008],
  fread(paste0(root_dir, root, "0910.csv"), select = keep_vars)[ , year := 2009],
  fread(paste0(root_dir, root, "1011.csv"), select = keep_vars)[ , year := 2010],
  fread(paste0(root_dir, root, "1112.csv"), select = keep_vars)[ , year := 2011],
  fread(paste0(root_dir, root, "1213.csv"), select = keep_vars)[ , year := 2012],
  fread(paste0(root_dir, root, "1314.csv"), select = keep_vars)[ , year := 2013],
  fread(paste0(root_dir, root, "1415.csv"), select = keep_vars)[ , year := 2014],
  fread(paste0(root_dir, root, "1516.csv"), select = keep_vars)[ , year := 2015],
  fread(paste0(root_dir, root, "1617.csv"), select = keep_vars)[ , year := 2016]
))

# Make column names consistent with rest of analysis
setnames(morb_rates, c("ageinyrs", "Cause", "Rate"), c("age", "condition", "morb_rate"))

# Fill zeros where no observation

# Assuming no hospitalisation from 11 to 15

domain <- data.frame(expand.grid(
  sex = c("Male", "Female"),
  imd_quintile = c("1_least_deprived", "2", "3", "4", "5_most_deprived"),
  age = 11:89,
  condition = unique(tobalcepi::tobacco_relative_risks$condition),
  year = 2002:2016
))
setDT(domain)

tob_morb_data_cause <- merge(domain, morb_rates, all.x = T, all.y = F, by = c("sex", "age", "imd_quintile", "condition", "year"))

tob_morb_data_cause[is.na(morb_rate), morb_rate := 0]


# the ultimate aim is to forecast these rates by disease
# using the same methods as used to forecast mortality rates
# however, for now am just using rates up to 2016

saveRDS(morb_rates, "intermediate_data/morb_rates.rds")



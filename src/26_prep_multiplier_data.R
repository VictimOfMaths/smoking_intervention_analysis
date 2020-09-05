
# The aim of this code is to prepare the 'multiplier' data on how many times a year
# someone with a particular condition will be admitted to hospital

# Multipliers are taken from the year 2016 and are estimated from our hospital episode statistics data

keep_vars <- c("sex", "imd_quintile", "ageinyrs", "Cause", "av_multiplier")

# Point to the location of the X drive
#root_dir <- "X:/"
root_dir <- "/Volumes/Shared/"

multiplier_data <- fread(paste0(root_dir, 
                                "ScHARR/PR_HES_data_TA/projects/Tobacco hospitalisations/Person-specific_single-age_rates/Tobacco_person_specific_single_age_rates_1617.csv"),
                         select = keep_vars)

setnames(multiplier_data, c("ageinyrs", "Cause", "av_multiplier"), c("age", "condition", "multiplier"))

# Fill ones where no observation
domain <- data.frame(expand.grid(
  sex = c("Male", "Female"),
  imd_quintile = c("1_least_deprived", "2", "3", "4", "5_most_deprived"),
  age = 11:89,
  condition = unique(tobalcepi::tobacco_relative_risks$condition)
))
setDT(domain)

multiplier_data <- merge(domain, multiplier_data, all.x = T, all.y = F, by = c("sex", "age", "imd_quintile", "condition"))

multiplier_data[is.na(multiplier), multiplier := 1]

multiplier_data[ , age_cat := c("11-15", "16-17", "18-24", "25-34", "35-49", "50-64", "65-74", "75-89")[
  findInterval(age, c(-10, 16, 18, 25, 35, 50, 65, 75, 1000))]]

multiplier_data <- multiplier_data[ , .(multiplier = mean(multiplier)), by = c("sex", "age_cat", "imd_quintile", "condition")]

saveRDS(multiplier_data, "intermediate_data/multiplier_data.rds")

rm(multiplier_data, domain, keep_vars)
gc()


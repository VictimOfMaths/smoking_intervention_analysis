
# The aim of this code is to prepare the data on quality of life

# calculated using the qalyr package

library(data.table)

# Point to the location of the X drive
#root_dir <- "X:/"
root_dir <- "/Volumes/Shared/"

utility_data <- fread(paste0(root_dir, "ScHARR/PR_HES_data_TA/projects/Tobacco hospitalisations/Utilities/age-sex-condition-GP-utilities.csv"))

utility_data[ , sex := c("Male", "Female")[sex]]

# Oesophageal utility missing - for now give same as oral cavity
temp <- copy(utility_data[condition == "Oral_cavity"])

utility_data <- rbindlist(list(
  utility_data,
  copy(temp[ , condition := "Oesophageal_AC"]),
  copy(temp[ , condition := "Oesophageal_SCC"])
), use.names = T)


# Fill zeros where no observation
domain <- data.frame(expand.grid(
  sex = c("Male", "Female"),
  age = 11:89,
  condition = unique(tobalcepi::tobacco_relative_risks$condition)
))
setDT(domain)

utility_data <- merge(domain, utility_data, all.x = T, all.y = F, by = c("sex", "age", "condition"))

utility_data[ , age_cat := c("11-15", "16-17", "18-24", "25-34", "35-49", "50-64", "65-74", "75-89")[
  findInterval(age, c(-10, 16, 18, 25, 35, 50, 65, 75, 1000))]]

utility_data <- utility_data[ , .(
  GenPop_utility = mean(GenPop_utility),
  ConditionUtil = mean(ConditionUtil)
),
by = c("sex", "age_cat", "condition")]

saveRDS(utility_data, "intermediate_data/utility_data.rds")

rm(utility_data, domain, temp)
gc()

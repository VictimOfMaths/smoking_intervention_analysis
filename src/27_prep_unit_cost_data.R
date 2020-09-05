
# The aim of this code is to prepare the data on unit costs of a hospital admission

# Unit costs are calculated for the year 2016 from our Hospital Episode Statistics data

library(data.table)

# Point to the location of the X drive
#root_dir <- "X:/"
root_dir <- "/Volumes/Shared/"

# Read the unit costs
unit_cost_data <- fread(paste0(root_dir, "ScHARR/PR_HES_data_TA/projects/Tobacco hospitalisations/Unit cost/Unit_cost_admissions.csv"),
                        select = c("Cause", "age_cat", "imd_quintile", "sex", "unit_cost_admission"))

setnames(unit_cost_data, c("Cause", "unit_cost_admission"), c("condition", "unit_cost"))

unit_cost_data[ , sex := c("Male", "Female")[sex]]

# Fill zeros where no observation
domain <- data.frame(expand.grid(
  sex = c("Male", "Female"),
  imd_quintile = c("1_least_deprived", "2", "3", "4", "5_most_deprived"),
  age_cat = c("11-15", "16-17", "18-24", "25-34", "35-49", "50-64", "65-74", "75-89"),
  condition = unique(tobalcepi::tobacco_relative_risks$condition)
))
setDT(domain)

unit_cost_data <- merge(domain, unit_cost_data, all.x = T, all.y = F, by = c("sex", "age_cat", "imd_quintile", "condition"))

unit_cost_data[is.na(unit_cost), unit_cost := 0]

saveRDS(unit_cost_data, "intermediate_data/unit_cost_data.rds")

rm(unit_cost_data, domain)
gc()


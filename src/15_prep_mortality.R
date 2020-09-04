
# The aim of this code is to prepare the mortality data 
# for use in estimating smoking transition probabilities
# and for use in the simulation model

library(data.table)
library(mort.tools)
library(readxl)
library(ggplot2)
library(magrittr)

# Load the mortality data
# This is stored on the university's X drive 
# after having been processed into an aggregated form on the secure heta_study virtual machine

# Point to the location of the X drive
#root_dir <- "X:/"
root_dir <- "/Volumes/Shared/"

# Load the processed mortality data
#tob_mort_data <- fread(paste0(root_dir,
#      "ScHARR/PR_Mortality_data_TA/Code/model_inputs/Output/tob_death_rates_national_2019-05-06_mort.tools_1.0.0.csv"))

#saveRDS(tob_mort_data, "intermediate_data/tob_mort_data.rds")

tob_mort_data <- readRDS("intermediate_data/tob_mort_data.rds")

# Filter data
tob_mort_data <- tob_mort_data[age %in% 11:89 & !is.na(cause) , c("age",
                                                                  "sex",
                                                                  "imd_quintile",
                                                                  "year",
                                                                  "cause",
                                                                  "n_deaths",
                                                                  "pops"), with = F]

# For the estimation of smoking transition probabilities -----------------

# Collapse data to remove stratification by cause
tob_mort_data_trans <- tob_mort_data[, list(n_deaths = sum(n_deaths, na.rm = T),
                                         pops = unique(pops)), by = c("age", "sex", "imd_quintile", "year")]

# Recalculate the central death rates
tob_mort_data_trans[ , mx := n_deaths / pops]

# Remove variables not needed
tob_mort_data_trans[ , `:=`(n_deaths = NULL, pops = NULL)]

# Sort data
setorderv(tob_mort_data_trans, c("age", "year", "sex", "imd_quintile"), c(1, 1, 1, 1))

# Save the data for use in estimating smoking transition probabilities
saveRDS(tob_mort_data_trans, "intermediate_data/tob_mort_data_trans.rds")

rm(tob_mort_data_trans)
gc()

# For the esimulation model -----------------

# Conduct a forecast of cause-specific mortality rates

# Load the paramaters that control the smoothing and forecast methods for each cause
  # these parameters have been tuned for each cause so that they produce a plausible looking forecast
params <- read_xlsx("tools/tobacco mortality forecasting parameters.xlsx") %>% setDT

# Create mx column 
tob_mort_data[ , mx_cause := n_deaths / pops]

# Run the forecast
# This produces a cause-specific forecast and an all-cause forecast
# It writes a large folder of cause-specific diagnostics to the project folder
cforecast <- mort.tools::CombinedForecast(
  data = tob_mort_data,
  forecast_params = params,
  n_years = 2100 - 2016 # time horizon - jumpoff year
)

# Grab the cause-specific forecast
tob_mort_data_cause <- copy(cforecast$mx_data_cause)

# Change variable names
setnames(tob_mort_data_cause, c("cause", "mx"), c("condition", "mix"))

# Save the data for use in the simulation model
saveRDS(tob_mort_data_cause, "intermediate_data/tob_mort_data_cause.rds")

rm(tob_mort_data_cause)
gc()












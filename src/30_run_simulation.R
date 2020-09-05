
# The aim of this code is to run the simulation of 
# an intervention that adjusts the probability of quitting for some individuals

library(data.table)
library(stapmr)
library(tobalcepi)

# Load data ----------------

# Load the prepared data on tobacco consumption
survey_data <- readRDS("intermediate_data/HSE_2001_to_2016_tobacco_imputed.rds")

# Transition probabilities
init_data <- readRDS("intermediate_data/init_data.rds")
quit_data <- readRDS("intermediate_data/quit_data.rds")
relapse_data <- readRDS("intermediate_data/relapse_data.rds")

# Mortality data
mort_data <- readRDS("intermediate_data/tob_mort_data_cause.rds")

# Morbidity data
morb_data <- readRDS("intermediate_data/morb_rates.rds")

# Create adjusted quit probabilities

# Imagine an intervention that targets people aged 55-74 years old
# and was offered to all smokers of these ages who attend their GP practice 
# from 2010 to 2015
# 90% of eligible smokers were offered the intervention
# and 75% of smokers who were offered the intervenion accepted it
# The intervention caused a change to the probability that the smokers 
# attempted to quit and the probability that they were sucessful 
# in quitting for at least 6 months
# for example, smokers might have been encouraged to take a course
# of behavioural counselling and been given a free e-cigarette starter pack.
# This intervention made the smokers who received it twice as likely to 
# quit smoking for at least 6 months as they normally would have been

# Adjust the quit probabilities input into the model accordingly
quit_data_adj <- copy(quit_data)
quit_data_adj[age %in% 55:74 & year %in% 2010:2015, p_quit := (0.9 * 0.75 * 2 * p_quit) + ((1 - 0.9 * 0.75) * p_quit)]

#quit_data[age %in% 55:74 & year == 2010 & age == 55 & sex == "Male" & imd_quintile == "3"]
#quit_data_adj[age %in% 55:74 & year == 2010 & age == 55 & sex == "Male" & imd_quintile == "3"]


# Run simulation ----------------

testrun <- SmokeSim(
  survey_data = survey_data,
  init_data = init_data,
  quit_data = quit_data,
  relapse_data = relapse_data,
  mort_data = mort_data,
  morb_data = morb_data,
  baseline_year = 2002,
  baseline_sample_years = 2001:2003,
  time_horizon = 2050,
  trend_limit_morb = 2016,
  trend_limit_mort = 2016,
  trend_limit_smoke = 2016,
  pop_size = 2e5, # 200,000 people is about the minimum to reduce noise for a single run
  pop_data = stapmr::pop_counts,
  two_arms = TRUE,
  quit_data_adj = quit_data_adj,
  write_outputs = "output",
  label = "quit_intervention_test"
)

# Check the "output" folder for the saved model outputs
# these are forecast individual-level data on smoking
# and forecast mortality and morbidity rates












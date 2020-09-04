
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

# Create adjusted quit probabilities

# Imagine an intervention that targets people aged 55-74 years old
# the intervenion was offered to all smokers who attend their GP practice in 2010
# assume that 90% of smokers were offered the intervention
# assume that 75% of smokers who were offered the intervenion accepted it
# and that the intervenion made these smokers twice as likely to achieve quitting smoking for six months

quit_data_adj <- copy(quit_data)
quit_data_adj[age %in% 55:74 & year == 2010, p_quit := (0.9 * 0.75 * 2 * p_quit) + ((1 - 0.9 * 0.75) * p_quit)]

quit_data[age %in% 55:74 & year == 2010]
quit_data_adj[age %in% 55:74 & year == 2010]


# Run simulation ----------------

testrun <- SmokeSim_indivadj(
  survey_data = survey_data,
  init_data = init_data,
  quit_data = quit_data,
  relapse_data = relapse_data,
  mort_data = mort_data,
  baseline_year = 2002,
  baseline_sample_years = 2001:2003, # synth pop is drawn from 3 years
  time_horizon = 2030,
  pop_size = 2e5, # 200,000 people is about the minimum to reduce noise for a single run
  pop_data = stapmr::pop_counts,
  two_arms = TRUE,
  init_data_adj = init_data,
  quit_data_adj = quit_data_adj,
  seed_sim = NULL,
  pop_seed = 1,
  iter = NULL,
  write_outputs = "output",
  label = "quit_intervention_test"
)

# Check the "output" folder for the saved model outputs
# these are forecast individual-level data on smoking
# and forecast mortality rates












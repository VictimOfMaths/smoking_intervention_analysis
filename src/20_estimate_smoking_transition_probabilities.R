
# The aim of this code is to estimate the smoking transition probabilities
# needed for use in the model

library(smktrans)
library(data.table)

# Load the data
hse_data <- readRDS("intermediate_data/HSE_2001_to_2016_tobacco_imputed.rds")
tob_mort_data_cause <- readRDS("intermediate_data/tob_mort_data_cause.rds")

###############################
# Initiation

# Calculate the cumulative probabilities of starting to smoke for each cohort
init_data_raw <- smktrans::init_est(
  data = hse_data,
  strat_vars = c("sex", "imd_quintile")
)

# Estimate the trend in the proportion of people who have ever smoked
# in the age range 25-34
ever_smoke_data <- smktrans::ever_smoke(
  data = hse_data,
  time_horizon = 2200,
  num_bins = 7,
  model = "England"
)

# Adjust and forecast
init_data_adj <- init_adj(
  init_data = copy(init_data_raw),
  ever_smoke_data = copy(ever_smoke_data$predicted_values),
  ref_age = 30,
  cohorts = 1971:2100,
  period_start = 2001, period_end = 2016)

smk_init_data <- p_dense(data = copy(init_data_adj), cum_func_var = "p_ever_smoker_adj",
                         strat_vars = c("cohort", "sex", "imd_quintile"))

###############################
# Relapse

# Combine published estimates of long-term relapse with the Health Survey for England data to arrive at the expected values for relapse probabilities within defined subgroups.
relapse_data <- smktrans::prep_relapse(
  data = hse_data,
  hawkins_relapse = smktrans::hawkins_relapse,
  lowest_year = 2001,
  highest_year = 2016,
  youngest_age = 11
)

###############################
# Quit

# model trends in current, former and never smoking
trend_data <- smktrans::trend_fit(hse_data,
                                  max_iterations = 1e3,
                                  age_var = "age",
                                  year_var = "year",
                                  sex_var = "sex",
                                  smoker_state_var = "smk.state",
                                  imd_var = "imd_quintile",
                                  weight_var = "wt_int")

# Estimate the shape of the cohort survivorship functions
survivorship_data <- smktrans::prep_surv(
  mx_data_hmd = smktrans::hmd_data,
  mx_data_ons = smktrans::tob_mort_data
)

# Estimate age-specific probabilities of death by smoking status
mortality_data <- smktrans::smoke_surv(
  data = hse_data,
  diseases  = unique(tobalcepi::tobacco_relative_risks$condition),
  mx_data = tob_mort_data_cause
)

# Calculate quit probabilities
quit_data <- quit_est(
  dataq = hse_data,
  trend_dataq = trend_data,
  survivorship_dataq = survivorship_data,
  mortality_dataq = mortality_data$data_for_quit_ests,
  relapse_dataq = relapse_data$relapse_by_age_imd,
  initiation_dataq = smk_init_data,
  lowest_yearq = 2001,
  highest_yearq = 2016,
  youngest_yearq = 11
)

forecast_data <- quit_forecast(
  data = copy(quit_data),
  forecast_var = "p_quit",
  forecast_type = "continuing", # continuing or stationary
  cont_limit = 2030, # the year at which the forecast becomes stationary
  first_year = 2010, # the earliest year of data on which the forecast is based
  jump_off_year = 2015,
  time_horizon = 2030
)

# Save the estimated transition probabilities
saveRDS(smk_init_data, "intermediate_data/init_data.rds")
saveRDS(relapse_data$relapse_by_age_imd_timesincequit, "intermediate_data/relapse_data.rds")
saveRDS(forecast_data, "intermediate_data/quit_data.rds")



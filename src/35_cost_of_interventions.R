
# The aim of this code is to calculate the number of interventions given
# and the cumulative cost of interventions
# and to stratify this number by age, sex and IMD quintile

library(stapmr)
library(tobalcepi)
library(ggplot2)

# Load the simulated population
smoke_data1 <- ReadSim(root = "output/smk_data_", label = "quit_intervention_test", two_arms = TRUE)

# Summarise the smoking outcomes by population strata
smoke_stats <- SmkEffects(
  data = smoke_data1,
  strat_vars = c("year", "age", "sex", "imd_quintile"),
  two_arms = TRUE)

# To calculate the number of interventions given
# Select just the control arm
smoke_stats_control <- smoke_stats[arm == "control"]

# The characteristics of the intervention are described in the code file '30_run_simulation.R'

# 90% of smokers aged 55-74 years old were offered the intervention from 2010 to 2015
smoke_stats_control[ , offered_intervention := 0]
smoke_stats_control[year %in% 2010:2015 & age %in% 55:74, offered_intervention := n_smokers * 0.9]

# Total number of interventions given
sum(smoke_stats_control$offered_intervention)

# By IMD quintile
smoke_stats_control[ , .(n_offered = sum(offered_intervention)), by = c("imd_quintile")]

# Note that in this simple intervention scenario,
# the same smoker could have been offered the intervention once in each year

# 75% of smokers who were offered the intervenion accepted it
smoke_stats_control[ , accepted_intervention := offered_intervention * 0.75]

# Total number of interventions accepted
sum(smoke_stats_control$accepted_intervention)

# By IMD quintile
smoke_stats_control[ , .(n_accepted = sum(accepted_intervention)), by = c("imd_quintile")]

# By IMD quintile and year
n_accepted_year_imd <- smoke_stats_control[ , .(n_accepted = sum(accepted_intervention)), by = c("imd_quintile", "year")]

# Plot interventions accepted
png("output/interventions_accepted_year_imd.png", units="in", width=7, height=7, res=300)
ggplot(n_accepted_year_imd) +
  geom_line(aes(x = year, y = n_accepted, colour = imd_quintile), size = .4) +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  ylab("Number of interventions") +
  theme_minimal() +
  labs(title = "Number of interventions accepted",
       #subtitle = "", 
       caption = "The interventions was offered to 90% of smokers aged 55-74 years from 2010 to 2015.
       It was assumed to be accepted by 75% people smokers who were offered it.")
dev.off()


############################################################################
# Cost of intervention

# Assume that each intervention cost £30

# Calculate cost of the interventions that were accepted
smoke_stats_control[ , intervention_cost := 30 * accepted_intervention]

# Calculate the cumulative cost over years
# stratified by IMD quintile 
cost_year_imd <- smoke_stats_control[ , .(intervention_cost = sum(intervention_cost)), by = c("imd_quintile", "year")]

cost_year_imd[ , cum_intervention_cost := cumsum(intervention_cost), by = "imd_quintile"]

# Plot cumulative intervention cost
png("output/intervention_cost_year_imd.png", units="in", width=7, height=7, res=300)
ggplot(cost_year_imd) +
  geom_line(aes(x = year, y = cum_intervention_cost, colour = imd_quintile), size = .4) +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  ylab("Cost of interventions") +
  theme_minimal() +
  labs(title = "Cumulative cost of interventions",
       #subtitle = "", 
       caption = "The interventions was offered to 90% of smokers aged 55-74 years from 2010 to 2015.
       It was assumed to be accepted by 75% people smokers who were offered it.
       Each intervention assumed to cost £30.")
dev.off()


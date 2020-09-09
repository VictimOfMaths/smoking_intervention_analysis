
# The aim of the code is to estimate the effect of the intervention 
# on health costs and QALYs

library(data.table)
library(stapmr)
library(ggplot2)

# Utility data
utility_data <- readRDS("intermediate_data/utility_data.rds")

# Hospital care unit cost data
unit_cost_data <- readRDS("intermediate_data/unit_cost_data.rds")

# Hospital care multiplier data
multiplier_data <- readRDS("intermediate_data/multiplier_data.rds")

# Calculate health outcomes
# Match baseline year and population size to the values in the code that runs the simulation
health_data <- HealthCalc(path = "output/",
                          label = "quit_intervention_test",
                          two_arms = TRUE,
                          baseline_year = 2002,
                          baseline_population_size = 2e5,
                          multiplier_data = multiplier_data,
                          unit_cost_data = unit_cost_data,
                          utility_data = utility_data)

saveRDS(health_data, "output/health_data1.rds")

# QALY calc
qaly_year <- health_data$qaly_data[ , .(
  qaly_total = sum(qaly_total)
), by = c("year", "imd_quintile", "arm")]

# Reshape data
qaly_year <- dcast(qaly_year, year + imd_quintile ~ arm, value.var = "qaly_total")

# Calculate QALY difference between treatment and control arms
qaly_year[ , qaly_difference := (treatment - control)]

# Calculate cumulative discounted effect on QALYs

# Set a years-since-intervention counter
# based on the first year of the intervention being 2010
qaly_year <- qaly_year[year >= 2010, Year_since_int := year - 2010,]

# Calculate discounted QALY difference
qaly_year[year >= 2010 , Dis_qaly_difference := (treatment - control)*(1/((1+0.035)^Year_since_int)), ]

qaly_year[year >= 2010, Dis_Cum_qaly_difference := cumsum(Dis_qaly_difference), by = "imd_quintile"]

write.csv(qaly_year, "output/discounted_QALY_gain.csv", row.names = F)

# Plot intervention effects on QALYs
png("output/qaly_year_imd.png", units="in", width=7, height=7, res=300)
ggplot(qaly_year) +
  geom_line(aes(x = year, y = Dis_Cum_qaly_difference, colour = imd_quintile), size = .4) +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  ylab("QALYs") +
  theme_minimal() +
  labs(title = "Intervention effect on quality adjusted years of life",
       subtitle = "Calculated cumulatively", 
       caption = "The interventions was offered to 90% of smokers aged 55-74 years from 2010 to 2015.
       It was assumed to be accepted by 75% people smokers who were offered it.")
dev.off()


############################################################################
# Effect on the cost of hospital admissions

# Summarise outcomes for cost of hospital admissions
cost_year <- health_data$hosp_data[ , .(
  admission_cost = sum(admission_cost)
), by = c("year", "imd_quintile", "arm")]

# Reshape data
cost_year <- dcast(cost_year, year + imd_quintile ~ arm, value.var = "admission_cost")

# Calculate intervention effect on costs
cost_year[ , Cost_difference := (treatment - control)]

# Discounted cost savings
cost_year <- cost_year[year >= 2010, Year_since_int := year - 2010,]
cost_year[year >= 2010 , Dis_Cost_difference := (treatment - control)*(1/((1+0.035)^Year_since_int)), ]
cost_year[year >= 2010 , Dis_Cum_Cost_difference := cumsum(Dis_Cost_difference), by = "imd_quintile"]

write.csv(cost_year, "output/discounted_cost_difference.csv", row.names = F)

# Plot intervention effects on the costs of hospital admissions
png("output/hosp_costs_year_imd.png", units="in", width=7, height=7, res=300)
ggplot(cost_year) +
  geom_line(aes(x = year, y = Dis_Cum_Cost_difference / 1e6, colour = imd_quintile), size = .4) +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  ylab("Cost /£Million") +
  theme_minimal() +
  labs(title = "Intervention effect on cost of hospital admissions",
       subtitle = "Calculated cumulatively", 
       caption = "The interventions was offered to 90% of smokers aged 55-74 years from 2010 to 2015.
       It was assumed to be accepted by 75% people smokers who were offered it.")
dev.off()










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
), by = c("year", "arm")]

qaly_year <- dcast(qaly_year, year ~ arm, value.var = "qaly_total")

qaly_year <- qaly_year[ , Year_since_int := year - 2010,]

qaly_year[ , qaly_difference := (treatment - control)]

# Discounted cost savings
qaly_year[year > 2010 , Dis_qaly_difference := (treatment - control)*(1/((1+0.035)^Year_since_int)), ]

qaly_year[year > 2010 , Dis_Cum_qaly_difference := cumsum(Dis_qaly_difference)]

qaly_year <- qaly_year[ , .(year, Dis_Cum_qaly_difference)]

write.csv(qaly_year, "output/discounted_QALY_gain_sc1.csv", row.names = F)


# Cost calc
cost_year <- health_data$hosp_data[ , . (
  admission_cost = sum(admission_cost)
), by = c("year", "arm")]

cost_year <- dcast(cost_year, year ~ arm, value.var = "admission_cost")

cost_year <- cost_year[ , Year_since_int := year - 2010,]

cost_year[ , Cost_difference := (treatment - control)]

# Discounted cost savings
cost_year[year > 2010 , Dis_Cost_difference := (treatment - control)*(1/((1+0.035)^Year_since_int)), ]

cost_year[year > 2010 , Dis_Cum_Cost_difference := cumsum(Dis_Cost_difference)]

cost_year <- cost_year[ , .(year, Dis_Cum_Cost_difference)]

write.csv(cost_year, "output/discounted_cost_difference_sc1.csv", row.names = F)

#qaly_year <- fread("output/discounted_QALY_gain_sc1.csv")
#cost_year <- fread("output/discounted_cost_difference_sc1.csv")

CpQ1 <- merge(cost_year, qaly_year, by = c("year"))
CpQ1[is.na(CpQ1)] <- 0

write.csv(CpQ1, "output/CEP_sc1.csv", row.names = F)


ggplot(CpQ1) +
  geom_point(aes(x = Dis_Cum_qaly_difference, y = -Dis_Cum_Cost_difference /1e6)) +
  #geom_errorbar(aes(x = QALY, ymin = ymin/1000000, ymax = ymax/1000000, colour = Scenario), width = 200) +
  #geom_errorbarh(aes(y = Cost/1000000, xmin = xmin, xmax = xmax, colour = Scenario), height = 0.2) +
  theme_bw() +
  geom_abline(intercept = 0, slope = 2e4/1e6, linetype = 2) +
  geom_abline(intercept = 0, slope = 3e4/1e6, linetype = 3) +
#  ylim(0, 200) +
#  xlim(0, 2e4) +
  xlab("QALY") +
  ylab("Cost (£ million)")


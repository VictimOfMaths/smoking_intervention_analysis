
# The aim of this code is to make some basic plots to 
# view the effects of the intervention on mortality

library(data.table)
library(stapmr)
library(ggplot2)
library(mort.tools)

# Distribution effects by year and IMD quintile

mort_data <- MortCalc(
  path = "output/",
  label = "quit_intervention_test",
  two_arms = TRUE,
  baseline_year = 2002,
  baseline_population_size = 2e5,
  strat_vars = c("year", "age", "imd_quintile"))

mort_data[ , `:=`(n_deaths_diff = n_deaths_treatment - n_deaths_control,
                  yll_diff = yll_treatment - yll_control)]

saveRDS(mort_data, "output/mort_data_year_age_imd.rds")

# Years of life lost to smoking related diseases

yll_temp <- mort_data[ , .(yll_diff = sum(yll_diff, na.rm = T)), by = c("year", "imd_quintile")]

# Plot intervention effects on the years of life lost
png("output/yll_year_imd.png", units="in", width=7, height=7, res=300)
ggplot(yll_temp) +
  geom_line(aes(x = year, y = yll_diff, colour = imd_quintile), size = .4) +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  ylab("Years of life lost") +
  theme_minimal() +
  labs(title = "Intervention effect on years of life lost to death",
       #subtitle = "", 
       caption = "The interventions was offered to 90% of smokers aged 55-74 years from 2010 to 2015.
       It was assumed to be accepted by 75% people smokers who were offered it.")
dev.off()







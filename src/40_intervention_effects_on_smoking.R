
# The aim of this code is to make some basic plots to 
# view the effects of the intervention on smoking trajectories

library(data.table)
library(stapmr)
library(ggplot2)


# Policy effects by age-group and sex

smk_data <- ReadSim(root = "output/smk_data_", two_arms = TRUE, label = "quit_intervention_test")

smk_data[ , ageband := c("11-29", "30-54", "55-74", "75-89")[findInterval(age, c(-10, 30, 55, 75, 1000))]]

smoke_stats <- SmkEffects(
  data = smk_data,
  strat_vars = c("year", "ageband", "sex"),
  two_arms = TRUE)

smoke_stats$prevalence[year == 2016 & ageband == "55-74" & sex == "Male"]

saveRDS(smoke_stats, "output/smoke_prev_by_year_age_sex.rds")

png("output/intervention_effects_by_age_and_sex.png", units="in", width=12, height=4, res=300)
ggplot(smoke_stats$prevalence) +
  geom_line(aes(x = year, y = 100 * smk_prev, linetype = arm, colour = sex), size = .4) +
  scale_colour_manual(name = "Sex", values = c('#6600cc','#00cc99')) +
  facet_wrap(~ ageband, nrow = 1) +
  ylim(0, 30) + ylab("percentage smokers") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Intervention effects on percentage smokers",
       #subtitle = "", 
       caption = "The intervention was targeted to smokers aged 55-74 years.")
dev.off()









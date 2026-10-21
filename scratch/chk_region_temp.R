.libPaths(c("project/rlibs", .libPaths()))
suppressPackageStartupMessages(library(dplyr))
res <- readRDS("project/output/cf_results_v3.rds"); d2 <- res$rich$d2
d2 %>% group_by(Region) %>%
  summarise(n = n(), orig_temp = round(mean(orig_temp), 2), .groups = "drop") %>%
  arrange(desc(orig_temp)) %>% print()

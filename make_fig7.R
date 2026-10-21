## ============================================================================
##  Figure 7: compositional turnover decomposition
##  (a) ATE on colonisations / extinctions / total turnover / net richness
##  (b) Turnover ATE by years since transplant
##  (c) Colonisations vs extinctions per turf-year, by treatment
## ============================================================================
root <- if (dir.exists("project/output")) "project" else "."
if (dir.exists(file.path(root, "rlibs"))) .libPaths(c(file.path(root, "rlibs"), .libPaths()))
suppressPackageStartupMessages({ library(dplyr); library(ggplot2); library(patchwork) })

out <- file.path(root, "output")
ate  <- read.csv(file.path(out, "gainloss_ate.csv"))
ph   <- read.csv(file.path(out, "gainloss_turnover_phase.csv"))
pan  <- read.csv(file.path(out, "gainloss_panel.csv"))
net <- read.csv(file.path(out, "joint_ate.csv")) %>% filter(outcome == "net_richness")
a_net <- c(net$ate, net$se_joint)

d_a <- bind_rows(
  ate %>% mutate(outcome = recode(outcome,
    colonisations = "Colonisations", extinctions = "Extinctions",
    turnover = "Total turnover"),
    lab = sprintf("%.2f [%.2f, %.2f]", est, lo, hi)),
  data.frame(outcome = "Net richness change",
             est = a_net[1], se = a_net[2],
             lo = a_net[1] - 1.96 * a_net[2],
             hi = a_net[1] + 1.96 * a_net[2], p = NA,
             lab = sprintf("%.2f [%.2f, %.2f]", a_net[1],
                           a_net[1] - 1.96 * a_net[2],
                           a_net[1] + 1.96 * a_net[2]))
) %>% mutate(outcome = factor(outcome, levels = c("Colonisations", "Extinctions",
                                                  "Total turnover", "Net richness change")))

p_a <- ggplot(d_a, aes(est, outcome, colour = outcome == "Net richness change")) +
  geom_vline(xintercept = 0, linetype = 2, colour = "grey45") +
  geom_errorbar(aes(xmin = lo, xmax = hi), orientation = "y", width = 0.18, linewidth = 0.7) +
  geom_point(size = 3) +
  geom_text(aes(label = lab), hjust = -0.12, vjust = -0.85, size = 3.1, show.legend = FALSE) +
  scale_colour_manual(values = c("FALSE" = "#185FA5", "TRUE" = "grey35"), guide = "none") +
  scale_x_continuous(limits = c(-1.6, 6.4)) +
  labs(x = "ATE (species per turf-year)", y = NULL,
       title = "(a) Colonisation and extinction",
       subtitle = "AIPW, turf-clustered 95% CI") +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(size = 9.5, face = "bold"),
        plot.subtitle = element_text(size = 8.5, colour = "grey35"))

ph <- ph %>% filter(phase %in% c("year 1", "year 2", "year >= 3"))
ph$phase <- factor(ph$phase, levels = c("year 1", "year 2", "year >= 3"),
                   labels = c("1", "2", ">= 3"))
p_b <- ggplot(ph, aes(phase, est)) +
  geom_hline(yintercept = 0, linetype = 2, colour = "grey45") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.12, colour = "#185FA5", linewidth = 0.7) +
  geom_point(size = 3, colour = "#185FA5") +
  geom_line(aes(group = 1), colour = "#185FA5", linewidth = 0.5, alpha = 0.6) +
  geom_text(aes(y = lo, label = sprintf("n=%d", n)), vjust = 1.7, size = 3, colour = "grey35") +
  labs(x = "Years since transplant", y = "ATE on total turnover",
       title = "(b) Turnover vs time since transplant",
       subtitle = "Separate forests per phase") +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(size = 9.5, face = "bold"),
        plot.subtitle = element_text(size = 8.5, colour = "grey35"))

p_c <- ggplot(pan, aes(gains, losses, colour = factor(W_bin))) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, colour = "grey45") +
  geom_jitter(width = 0.28, height = 0.28, alpha = 0.32, size = 0.9) +
  scale_colour_manual(values = c("0" = "grey55", "1" = "#C0392B"),
                      labels = c("0" = "In-situ control", "1" = "Transplanted warm"),
                      name = NULL) +
  labs(x = "Colonisations", y = "Extinctions",
       title = "(c) Gains vs losses per turf-year",
       subtitle = "Dashed line: gains = losses (no net change)") +
  theme_bw(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.background = element_rect(fill = "white", colour = NA),
        plot.title = element_text(size = 9.5, face = "bold"),
        plot.subtitle = element_text(size = 8.5, colour = "grey35"))

p <- (p_a | p_b) / p_c + plot_layout(heights = c(1, 1.05))
ggsave(file.path(out, "fig7_turnover.png"), type = "cairo", p, width = 170, height = 150,
       units = "mm", dpi = 300, bg = "white")
ggsave(file.path(out, "fig7_turnover.pdf"), device = cairo_pdf, p, width = 170, height = 150,
       units = "mm", bg = "white")
cat("wrote fig7_turnover.png + .pdf\n")

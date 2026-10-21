# =====================================================================
# make_fig8.R - Fig 8: directionality of compositional change
#   (a) distribution of conditional effects on dCTI
#   (b) dCTI by event-time phase
#   (c) thermal directionality of turnover (colonist STP - extinct STP)
#   (d) how much of the imposed warming the community actually tracks
# Depends on: analysis_cti.R
# =====================================================================
root <- if (dir.exists("project/output")) "project" else "."
if (dir.exists(file.path(root, "rlibs"))) .libPaths(c(file.path(root, "rlibs"), .libPaths()))
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(patchwork)
})

out <- file.path(root, "output")
ana <- read.csv(file.path(out, "cti_panel.csv"))
ate_cti <- read.csv(file.path(out, "cti_ate.csv")) %>% filter(outcome == "dCTI_degC")

POS <- "#2C6E9B"; NEG <- "#B4462F"; WARM <- "#C4622D"; COOL <- "#2C6E9B"; GREY <- "grey35"
theme_pub <- theme_classic(base_size = 9) +
  theme(
    axis.text  = element_text(colour = "grey20", size = 8),
    axis.title = element_text(size = 9),
    plot.title = element_text(size = 9.5, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 7.6, colour = "grey30"),
    strip.background = element_blank(),
    strip.text = element_text(size = 8.5, face = "bold"),
    legend.key.size = unit(0.8, "lines"),
    legend.text = element_text(size = 7.4),
    legend.title = element_text(size = 8),
    panel.grid.major = element_line(colour = "grey93", linewidth = 0.22),
    plot.margin = margin(4, 6, 4, 4)
  )
theme_set(theme_pub)

save_both <- function(plot, name, w, h) {
  ggsave(file.path(out, paste0(name, ".png")), type = "cairo", plot,
         width = w, height = h, dpi = 300, bg = "white")
  ggsave(file.path(out, paste0(name, ".pdf")), device = cairo_pdf, plot,
         width = w, height = h, bg = "white")
  cat("saved", name, "(.png + .pdf)\n")
}

## ---------------------------------------------------------------- (a) Observed change distribution; descriptive only
dd <- read.csv(file.path(out, "cti_panel.csv"))
p8a <- ggplot(tibble(v = dd$d_cti_ok), aes(v)) +
  geom_histogram(bins = 38, fill = POS, colour = "white", linewidth = 0.12, alpha = 0.9) +
  geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  labs(x = "Observed change in community temperature index (deg C)",
       y = "Turf-years",
       title = "(a) Observed CTI change (descriptive)",
       subtitle = sprintf("%d eligible turf-years", sum(!is.na(dd$d_cti_ok))))

## ---------------------------------------------------------------- (b) event-time
ph <- read.csv(file.path(out, "cti_phase.csv"))
ph$phase <- factor(ph$phase, levels = c("year 1", "year 2", "year >= 3", "year >= 2"))
ph$sig   <- ifelse(ph$lo > 0 | ph$hi < 0, "sig", "ns")

p8b <- ggplot(ph, aes(x = phase, y = est)) +
  geom_hline(yintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_col(aes(fill = sig), width = 0.62, alpha = 0.85) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.14, linewidth = 0.5) +
  geom_text(aes(label = sprintf("n=%d", n)), y = -0.045, size = 2.4, colour = "grey35") +
  scale_fill_manual(values = c(sig = NEG, ns = "grey78"), guide = "none") +
  coord_cartesian(ylim = c(-0.09, 0.25)) +
  labs(x = "Years since transplant", y = "dCTI (deg C)",
       title = "(b) Phase-specific CTI estimates",
       subtitle = "ATE by phase, 95% CI; filled = CI excludes zero")

## ---------------------------------------------------------------- (c) thermal directionality
dp <- ana %>%
  filter(!is.na(stp_gain), !is.na(stp_loss)) %>%
  mutate(grp = factor(ifelse(W_bin == 1, "Warm", "LocalControl"),
                      levels = c("LocalControl", "Warm")))

p8c <- ggplot(dp, aes(x = grp, y = d_stp, fill = grp)) +
  geom_hline(yintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_violin(alpha = 0.35, colour = NA, width = 0.85, scale = "width") +
  geom_boxplot(width = 0.16, outlier.shape = NA, alpha = 0.95, linewidth = 0.35) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 1.9,
               fill = "white", colour = "grey10", stroke = 0.4) +
  scale_fill_manual(values = c(LocalControl = COOL, Warm = WARM), guide = "none") +
  coord_cartesian(ylim = c(-2.6, 2.6)) +
  labs(x = NULL, y = "STP of colonisers - STP of extinctions (deg C)",
       title = "(c) Which species replace which",
       subtitle = sprintf("n = %d turf-years; diamond = mean", nrow(dp)))

## ---------------------------------------------------------------- (d) tracking ratio
tr <- read.csv(file.path(out, "cti_tracking.csv"))
lo <- 100 * ate_cti$lo / tr$dose_degC
hi <- 100 * ate_cti$hi / tr$dose_degC
td <- tibble(
  what = factor(c("Imposed\nwarming", "Tracked by\ncomposition"),
                levels = c("Imposed\nwarming", "Tracked by\ncomposition")),
  pct  = c(100, tr$tracking_pct),
  lo   = c(NA, lo), hi = c(NA, hi)
)

p8d <- ggplot(td, aes(x = what, y = pct)) +
  geom_col(fill = c("grey72", NEG), width = 0.55, alpha = 0.9) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.12, linewidth = 0.5, na.rm = TRUE) +
  geom_text(aes(label = ifelse(pct == 100, "100%", sprintf("%.1f%%", pct))),
            vjust = -0.9, size = 3.1, fontface = "bold") +
  scale_y_continuous(limits = c(-5, 115), expand = c(0, 0),
                     breaks = c(0, 25, 50, 75, 100)) +
  labs(x = NULL, y = "Share of the imposed shift (%)",
       title = "(d) CTI shift relative to warming",
       subtitle = sprintf("%.1f%% [%.2f, %.1f]; CI conditional on fixed mean dose",
                          tr$tracking_pct, lo, hi))

## ---------------------------------------------------------------- assemble
fig8 <- (p8a | p8b) / (p8c | p8d) +
  plot_annotation(tag_levels = NULL) &
  theme(plot.margin = margin(4, 7, 4, 4))

save_both(fig8, "fig8_thermal_directionality", 6.7, 5.6)
cat("\nFig 8 done.\n")

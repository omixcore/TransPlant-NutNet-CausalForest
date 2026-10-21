# =====================================================================
# make_figures.R — Main manuscript figures (GCB dimensions, 300 dpi, 170 mm double-column width)
# Fig 1 Study system and design | Fig 2 Average effects and placebo | Fig 3 Who benefits
# Fig 4 Regional effect reversals | Fig 5 Time since transplantation | Fig 6 NutNet positive control
# Prerequisite: run analysis_causal_forest_v3.R / analysis_event_time.R / analysis_nutnet.R
# =====================================================================
root <- if (dir.exists("project/output")) "project" else "."
if (dir.exists(file.path(root, "rlibs"))) .libPaths(c(file.path(root, "rlibs"), .libPaths()))
suppressPackageStartupMessages({
  library(grf); library(dplyr); library(tidyr); library(ggplot2)
  library(patchwork); library(maps)
})

set.seed(20261021)
out <- file.path(root, "output")
res <- readRDS(file.path(out, "cf_results_v3.rds"))
rich <- res$rich; lrr <- res$lrr
d2 <- rich$d2
d2$CATE_rich <- predict(rich$cf)$predictions
d2$CATE_lrr  <- predict(lrr$cf)$predictions

X_names <- c("orig_temp", "orig_prec", "d_temp_y", "d_prec_y", "d_elev",
             "base_rich", "cwm_SLA", "cwm_Hgt", "cwm_Npc", "prop_woody", "Year")

## ---- Shared theme and palette ----
POS <- "#2C6E9B"; NEG <- "#B4462F"; WARM <- "#C4622D"; COOL <- "#2C6E9B"; GREY <- "grey35"
theme_pub <- theme_classic(base_size = 9) +
  theme(
    axis.text  = element_text(colour = "grey20", size = 8),
    axis.title = element_text(size = 9),
    plot.title = element_text(size = 9.5, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 8, colour = "grey30"),
    strip.background = element_blank(),
    strip.text = element_text(size = 9, face = "bold"),
    legend.key.size = unit(0.9, "lines"),
    legend.text = element_text(size = 7.5),
    legend.title = element_text(size = 8),
    panel.grid.major = element_line(colour = "grey92", linewidth = 0.25),
    plot.margin = margin(4, 6, 4, 4)
  )
theme_set(theme_pub)
## ---- Export PNG (300 dpi) and vector PDF (cairo_pdf)----
save_both <- function(plot, name, w, h) {
  ggsave(file.path(out, paste0(name, ".png")), type = "cairo", plot,
         width = w, height = h, dpi = 300, bg = "white")
  ggsave(file.path(out, paste0(name, ".pdf")), device = cairo_pdf, plot,
         width = w, height = h, bg = "white")
  cat("saved", name, "(.png + .pdf)\n")
}

W2 <- 6.7   # single-column/full-page width (inches)

## ===================== Fig 1: Study system and design =====================
## (a) Site map
e <- new.env(); load(file.path(root, "data", "TransPlantNetwork.RData"), envir = e)
cl <- as.data.frame(e$climdata)
site_xy <- cl %>% group_by(Region = gradient, destSiteID) %>%
  summarise(lat = mean(lat, na.rm = TRUE), lon = mean(lon, na.rm = TRUE), .groups = "drop") %>%
  filter(!is.na(lat), !is.na(lon))

reg_xy <- d2 %>%
  left_join(site_xy, by = c("Region", "destSiteID")) %>%
  group_by(Region) %>%
  summarise(lat = mean(lat, na.rm = TRUE), lon = mean(lon, na.rm = TRUE),
            n = n(), cate = mean(CATE_rich), .groups = "drop") %>%
  filter(!is.na(lat))
write.csv(reg_xy, file.path(out, "fig1_region_summary.csv"), row.names = FALSE)

world <- map_data("world")
p1a <- ggplot() +
  geom_polygon(data = world, aes(long, lat, group = group),
               fill = "grey94", colour = "grey80", linewidth = 0.2) +
  geom_point(data = reg_xy, aes(lon, lat, size = n, fill = cate),
             shape = 21, colour = "grey20", stroke = 0.35) +
  scale_fill_gradient2(low = NEG, mid = "grey96", high = POS, midpoint = 0,
                       name = "Mean CATE\n(species)") +
  scale_size_area(max_size = 6, name = "Turf-years", breaks = c(50, 150, 250)) +
  coord_quickmap(xlim = c(-125, 120), ylim = c(24, 74)) +
  labs(title = "(a) TransPlant network",
       subtitle = sprintf("%d regions, %d countries, %d turf-years", nrow(reg_xy),
                          length(unique(sub("_.*", "", reg_xy$Region))), nrow(d2)),
       caption = "Map lines delineate study areas and do not necessarily depict accepted national boundaries") +
  theme(axis.line = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), panel.grid = element_blank(),
        legend.position = "right", legend.box = "vertical")

## (b) Design diagram
p1b <- ggplot() +
  annotate("segment", x = 0.4, y = 9.1, xend = 9.6, yend = 2.2,
           colour = "grey55", linewidth = 0.7) +
  annotate("text", x = 2.0, y = 9.6, label = "Cold source\n(upslope)", size = 2.6,
           colour = "grey25", lineheight = 0.9) +
  annotate("text", x = 8.6, y = 1.5, label = "Warm destination\n(downslope)", size = 2.6,
           colour = "grey25", lineheight = 0.9) +
  annotate("point", x = 1.7, y = 8.2, size = 3, colour = COOL) +
  annotate("point", x = 8.3, y = 3.1, size = 3, colour = COOL, shape = 1, stroke = 1) +
  annotate("point", x = 8.3, y = 3.1, size = 1.8, colour = WARM) +
  annotate("curve", x = 2.0, y = 7.9, xend = 7.9, yend = 3.4, curvature = 0.28,
           arrow = arrow(length = unit(2.2, "mm"), type = "closed"),
           colour = WARM, linewidth = 0.75) +
  annotate("text", x = 4.4, y = 7.0, label = "Warm treatment\ntransplant downslope\n(median +2.0 deg C)",
           size = 2.5, colour = WARM, lineheight = 0.92) +
  annotate("text", x = 8.35, y = 4.5, label = "LocalControl\nin situ", size = 2.5,
           colour = COOL, lineheight = 0.92) +
  coord_cartesian(xlim = c(0, 10), ylim = c(0.4, 10.2), clip = "off") +
  theme_void() +
  labs(title = "(b) Paired design")

## (c) Dose distribution
dose <- d2 %>% filter(W_bin == 1)
p1c <- ggplot(dose, aes(W_cont)) +
  geom_histogram(bins = 30, fill = WARM, colour = "white", linewidth = 0.15, alpha = .9) +
  geom_vline(xintercept = median(dose$W_cont), linetype = 2, colour = "grey20", linewidth = 0.4) +
  annotate("text", x = median(dose$W_cont) + 0.25, y = Inf,
           label = sprintf("median %.1f deg C", median(dose$W_cont)),
           hjust = 0, vjust = 1.6, size = 2.6, colour = "grey20") +
  labs(title = "(c) Warming dose", x = "Destination - source temperature (deg C)",
       y = "Treated turf-years")

p1 <- p1a / (p1b | p1c) + plot_layout(heights = c(1.55, 1))
save_both(p1, "fig1_study_system", W2, 5.9)

## ===================== Fig 2: Average effects and placebo =====================
mk_hist <- function(x, fill, xlab, ttl) {
  ggplot(tibble(v = x), aes(v)) +
    geom_histogram(bins = 42, fill = fill, colour = "white", linewidth = 0.12, alpha = .9) +
    geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
    labs(x = xlab, y = "Turf-years", title = ttl)
}
p2a <- mk_hist(d2$CATE_rich, POS, "CATE: species richness change", "(a) Richness")
p2b <- mk_hist(d2$CATE_lrr,  "#5B8C7B", "CATE: cover log response ratio", "(b) Cover")

pl <- res$placebo
p2c <- ggplot(tibble(v = pl), aes(v)) +
  geom_histogram(bins = 26, fill = "grey72", colour = "white", linewidth = 0.15) +
  geom_vline(xintercept = mean(pl), linetype = 3, colour = "grey30", linewidth = 0.5) +
  geom_vline(xintercept = rich$ate[1], colour = NEG, linewidth = 0.9) +
  annotate("text", x = rich$ate[1], y = Inf, label = sprintf("observed\n%.2f", rich$ate[1]),
           hjust = 1.15, vjust = 1.4, size = 2.6, colour = NEG, lineheight = 0.9) +
  labs(x = "ATE under permuted treatment", y = "Permutations",
       title = "(c) Placebo (200 perms)",
       subtitle = sprintf("null: %.2f +/- %.2f; p = %.3f",
                          mean(pl), sd(pl), (1 + sum(pl >= rich$ate[1])) / (length(pl) + 1)))

p2 <- p2a + p2b + p2c + plot_layout(widths = c(1, 1, 1))
save_both(p2, "fig2_average_and_placebo", W2, 2.5)

## ===================== Fig 3: Who benefits (heterogeneity) =====================
bin_cate <- function(xv, lab, ttl, colour = POS) {
  tb <- d2 %>% transmute(x = .data[[xv]], y = CATE_rich) %>%
    mutate(bin = ntile(x, 7)) %>%
    group_by(bin) %>%
    summarise(x = mean(x), m = mean(y), n = n(), .groups = "drop")
  ggplot(tb, aes(x, m)) +
    geom_hline(yintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
    geom_line(colour = colour, linewidth = 0.45) +
    geom_point(aes(size = n), colour = colour) +
    scale_size_area(max_size = 3.6, guide = "none") +
    labs(x = lab, y = "CATE (species richness)", title = ttl)
}
p3a <- bin_cate("orig_temp", "Source temperature (deg C)", "(a) Source climate")
p3b <- bin_cate("base_rich", "Baseline species richness", "(b) Baseline diversity")

## (c) Observed covariate support only: binned predictions
Xm <- as.matrix(d2[, X_names])
mu <- colMeans(Xm, na.rm = TRUE)
sdv <- apply(Xm, 2, sd, na.rm = TRUE); sdv[sdv == 0] <- 1
grid <- d2 %>% mutate(temp_bin = ntile(orig_temp, 12), rich_bin = ntile(base_rich, 12)) %>%
  group_by(temp_bin, rich_bin) %>%
  summarise(orig_temp = mean(orig_temp), base_rich = mean(base_rich),
            CATE = mean(CATE_rich), n = n(), .groups = "drop") %>%
  filter(n >= 4)
p3c <- ggplot(grid, aes(orig_temp, base_rich, fill = CATE, size = n)) +
  geom_point(shape = 21, colour = "grey35") +
  scale_fill_gradient2(low = NEG, mid = "grey96", high = POS, midpoint = 0,
                       name = "CATE\n(species)") +
  scale_size_area(max_size = 5, name = "Turf-years") +
  labs(x = "Source temperature (deg C)", y = "Baseline species richness",
       title = "(c) Observed covariate cells",
       subtitle = "Mean predicted CATE; cells with n >= 4")
p3 <- p3a + p3b + p3c + plot_layout(widths = c(1, 1, 1.15))
save_both(p3, "fig3_who_benefits", W2, 2.6)

## ===================== Fig 4: Regional effect reversals =====================
run_region <- function(r) {
  s <- d2 %>% filter(Region == r)
  if (n_distinct(s$turf_key) < 8) return(NULL)
  X <- scale(as.matrix(s[, X_names])); X[is.na(X)] <- 0
  cf <- causal_forest(X, s$Y_rich, s$W_bin, W.hat = s$W_hat_site,
                      clusters = as.numeric(factor(s$turf_key)),
                      num.trees = 2000, min.node.size = 5)
  a <- average_treatment_effect(cf)
  tibble(Region = r, n = nrow(s), turfs = n_distinct(s$turf_key),
         ate = a[1], se = a[2],
         lo = a[1] - 1.96 * a[2], hi = a[1] + 1.96 * a[2])
}
reg <- bind_rows(lapply(sort(unique(d2$Region)), run_region))
write.csv(reg, file.path(out, "fig4_region_ate.csv"), row.names = FALSE)

p4 <- ggplot(reg, aes(ate, reorder(sub("_", " ", Region), ate))) +
  geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_errorbar(aes(xmin = lo, xmax = hi), orientation = "y", width = 0, colour = "grey40", linewidth = 0.5) +
  geom_point(aes(colour = ate > 0, size = turfs)) +
  scale_colour_manual(values = c(`TRUE` = POS, `FALSE` = NEG), guide = "none") +
  scale_size_area(max_size = 4, name = "Turfs", breaks = c(10, 25, 50)) +
  labs(x = "Region-specific ATE (species richness)", y = NULL,
       title = "Regional point estimates vary",
       subtitle = "Forests re-fitted within region; bars = 95% CI")
save_both(p4, "fig4_region_ate", 4.6, 3.0)

## ===================== Fig 5: Time since transplantation =====================
d2 <- d2 %>% mutate(ys = Year - base_year)

ev <- d2 %>% filter(ys >= 1) %>% group_by(ys) %>%
  summarise(m = mean(CATE_rich), n = n(), .groups = "drop") %>%
  filter(n >= 20)
p5a <- ggplot(ev, aes(ys, m)) +
  geom_hline(yintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_line(colour = POS, linewidth = 0.7) +
  geom_point(colour = POS, size = 1.8) +
  labs(x = "Years since transplant", y = "Estimated CATE (richness)",
       title = "(a) Event-time profile", subtitle = "bins with n >= 20 turf-years")

## Re-estimate by phase (as in manuscript Table 3)
run_phase <- function(sub, lab) {
  X <- scale(as.matrix(sub[, X_names])); X[is.na(X)] <- 0
  cf <- causal_forest(X, sub$Y_rich, sub$W_bin, W.hat = sub$W_hat_site,
                      clusters = as.numeric(factor(sub$turf_key)),
                      num.trees = 4000, min.node.size = 5)
  a <- average_treatment_effect(cf)
  tibble(phase = lab, n = nrow(sub), ate = a[1], se = a[2],
         lo = a[1] - 1.96 * a[2], hi = a[1] + 1.96 * a[2])
}
ph <- bind_rows(
  run_phase(d2 %>% filter(ys == 1), "Year 1"),
  run_phase(d2 %>% filter(ys == 2), "Year 2"),
  run_phase(d2 %>% filter(ys >= 3), "Year >= 3")
) %>% mutate(phase = factor(phase, levels = c("Year 1", "Year 2", "Year >= 3")))
write.csv(ph, file.path(out, "fig5_phase_ate.csv"), row.names = FALSE)

p5b <- ggplot(ph, aes(ate, phase)) +
  geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_errorbar(aes(xmin = lo, xmax = hi), orientation = "y", width = 0,
                colour = "grey40", linewidth = 0.55) +
  geom_point(aes(colour = ate > 0), size = 2.6) +
  geom_text(aes(label = paste0("n = ", n)), vjust = -1.1, size = 2.5, colour = "grey35") +
  scale_colour_manual(values = c(`TRUE` = POS, `FALSE` = NEG), guide = "none") +
  labs(x = "ATE (species richness)", y = NULL,
       title = "(b) Phase-specific ATEs", subtitle = "separate forests per phase")

p5 <- p5a + p5b + plot_layout(widths = c(1.25, 1))
save_both(p5, "fig5_event_time", W2, 2.6)

## ===================== Fig 6: NutNet positive control =====================
nn <- read.csv(file.path(out, "nutnet_plot_cate.csv"))
ctrl <- nn %>% filter(trt == "Ctrl")
nutnet_log <- readLines(file.path(out, "run_log_nutnet.txt"), warn = FALSE)
n_line <- grep("^n=[0-9]+ sites=[0-9]+ treated=[0-9]+", nutnet_log, value = TRUE)
n_val <- as.integer(regmatches(n_line, gregexpr("[0-9]+", n_line))[[1]])
stopifnot(length(n_val) == 3, n_val[1] == sum(nn$trt %in% c("Ctrl", "N", "NP")))
n_ate <- grep("^ATE = ", nutnet_log, value = TRUE)
p_ate <- grep("^P-only ATE = ", nutnet_log, value = TRUE)
stopifnot(length(n_ate) == 1, length(p_ate) == 1)
n_est <- as.numeric(regmatches(n_ate, gregexpr("[0-9]+\\.[0-9]+", n_ate))[[1]][1:2])
p_est <- as.numeric(regmatches(p_ate, gregexpr("[0-9]+\\.[0-9]+", p_ate))[[1]][1:2])
res_n <- bind_rows(
  tibble(term = "N or NP added", est = n_est[1], se = n_est[2]),
  tibble(term = "P added", est = p_est[1], se = p_est[2])
) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se,
             term = factor(term, levels = c("P added", "N or NP added")))

p6a <- ggplot(res_n, aes(est, term)) +
  geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_errorbar(aes(xmin = lo, xmax = hi), orientation = "y", width = 0, colour = "grey40", linewidth = 0.55) +
  geom_point(size = 2.6, colour = "#3D6E4E") +
  labs(x = "ATE on ANPP (g m^-2)", y = NULL, title = "(a) Fertilization effects",
       subtitle = sprintf("%d sites; N/NP: %d treated, %d controls", n_val[2], n_val[3], n_val[1]-n_val[3]))

## Site-level CATE (N/NP)
site_c <- nn %>% filter(trt != "Ctrl") %>%
  group_by(site) %>% summarise(cate = mean(CATE), n = n(), .groups = "drop")
p6b <- ggplot(site_c, aes(cate, reorder(site, cate))) +
  geom_vline(xintercept = 0, linetype = 2, colour = GREY, linewidth = 0.45) +
  geom_vline(xintercept = n_est[1], linetype = 3, colour = "#3D6E4E", linewidth = 0.5) +
  geom_point(aes(size = n), colour = "#3D6E4E") +
  scale_size_area(max_size = 3.2, guide = "none") +
  labs(x = "Mean plot-level CATE (g/m2)", y = NULL,
       title = "(b) Site-level heterogeneity",
       subtitle = "dotted line = pooled ATE")

p6 <- p6a + p6b + plot_layout(widths = c(1, 1))
save_both(p6, "fig6_nutnet", W2, 2.5)

cat("== Figures complete ==\n")
for (f in c("fig1_study_system.png", "fig2_average_and_placebo.png", "fig3_who_benefits.png",
            "fig4_region_ate.png", "fig5_event_time.png", "fig6_nutnet.png"))
  cat(sprintf("  %-28s %s\n", f, file.exists(file.path(out, f))))

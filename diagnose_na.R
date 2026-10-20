.libPaths(c("project/rlibs", .libPaths()))
library(dplyr)
source_local <- function(f) source(f)
# 复用主管线的数据构建部分（到第 5 步），此处快速重建
e <- new.env()
load("project/data/TransPlantNetwork.RData", envir = e)
dat <- as.data.frame(e$dat); clim <- as.data.frame(e$climdata); traits <- as.data.frame(e$alltraits)

gs <- clim %>% filter(month %in% 5:9)
normals <- gs %>% filter(year <= 2010) %>%
  group_by(destSiteID, var) %>%
  summarise(temp_normal = mean(value[var == "temperature"], na.rm=TRUE),
            prec_normal = sum(value[var=="precipitation"], na.rm=TRUE)/length(unique(year[var=="precipitation"])),
            .groups="drop") %>%
  group_by(destSiteID) %>% summarise(across(c(temp_normal, prec_normal), ~mean(.x, na.rm=TRUE)), .groups="drop")
yearly <- gs %>% group_by(destSiteID, var, year) %>%
  summarise(v = mean(value, na.rm=TRUE), .groups="drop") %>%
  tidyr::pivot_wider(names_from = var, values_from = v) %>%
  rename(temp_y = temperature, prec_y = precipitation)
site_elev <- clim %>% group_by(destSiteID) %>% summarise(elev = mean(unique(elevation), na.rm=TRUE), .groups="drop")

panel0 <- dat %>% group_by(Region, originSiteID, destSiteID, Treatment, turfID, Year) %>%
  summarise(richness = n_distinct(SpeciesName), tot_cover = sum(Cover, na.rm=TRUE), .groups="drop") %>%
  group_by(turfID) %>% arrange(Year, .by_group=TRUE) %>% mutate(base_year = first(Year)) %>% ungroup()
base_tbl <- panel0 %>% filter(Year == base_year) %>%
  dplyr::select(Region, originSiteID, destSiteID, turfID, base_rich=richness, base_cover=tot_cover)
panel <- panel0 %>% left_join(base_tbl, by=c("Region","originSiteID","destSiteID","turfID")) %>%
  mutate(Y_rich = richness - base_rich, Y_lrr = log((tot_cover+1)/(base_cover+1)))

sp_traits <- traits %>%
  mutate(SLA=coalesce(SLA_cm2_g,TSLA_cm2_g), Hgt=coalesce(Plant_Veg_Height_cm,TPlant_Veg_Height_cm),
         Npc=coalesce(N_percent,TN_percent),
         woody_num=if(is.character(woodiness)) as.numeric(!grepl("non",woodiness,ignore.case=TRUE)) else as.numeric(woodiness)) %>%
  dplyr::select(Region, destSiteID, SpeciesName, SLA, Hgt, Npc, woody_num) %>%
  group_by(Region, destSiteID, SpeciesName) %>% summarise(across(everything(), ~mean(.x,na.rm=TRUE)), .groups="drop")
base_rows <- panel %>% filter(Year==base_year) %>% dplyr::select(Region, originSiteID, destSiteID, turfID, base_year)
sp_base <- dat %>% left_join(base_rows, by=c("Region","originSiteID","destSiteID","turfID")) %>%
  filter(Year==base_year) %>% left_join(sp_traits, by=c("Region","destSiteID","SpeciesName"))
cwm <- sp_base %>% group_by(Region, destSiteID, turfID) %>%
  summarise(cwm_SLA=weighted.mean(SLA,Cover,na.rm=TRUE), cwm_Hgt=weighted.mean(Hgt,Cover,na.rm=TRUE),
            cwm_Npc=weighted.mean(Npc,Cover,na.rm=TRUE), prop_woody=weighted.mean(woody_num,Cover,na.rm=TRUE), .groups="drop")

ana <- panel %>%
  left_join(normals, by=c("originSiteID"="destSiteID")) %>% rename(orig_temp=temp_normal, orig_prec=prec_normal) %>%
  left_join(normals, by=c("destSiteID"="destSiteID")) %>% rename(dest_temp=temp_normal, dest_prec=prec_normal) %>%
  left_join(rename(yearly, orig_temp_y=temp_y, orig_prec_y=prec_y), by=c("originSiteID"="destSiteID","Year"="year")) %>%
  left_join(rename(yearly, dest_temp_y=temp_y, dest_prec_y=prec_y), by=c("destSiteID"="destSiteID","Year"="year")) %>%
  left_join(site_elev, by=c("originSiteID"="destSiteID")) %>% rename(orig_elev=elev) %>%
  left_join(site_elev, by=c("destSiteID"="destSiteID")) %>% rename(dest_elev=elev) %>%
  left_join(cwm, by=c("Region","destSiteID","turfID")) %>%
  mutate(W_bin=as.integer(Treatment=="Warm"), W_cont=dest_temp-orig_temp,
         d_temp_y=coalesce(dest_temp_y-orig_temp, dest_temp-orig_temp),
         d_prec_y=coalesce(dest_prec_y-orig_prec,0), d_elev=dest_elev-orig_elev)

cat("\n### 各协变量 NA 数（n=", nrow(ana), "）###\n")
for (v in c("orig_temp","orig_prec","d_temp_y","d_prec_y","d_elev","base_rich","cwm_SLA","cwm_Hgt","cwm_Npc","prop_woody")) {
  cat(sprintf("%-12s NA=%d\n", v, sum(is.na(ana[[v]]))))
}

X1 <- c("orig_temp","orig_prec","d_temp_y","d_prec_y","d_elev","Year")
X2 <- c("orig_temp","orig_prec","d_temp_y","d_prec_y","d_elev","base_rich","cwm_SLA","cwm_Hgt","cwm_Npc","prop_woody","Year")
X3 <- c("orig_temp","orig_prec","d_temp_y","d_prec_y","d_elev","base_rich","Year")

run <- function(Xn, lab, target = "all") {
  d2 <- ana %>% tidyr::drop_na(all_of(c("Y_rich", Xn, "turfID")))
  X <- scale(as.matrix(d2[, Xn]))
  cf <- grf::causal_forest(X, d2$Y_rich, d2$W_bin, clusters=as.numeric(factor(d2$turfID)), num.trees=4000)
  ate <- grf::average_treatment_effect(cf, target.sample = target)
  cat(sprintf("\n[%s | target=%s] n=%d clusters=%d ATE=%.3f SE=%.3f CI=[%.3f, %.3f]\n",
      lab, target, nrow(d2), length(unique(d2$turfID)), ate[1], ate[2], ate[1]-1.96*ate[2], ate[1]+1.96*ate[2]))
}
run(X1, "仅气候协变量")
run(X3, "气候+基线丰富度")
run(X2, "全协变量")
run(X3, "气候+基线丰富度(overlap)", "overlap")

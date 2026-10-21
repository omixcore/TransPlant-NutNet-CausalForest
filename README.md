# TransPlant-NutNet-CausalForest

公共数据库 + 因果森林（Generalized Random Forests）：全球变化实验网络中植物群落响应的**异质性因果效应**分析。

## 核心问题

主流 meta 分析只能给"平均效应"。本项目用因果森林估计逐样方的条件平均处理效应（CATE），回答：

1. 哪些基线条件下的群落会发生效应**方向翻转**（变暖下物种减少；施肥下多样性损失最重）？
2. 效应异质性由基线气候主导还是由群落功能性状主导？
3. 能否基于 CATE 绘制保护决策用的"风险地图"？

## 数据（全部公开）

| 网络 | 来源 | 规模（分析样本） |
|---|---|---|
| TransPlant（群落移栽/变暖） | OSF: doi.org/10.17605/OSF.IO/9874T | 20 区域 / 9 国、41 站、225 turf、1171 turf-年（2007–2022） |
| NutNet e247（养分添加） | EDI: knb-lter-cdr.692.1（CC-BY） | 9 站 × 4 处理，90 plot 观测 |
| NutNet 核心（扩展中） | nutnet.org 数据协议 | ~200 站 |

辅助：TRY 性状库、WorldClim、SoilGrids。

## 快速复现

```r
# 依赖 R >= 4.5；grf/dplyr/ggplot2/patchwork
source("analysis_causal_forest_v3.R")   # 网络 1：TransPlant 全样本（v3，修复 turfID 跨区重号）
source("analysis_event_time.R")         # 事件时间分析（首年冲击 vs 建立期）
source("analysis_nutnet.R")             # 网络 2：NutNet e247 阳性对照
```

数据文件请按上述 DOI 下载后放入 `data/`（.gitignore 已排除大文件）。

## 主结果（v3，详见手稿）

- **TransPlant 全样本**（n=1171）：平均效应 +0.65 种 [−0.39, 1.69]（不显著），盖度 LRR −0.02 → 物种更替
- **事件时间**：首年 −1.22 → 第 2 年起 +1.03～+1.08：移栽首年冲击掩盖持续增温响应，混年份平均会稀释真实效应
- **异质性**：来源地越冷增益越大（BLP −1.36，p=0.08）；**基线多样性越高增益越小**（−1.74，p=0.051，最丰富样方 CATE 转负）；区域间效应方向翻转（DE_Susalps −4.0 vs NO_Ulvhaugen +3.4）
- **安慰剂**（站点内置换 200 次）：p=0.065；NutNet 阳性对照：施氮 +124 g/m² [76, 173]
- 证据强度：方向一致但尚未定论；正式版需 NutNet 全球版（数据协议）+ 完整稳健性包

## 文件

- `analysis_causal_forest_v3.R` — TransPlant 主管线（全样本：复合键修复版，v2 只剩 5 区域的 bug 已修）
- `analysis_event_time.R` — 事件时间分析 + 区域亚组
- `analysis_nutnet.R` — NutNet 管线原型
- `manuscript_GCB_draft_v0.1.md` — **投稿手稿初稿**（GCB 格式，含表格/图注/中文摘要）
- `diagnose_na.R` / `inspect_*.R` — 数据诊断脚本
- `A角度_原型分析报告.md` — 原型结果报告（v2，已被 v3 部分取代）
- `研究计划书_双网络因果森林.md` — 正式研究计划与投稿策略
- `output/` — 图表、CATE 表、运行日志

## 引用方法

- Athey, Tibshirani & Wager (2019) *Annals of Statistics*; Wager & Athey (2018) *JASA*
- 数据：TransPlant Network (OSF 9874T)；Seabloom et al. 2020 (EDI edi.599.1)；knb-lter-cdr.692.1 (e247)

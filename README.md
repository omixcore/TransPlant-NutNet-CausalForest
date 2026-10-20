# TransPlant-NutNet-CausalForest

公共数据库 + 因果森林（Generalized Random Forests）：全球变化实验网络中植物群落响应的**异质性因果效应**分析。

## 核心问题

主流 meta 分析只能给"平均效应"。本项目用因果森林估计逐样方的条件平均处理效应（CATE），回答：

1. 哪些基线条件下的群落会发生效应**方向翻转**（变暖下物种减少；施肥下多样性损失最重）？
2. 效应异质性由基线气候主导还是由群落功能性状主导？
3. 能否基于 CATE 绘制保护决策用的"风险地图"？

## 数据（全部公开）

| 网络 | 来源 | 规模 |
|---|---|---|
| TransPlant（群落移栽/变暖） | OSF: doi.org/10.17605/OSF.IO/9874T | 21 站、157 turf、888 turf-年 |
| NutNet e247（养分添加） | EDI: knb-lter-cdr.692.1（CC-BY） | 9 站 × 4 处理 × 3 区组 |
| NutNet 核心（扩展中） | nutnet.org 数据协议 | ~200 站 |

辅助：TRY 性状库、WorldClim、SoilGrids。

## 快速复现

```r
# 依赖 R >= 4.5；grf/dplyr/ggplot2/patchwork
source("analysis_causal_forest_v2.R")   # 网络 1：TransPlant
source("analysis_nutnet.R")             # 网络 2：NutNet e247
```

数据文件请按上述 DOI 下载后放入 `data/`（.gitignore 已排除大文件）。

## 原型结果（详见报告）

- **TransPlant 全样本**（n=872）：移栽变暖使丰富度净增 +0.84 物种 [−0.03, 1.71]；**来源地越冷增益越大**（−2.30/°C，p<0.001），**基线多样性越高增益越小**（−2.40，p<0.01）；盖度不变 → 物种更替机制；安慰剂检验通过
- **NutNet e247**（n=90）：施氮使 ANPP 增 +124 g/m² [76, 173]，与已发表量级一致
- 连续处理：每 +1°C 移栽温差 → +0.55 个物种

## 文件

- `analysis_causal_forest_v2.R` — TransPlant 主管线（分类匹配修复版）
- `analysis_nutnet.R` — NutNet 管线原型
- `diagnose_na.R` / `inspect_*.R` — 数据诊断脚本
- `A角度_原型分析报告.md` — 原型结果报告
- `研究计划书_双网络因果森林.md` — 正式研究计划与投稿策略
- `output/` — 图表、CATE 表、运行日志

## 引用方法

- Athey & Wager (2019) *Econometrics Journal*; Wager & Athey (2018) *JASA*
- 数据：Vandvik et al. (TransPlant Network)；Borer et al. 2020 / Seabloom et al. 2020 (NutNet)

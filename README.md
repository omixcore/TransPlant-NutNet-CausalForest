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
source("analysis_gainloss.R")           # 定殖/灭绝分解（核心结果）
source("analysis_cti.R")                # 组成变化的方向性：CTI/STP/性状位移（新增）
source("analysis_robustness.R")         # 稳健性包：LOO/聚类/超参数/FDR/overlap
source("make_figures.R"); source("make_fig7.R"); source("make_fig8.R")   # 八张主图，PNG + 矢量 PDF
```

数据文件请按上述 DOI 下载后放入 `data/`（.gitignore 已排除大文件）。

## 主结果（v3，详见手稿 v0.2）

- **周转分解（核心）**：增温同时提高定殖 +1.12（p=0.017）与灭绝 +0.91（p=0.003），总周转 **+2.02 种/turf-年（p<0.001）**，第 2 年起 +2.44（p<0.001）→ **组成快速更替而净丰富度不变**
- **方向性（新增，Fig 8）**：群落温度指数 CTI 仅升 +0.071 °C [0.000, 0.141]，而施加增温平均 +2.4 °C → **群落只追踪了 2.9%（CI 0.0–5.9%）**，且第 3 年起才升至 0.11 °C（p=0.030）；换入物种比换出物种平均暖 0.16 °C（p=0.070）；叶片氮 −0.60 mg/g（p=0.037）。六个方向性结局 BH 校正后最小 p=0.14，属提示性证据
- **TransPlant 全样本**（n=1171）：平均效应 +0.65 种 [−0.39, 1.69]（不显著），盖度 LRR −0.02
- **事件时间**：首年 −1.22 → 第 2 年起 +1.03～+1.08
- **异质性**：来源地越冷增益越大（BLP −1.36，p=0.08）；**基线多样性越高增益越小**（−1.74，p=0.051）；区域间效应方向翻转（DE_Susalps −4.0 vs NO_Ulvhaugen +3.4）
- **安慰剂**：p=0.065；NutNet 阳性对照：施氮 +124 g/m² [76, 173]
- **稳健性**：LOO 区域 ATE 0.21–0.82、超参数 0.56–0.65、站点聚类 SE 0.71（MDE 2.0 种）、26/41 站点双臂；BLP 经 BH 校正后无调节变量存活（最小 p=0.30）

## 文件

- `analysis_causal_forest_v3.R` — TransPlant 主管线（全样本：复合键修复版，v2 只剩 5 区域的 bug 已修）
- `analysis_event_time.R` — 事件时间分析 + 区域亚组
- `analysis_nutnet.R` — NutNet 管线原型
- `analysis_gainloss.R` — 定殖/灭绝/周转分解
- `analysis_cti.R` — 组成变化的方向性：CTI（群落温度指数）、STP（物种温度偏好，留一站法防循环）、ΔSTP（更替方向性）、CWM 性状位移（新增）
- `analysis_robustness.R` — 稳健性与报告标准（FDR、LOO、MDE、overlap、sessionInfo）
- `make_figures.R` / `make_fig7.R` / `make_fig8.R` — 八张主图（PNG 300 dpi + **矢量 PDF**，字体嵌入）
- `manuscript_GCB_draft_v0.2.md` — **投稿手稿 v0.2**（正文 ~6,600 词，71 条参考文献，6 表 8 图，含中文摘要）
- `Supplementary_Information.md` — 补充材料（表 S1–S9）
- `build_references.py` / `finalize_references.py` — 文献元数据 Crossref 核对与格式化
- `投稿缺口审计.md` — 投稿前缺口清单（哪些已补、哪些需作者行动）
- `diagnose_na.R` / `inspect_*.R` — 数据诊断脚本
- `A角度_原型分析报告.md` — 原型结果报告（v2，已被 v3 部分取代）
- `研究计划书_双网络因果森林.md` — 正式研究计划与投稿策略
- `output/` — 图表（`.png` + `.pdf`）、CATE 表、运行日志、`session_info.txt`、`references.json`

## 引用方法

- Athey, Tibshirani & Wager (2019) *Annals of Statistics*; Wager & Athey (2018) *JASA*
- 数据：TransPlant Network (OSF 9874T)；Seabloom et al. 2020 (EDI edi.599.1)；knb-lter-cdr.692.1 (e247)

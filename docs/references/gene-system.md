# 培育系统设计文档 v2.0（植物学重构版）

> 基于真实花卉杂交生物学研究的全面重设计
> 更新日期：2026-05-22

---

## 目录

1. [当前问题分析](#1-当前问题分析)
2. [植物学研究结论](#2-植物学研究结论)
3. [新版设计原则](#3-新版设计原则)
4. [群组结构重构](#4-群组结构重构)
5. [植物学兼容度体系](#5-植物学兼容度体系)
6. [花色遗传（不完全显性模型）](#6-花色遗传不完全显性模型)
7. [渐进发现系统（Discovery Tree）](#7-渐进发现系统discovery-tree)
8. [培育概率系统（加权候选池）](#8-培育概率系统加权候选池)
9. [稀有变异与突变](#9-稀有变异与突变)
10. [初始种子重新设计](#10-初始种子重新设计)
11. [完整培育流程](#11-完整培育流程)
12. [实现计划](#12-实现计划)
13. [图鉴种子解锁系统](#13-图鉴种子解锁系统)

---

## 1. 当前问题分析

### 1.1 玩家反馈核心问题

> "玩来玩去还是初始的几个种类" → **品种分布严重不均，新种获取概率极低**
> "感觉现在非常的无聊" → **每次培育结果缺乏惊喜，策略深度为零**

### 1.2 根因

| 问题 | 表现 | 根因 |
|------|------|------|
| 初始种子太少 | 仅 3 种(rose_red, daisy_white, tulip_yellow) | 分布在 3 个不同组 → 杂交判定永远不触发 |
| 杂交触发率低 | 70% 退回亲本A | `CROSS_BREED_CHANCE = 27%`，且 `rare(3%) + cross_breed(27%) = 30%` → 70% 进混色通道 |
| 同品种混色无感 | 仅颜色变化，品种不变 | `mix_color` 品种从未通过系统逻辑生成，全靠硬编码初始数据 |
| 杂交表不覆盖 | 31 条路径，但需要同组才能触发 | 杂交判定前提 `same_group` → 初始三者不同组 |
| 渐进发现无机制 | `gradual` 品种从未通过游戏生成 | `discover_method = "gradual"` 没有任何系统逻辑支撑 |
| 无策略深度 | 任意两花培育结果一样 | 没有"尝试特定组合→预期特定结果"的反馈 |

### 1.3 数据印证

```
品种按 discover_method 分布（83种）：
  initial:        3  (3.6%)   ← 仅这3种是玩家能得到的起点
  mix_color:     18  (21.7%)  ← 代码无法生成，需手动给
  cross_breed:   25  (30.1%)  ← 31条表，但初始3非同组
  gradual:       21  (25.3%)  ← 代码无任何逻辑
  expansion_gift: 1  (1.2%)   ← 仅多肉观音莲
  rare_mutation: 15  (18.1%)  ← 3%触发率
```

**结论：游戏实际可玩内容 = 3 种初始花 + 极低概率的 15 种稀有花。其余 65 种（78%）玩家永远无法自然获取。**

---

## 2. 植物学研究结论

### 2.1 真实杂交生物学核心原则

| 规则 | 说明 | 游戏映射 |
|------|------|---------|
| **同种可育** | 同种内不同个体/变种杂交成功率最高 | 同品种繁殖→颜色变异+少量突变 |
| **同属可杂交** | 同属不同种（如 Rosa gallica × Rosa chinensis）最常见园艺杂交 | 同属→最高杂交成功率 |
| **同科可能** | 同科不同属（如 Rosa × Prunus 同Rosaceae）极罕见但存在 | 同组→中等成功率 |
| **跨科极难** | 不同科无法杂交（蔷薇×山茶不可能） | 跨组→极低成功率，需特殊道具 |
| **种间隔离** | 亲缘越远，杂交成功率指数下降 | 用兼容度等级量化 |
| **胚胎败育** | 远缘杂交虽可能受精，但胚往往无法发育 | 用"成功率"体现 |

### 2.2 当前游戏群的植物学准确性

#### ROSE 群（蔷薇系）

| 品种 | 真实科 | 真实属 | 和Rosa同科? | 备注 |
|------|--------|--------|------------|------|
| 玫瑰/月季 | **Rosaceae** 蔷薇科 | *Rosa* 蔷薇属 | ✅ 本尊 | |
| 樱花 | **Rosaceae** 蔷薇科 | *Prunus* 李属 | ✅ 同科不同属 | |
| 梅花 | **Rosaceae** 蔷薇科 | *Prunus* 李属 | ✅ 同科不同属 | |
| 桃花 | **Rosaceae** 蔷薇科 | *Prunus* 李属 | ✅ 同科不同属 | |
| 牡丹 | **Paeoniaceae** 芍药科 | *Paeonia* 芍药属 | ❌ | |
| 海棠 | **Begoniaceae** 秋海棠科 | *Begonia* 秋海棠属 | ❌ | |
| 栀子花 | **Rubiaceae** 茜草科 | *Gardenia* 栀子属 | ❌ | |
| 山茶花 | **Theaceae** 山茶科 | *Camellia* 山茶属 | ❌ | |
| 杜鹃花 | **Ericaceae** 杜鹃花科 | *Rhododendron* 杜鹃属 | ❌ | |
| 银莲花 | **Ranunculaceae** 毛茛科 | *Anemone* 银莲花属 | ❌ | |
| 木槿花 | **Malvaceae** 锦葵科 | *Hibiscus* 木槿属 | ❌ | |

#### LILY 群（百合系）

| 品种 | 真实科 | 和 Lilium 同科? |
|------|--------|----------------|
| 百合 | **Liliaceae** 百合科 | ✅ 本尊 |
| 郁金香 | **Liliaceae** 百合科 | ✅ 同科 |
| 风信子 | **Asparagaceae** 天门冬科 | ❌ |
| 荷花 | **Nelumbonaceae** 莲科 | ❌ |
| 睡莲 | **Nymphaeaceae** 睡莲科 | ❌ 且和百合差4个目 |
| 剑兰 | **Iridaceae** 鸢尾科 | ❌ |
| 水仙 | **Amaryllidaceae** 石蒜科 | ❌ |
| 美人蕉 | **Cannaceae** 美人蕉科 | ❌ |
| 花毛茛 | **Ranunculaceae** 毛茛科 | ❌ |
| 香豌豆 | **Fabaceae** 豆科 | ❌ |

#### DAISY 群（菊系）

| 品种 | 真实科 | 和 Bellis 同科? |
|------|--------|----------------|
| 雏菊 | **Asteraceae** 菊科 | ✅ 本尊 |
| 向日葵 | **Asteraceae** 菊科 | ✅ 同科 |
| 波斯菊 | **Asteraceae** 菊科 | ✅ 同科 |
| 菊花 | **Asteraceae** 菊科 | ✅ 同科 |
| 大丽花 | **Asteraceae** 菊科 | ✅ 同科 |
| 百日菊 | **Asteraceae** 菊科 | ✅ 同科 |
| 万寿菊 | **Asteraceae** 菊科 | ✅ 同科 |
| 格桑花 | **Asteraceae** 菊科 | ✅ 同科（秋英属） |
| 康乃馨 | **Caryophyllaceae** 石竹科 | ❌ |
| 满天星 | **Caryophyllaceae** 石竹科 | ❌ |
| 虞美人 | **Papaveraceae** 罂粟科 | ❌ |
| 绣球花 | **Hydrangeaceae** 绣球花科 | ❌ |

#### ORCHID 群（兰系）

| 品种 | 真实科 | 和 Orchidaceae 同科? |
|------|--------|---------------------|
| 蝴蝶兰 | **Orchidaceae** 兰科 | ✅ 本尊 |
| 薰衣草 | **Lamiaceae** 唇形科 | ❌ |
| 紫罗兰 | **Violaceae** 堇菜科 | ❌ |
| 茉莉花 | **Oleaceae** 木犀科 | ❌ |
| 紫藤 | **Fabaceae** 豆科 | ❌ |
| 鸢尾花 | **Iridaceae** 鸢尾科 | ❌ |
| 玉兰 | **Magnoliaceae** 木兰科 | ❌ |
| 牵牛花 | **Convolvulaceae** 旋花科 | ❌ |
| 勿忘我 | **Boraginaceae** 紫草科 | ❌ |

#### SUCCULENT / CACTUS 群

| 品种 | 真实科 | 同科? |
|------|--------|-------|
| 观音莲(Echeveria) | **Crassulaceae** 景天科 | ✅ |
| 熊童子(Cotyledon) | **Crassulaceae** 景天科 | ✅ 可杂交 |
| 玉龙观音 | **Crassulaceae** 景天科 | ✅ |
| 玉露(Haworthia) | **Asphodelaceae** 阿福花科 | ❌ 不同科 |
| 仙人掌 | **Cactaceae** 仙人掌科 | ❌ 完全不同 |
| 星兜(Astrophytum) | **Cactaceae** 仙人掌科 | ❌ |
| 佛珠(Senecio) | **Asteraceae** 菊科 | ❌ 居然是菊科的! |

---

## 3. 新版设计原则

### 3.1 核心目标

1. **83+ 品种全部可达** — 每种花都有至少一条自然培育路径
2. **每次培育都有意义** — 不同组合产生可预期的不同结果
3. **渐进发现的成就感** — 游戏前/中/后期持续有新种解锁
4. **现实感 + 惊喜感** — 基于真实植物学，同时保留稀有变异的浪漫
5. **策略深度** — 玩家可以"追求"特定品种，而不是纯随机

### 3.2 四大设计方向（玩家提出）

```
① 初始种子丰富化
   └→ 每组以真实原生种为起点，从3种→14+种

② 颜色匹配系统
   └→ 特定颜色组合触发特定品种（取代纯随机混色）

③ 渐进发现树
   └→ 每种花都需要特定的"前置条件"才能被发现

④ 杂交概率系统
   └→ 不同亲缘关系→不同概率结果池（加权候选池）
```

---

## 4. 群组结构重构

### 4.1 六个组保留，内部增加植物学分科

不改变现有的 `BreedingGroup` 枚举（保持代码兼容），但每个品种新增 `family_id` 字段记录真实植物学分类：

```gdscript
enum PlantFamily {
	ROSACEAE,      # 蔷薇科
	PAEONIACEAE,   # 芍药科
	BEGONIACEAE,   # 秋海棠科
	RUBIACEAE,     # 茜草科
	THEACEAE,      # 山茶科
	ERICACEAE,     # 杜鹃花科
	RANUNCULACEAE, # 毛茛科
	MALVACEAE,     # 锦葵科
	LILIACEAE,     # 百合科
	ASPARAGACEAE,  # 天门冬科
	NELUMBONACEAE, # 莲科
	NYMPHAEACEAE,  # 睡莲科
	IRIDACEAE,     # 鸢尾科
	AMARYLLIDACEAE,# 石蒜科
	CANNACEAE,     # 美人蕉科
	FABACEAE,      # 豆科
	ASTERACEAE,    # 菊科
	CARYOPHYLLACEAE,# 石竹科
	PAPAVERACEAE,  # 罂粟科
	HYDRANGEACEAE, # 绣球花科
	ORCHIDACEAE,   # 兰科
	LAMIACEAE,     # 唇形科
	VIOLACEAE,     # 堇菜科
	OLEACEAE,      # 木犀科
	MAGNOLIACEAE,  # 木兰科
	CONVOLVULACEAE,# 旋花科
	BORAGINACEAE,  # 紫草科
	CRASSULACEAE,  # 景天科
	ASPHODELACEAE, # 阿福花科
	CACTACEAE,     # 仙人掌科
}
```

### 4.2 每组核心科 vs 外围科

组之间不再是"同组可杂交/不同组不可"的二元关系，而是**连续兼容度**：

```
ROSE 群 = 蔷薇科(Rosaceae)为核心 + 游戏内归类的其他科为外围
LILY 群 = 百合科(Liliaceae) + Asparagaceae 等为核心
DAISY 群 = 菊科(Asteraceae)为核心
ORCHID 群 = 兰科(Orchidaceae)为核心
SUCCULENT 群 = 景天科(Crassulaceae)为核心
CACTUS 群 = 仙人掌科(Cactaceae)为核心
```

### 4.3 品种归属矩阵（完整）

#### ROSE 群（蔷薇系）— 20种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| rose_red | Rosaceae | ROSACEAE | 核心原始种 |
| rose_pink | Rosaceae | ROSACEAE | 核心-混色变种 |
| rose_white | Rosaceae | ROSACEAE | 核心-混色变种 |
| rose_yellow | Rosaceae | ROSACEAE | 核心-混色变种 |
| sakura | Rosaceae | ROSACEAE | 核心同科 (Prunus) |
| sakura_white | Rosaceae | ROSACEAE | 核心同科 (Prunus) |
| sakura_pink | Rosaceae | ROSACEAE | 核心同科 (Prunus) |
| plum_blossom | Rosaceae | ROSACEAE | 核心同科 (Prunus) |
| peach_blossom | Rosaceae | ROSACEAE | 核心同科 (Prunus) |
| peony | Paeoniaceae | PAEONIACEAE | 外围 |
| begonia | Begoniaceae | BEGONIACEAE | 外围 |
| gardenia | Rubiaceae | RUBIACEAE | 外围 |
| camellia | Theaceae | THEACEAE | 外围 |
| azalea | Ericaceae | ERICACEAE | 外围 |
| anemone | Ranunculaceae | RANUNCULACEAE | 外围 |
| hibiscus | Malvaceae | MALVACEAE | 外围 |
| (稀有花) | — | — | 稀有变异 |

#### LILY 群（百合系）— 18种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| lily | Liliaceae | LILIACEAE | 核心原始种 |
| lily_white | Liliaceae | LILIACEAE | 核心-混色 |
| lily_pink | Liliaceae | LILIACEAE | 核心-混色 |
| tulip_yellow | Liliaceae | LILIACEAE | 核心同科 (Tulipa) |
| tulip_orange | Liliaceae | LILIACEAE | 核心同科 (Tulipa) |
| tulip_purple | Liliaceae | LILIACEAE | 核心同科 (Tulipa) |
| tulip_red | Liliaceae | LILIACEAE | 核心同科 (Tulipa) |
| hyacinth | Asparagaceae | ASPARAGACEAE | 近缘 (同目 Asparagales) |
| bluebell | Asparagaceae | ASPARAGACEAE | 近缘 |
| narcissus | Amaryllidaceae | AMARYLLIDACEAE | 近缘 (同目) |
| lotus | Nelumbonaceae | NELUMBONACEAE | 外围 |
| gladiolus | Iridaceae | IRIDACEAE | 外围 |
| canna | Cannaceae | CANNACEAE | 外围 |
| ranunculus | Ranunculaceae | RANUNCULACEAE | 外围 |
| sweet_pea | Fabaceae | FABACEAE | 外围 |
| water_lily | Nymphaeaceae | NYMPHAEACEAE | 外围 |

#### DAISY 群（菊系）— 18种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| daisy_white | Asteraceae | ASTERACEAE | 核心原始种 |
| daisy_yellow | Asteraceae | ASTERACEAE | 核心-混色 |
| sunflower | Asteraceae | ASTERACEAE | 核心同科 |
| sunflower_orange | Asteraceae | ASTERACEAE | 核心-混色 |
| cosmos | Asteraceae | ASTERACEAE | 核心同科 |
| chrysanthemum | Asteraceae | ASTERACEAE | 核心同科 |
| dahlia | Asteraceae | ASTERACEAE | 核心同科 |
| dahlia_red | Asteraceae | ASTERACEAE | 核心-混色 |
| zinnia | Asteraceae | ASTERACEAE | 核心同科 |
| marigold | Asteraceae | ASTERACEAE | 核心同科 |
| gesang | Asteraceae | ASTERACEAE | 核心同科 |
| carnation | Caryophyllaceae | CARYOPHYLLACEAE | 外围 |
| carnation_pink | Caryophyllaceae | CARYOPHYLLACEAE | 外围-混色 |
| gypsophila | Caryophyllaceae | CARYOPHYLLACEAE | 外围 |
| poppy | Papaveraceae | PAPAVERACEAE | 外围 |
| hydrangea | Hydrangeaceae | HYDRANGEACEAE | 外围 |

#### ORCHID 群（兰系）— 13种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| orchid | Orchidaceae | ORCHIDACEAE | 核心原始种 |
| orchid_white | Orchidaceae | ORCHIDACEAE | 核心-混色 |
| lavender | Lamiaceae | LAMIACEAE | 外围 |
| lavender_deep | Lamiaceae | LAMIACEAE | 外围-混色 |
| violet | Violaceae | VIOLACEAE | 外围 |
| jasmine | Oleaceae | OLEACEAE | 外围 |
| wisteria | Fabaceae | FABACEAE | 外围 |
| magnolia | Magnoliaceae | MAGNOLIACEAE | 外围 |
| iris | Iridaceae | IRIDACEAE | 外围 (同目) |
| morning_glory | Convolvulaceae | CONVOLVULACEAE | 外围 |
| forget_me_not | Boraginaceae | BORAGINACEAE | 外围 |

#### SUCCULENT 群（多肉系）— 7种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| succulent_echeveria | Crassulaceae | CRASSULACEAE | 核心原始种 |
| succulent_bear | Crassulaceae | CRASSULACEAE | 核心同科 |
| succulent_dragon | Crassulaceae | CRASSULACEAE | 核心同科 |
| succulent_haworthia | Asphodelaceae | ASPHODELACEAE | 外围 |
| succulent_string | Asteraceae | ASTERACEAE | 外围 (菊科居然!) |
| succulent_panda | — | — | 混色变种 |

#### CACTUS 群（仙人掌系）— 4种

| 品种ID | 真实科 | family_id | 组内角色 |
|--------|--------|-----------|---------|
| cactus | Cactaceae | CACTACEAE | 核心原始种 |
| cactus_bloom | Cactaceae | CACTACEAE | 核心同科 |
| cactus_star | Cactaceae | CACTACEAE | 核心同科 |

---

## 5. 植物学兼容度体系

### 5.1 四层兼容度

这是新系统的核心创新。不再只是"同组/不同组"二元判定，而是根据双亲的**真实植物学关系**计算兼容等级：

| 等级 | 名称 | 判断条件 | 杂交成功率 | 寓意 |
|------|------|---------|-----------|------|
| S | 同种（Same Species） | 同一品种 | 80% | 保种繁殖 |
| A | 同属（Same Genus） | 同 family_id + 同属标记 | 55% | 最易产生种间杂交种 |
| B | 同科（Same Family） | 同 family_id | 30% | 不同属但同科 |
| C | 同组（Same Group） | 同 BreedingGroup | 15% | 游戏内同一组但不同科 |
| D | 跨组（Cross Group） | 不同 BreedingGroup | 5% | 游戏内不同大组 |

### 5.2 每个品种的属标记

在 PlantData 中增加字段：

```gdscript
# 同属标记：同 group 内相同真实属的品种共享同一个 genus_id
"genus_id": "rosa",      # 所有 Rosa 属品种
"genus_id": "prunus",    # 所有 Prunus 属品种（樱花/梅/桃）
"genus_id": "tulipa",    # 郁金香属
"genus_id": "lilium",    # 百合属
"genus_id": "bellis",    # 雏菊属
"genus_id": "tagetes",   # 万寿菊属
# ... 以此类推
```

### 5.3 兼容度判定算法

```gdscript
static func compute_compatibility(a_type: String, b_type: String) -> int:
	var a := PlantData.get_data(a_type)
	var b := PlantData.get_data(b_type)
	
	# S级：同品种
	if a_type == b_type:
		return COMPAT_SAME_SPECIES  # 4
	
	# A级：同属
	if a.has("genus_id") and b.has("genus_id") and a.genus_id == b.genus_id:
		return COMPAT_SAME_GENUS     # 3
	
	# B级：同科
	if a.family_id == b.family_id:
		return COMPAT_SAME_FAMILY    # 2
	
	# C级：同组
	if a.group == b.group:
		return COMPAT_SAME_GROUP     # 1
	
	# D级：跨组
	return COMPAT_CROSS_GROUP       # 0
```

---

## 6. 花色遗传（不完全显性模型）

### 6.1 改变：从随机选择到不完全显性混合

**旧版**：50% 继承父本A、50% 继承父本B → 孩子要么全红要么全白
**新版**：**不完全显性** → 红+白 = 粉（中间色）

### 6.2 花色遗传算法

```gdscript
# 不完全显性混合 — 取代旧版 inherit_color_gene
static func blend_color(primary: Dictionary, secondary: Dictionary, dominance: float = 0.5) -> Dictionary:
	# dominance: 显性亲本权重 (0.5 = 均等, >0.5 = 偏向primary)
	return {
		"r": clampi(int(primary.r * dominance + secondary.r * (1.0 - dominance) + randf_range(-15, 15)), 0, 255),
		"g": clampi(int(primary.g * dominance + secondary.g * (1.0 - dominance) + randf_range(-15, 15)), 0, 255),
		"b": clampi(int(primary.b * dominance + secondary.b * (1.0 - dominance) + randf_range(-15, 15)), 0, 255),
	}
```

### 6.3 显性等级

某些颜色具有生物学上的显性/隐性关系：

| 颜色 | 显性等级 | 说明 |
|------|---------|------|
| 红色 | 高(0.6) | 花青素显性，常遮盖其他色 |
| 紫色 | 高(0.55) | 花青素类 |
| 粉色 | 中(0.5) | 不完全显性典型 |
| 白色 | 低(0.4) | 常为隐性（无色） |
| 黄色 | 中(0.5) | 类胡萝卜素独立遗传 |
| 橙色 | 中(0.5) | 红+黄混合 |

### 6.4 预期结果示例

```
红玫瑰(229,57,53) × 白玫瑰(250,250,250)
  → 粉玫瑰 (239,153,151) — 不完全显性混合，dominance=0.5
  → 与当前 "rose_pink"(244,143,177) 接近 ✓

黄郁金香(253,216,53) × 紫郁金香(126,87,194)
  → 橙色调混合 (190,152,124)
  → 可触发 "tulip_orange" 的发现

蓝雏菊(60,120,255) 理论上 → 需要先通过杂交培育出蓝色调雏菊
  真实：蓝色在花卉中罕见，通过特殊花青素条件产生
  游戏：通过多代杂交逐渐将蓝色引入菊系
```

---

## 7. 渐进发现系统（Discovery Tree）

### 7.1 设计思路

每个培育组有独立的**发现树（Discovery Tree）**，类似科技树：

```
初始种 ──→ 混色变种 ──→ 同组杂交种 ──→ 多步杂交种 ──→ 珍稀种
 (Tier 0)    (Tier 1)     (Tier 2)      (Tier 3)      (Tier 4)
```

### 7.2 品种 tier 定义

| Tier | 名称 | 数量示意 | 解锁条件 |
|------|------|---------|---------|
| 0 | 原始野生种 | 每组2-3种 | 游戏直接给予 |
| 1 | 同种混色 | 每组2-4种 | 同种繁殖3-5次 或 特定颜色组合 |
| 2 | 同属杂交种 | 每组2-3种 | 同属两个不同种杂交 |
| 3 | 同科杂交种 | 每组2-4种 | 同科不同属杂交 |
| 4 | 外围跨科种 | 每组1-3种 | 同组不同科的特殊组合 |
| R | 稀有变异 | 全游戏15种 | 低概率突变 + 颜色条件 |

### 7.3 发现树示例（ROSE 群）

```
Tier 0 [初始]:
  Rosa gallica (红玫瑰) ─── 蔷薇科 Rosa 属
  Rosa canina (粉玫瑰)  ─── 蔷薇科 Rosa 属
  
Tier 1 [同种繁殖/混色]:
  Rosa gallica 自交 → rose_white (白玫瑰, albino 变异)
  Rosa gallica × Rosa canina → rose_pink (粉色中间色)
  Rosa gallica × rosa_white → rose_yellow (隐性基因表达)
  
Tier 2 [同科 Rosa × Prunus 杂交]:
  玫瑰 × 樱花 → peony (牡丹 - 虚构跨属杂种)
  玫瑰 × 梅花 → plum_blossom
  玫瑰 × 桃花 → peach_blossom
  
Tier 3 [同组不同科]:
  玫瑰(Rosaceae) + 银莲花(Ranunculaceae) → anemone
  玫瑰(Rosaceae) + 山茶(Theaceae) → camellia
  
Tier 4 [多步杂交]:
  玫瑰 + 牡丹 → 山茶花
  山茶花 + 桃花 → 杜鹃花
  杜鹃花 + 玫瑰 → 木槿花
  
R [稀有]:
  极亮RGB → rainbow_rose
  极暗 → dark_mandrake / black_rose
  烈焰橙 → phoenix_flower
```

### 7.4 发现条件表（取代旧 CROSS_BREED_TABLE）

新系统用更灵活的**发现条件表**替代旧版字符串拼接的杂交表：

```gdscript
static var DISCOVERY_TABLE: Dictionary = {
	# 键: "type_a+type_b" → 值: {result_type, min_tier, min_count}
	# 同属自动计算，不需全写进表
	
	# ROSE 群 Tier 2
	"rosa+prunus": {"result": "peony", "min_discoveries": 3},
	"rosa+prunus_sakura": {"result": "sakura", "min_discoveries": 2},
	
	# ROSE 群 Tier 3
	"rosa+anemone": {"result": "plum_blossom", "min_discoveries": 5},
	"rosa+gardenia": {"result": "camellia", "min_discoveries": 5},
	
	# ROSE 群 Tier 4 (多步)
	"peony+camellia": {"result": "azalea", "min_discoveries": 8},
	"camellia+azalea": {"result": "hibiscus", "min_discoveries": 10},
	# ... 以此类推
}
```

关键变化：
- 使用 **genus_id** 匹配取代冗长的品种名拼接
- 增加 `min_discoveries` 条件：玩家必须先发现 N 种花才能解锁特定杂交
- 杂交条件是分步解锁的，不一次性全开

---

## 8. 培育概率系统（加权候选池）

### 8.1 总流程概览

```
选择两亲本
  ↓
计算兼容度等级 (S/A/B/C/D)
  ↓
构建结果候选池（加权）
  ↓
按概率从池中抽取最终结果
  ↓
抽取后执行后处理（颜色混合、突变检测）
```

### 8.2 加权候选池模型

采用 Oracle 设计的**方案A（加权候选池）**，确保~76% 概率得到「新内容」：

| 结果类型 | S级权重 | A级权重 | B级权重 | C级权重 | D级权重 |
|---------|---------|---------|---------|---------|---------|
| 亲本A复制 | 20 | 15 | 20 | 25 | 35 |
| 亲本B复制 | 20 | 15 | 10 | 15 | 20 |
| 同属杂交新种 | — | 40 | 20 | 5 | — |
| 同科杂交新种 | — | — | 25 | 10 | — |
| 同组跨科新种 | — | — | — | 15 | 5 |
| 跨组稀有 | — | — | — | 2 | 5 |
| 颜色变异 | 30 | 15 | 10 | 10 | 10 |
| 突变 | 20 | 10 | 8 | 8 | 10 |
| 亲本A混色 | 10 | 5 | 7 | 10 | 15 |
| **"出新率"** | **~30%** | **~65%** | **~63%** | **~40%** | **~20%** |

> 注：出新率 = 获得新品种（非亲本A/B复制）的概率。

### 8.3 决策算法

```gdscript
static func select_outcome(parent_a: String, parent_b: String, compat: int) -> Dictionary:
	var weights := COMPAT_WEIGHTS[compat]  # 根据兼容度取权重表
	var pool := _build_candidate_pool(parent_a, parent_b, compat)
	
	# 加权随机选择
	var total_weight := 0
	for candidate in pool:
		total_weight += candidate.weight
	
	var roll := randf_range(0, total_weight)
	var cumulative := 0.0
	for candidate in pool:
		cumulative += candidate.weight
		if roll <= cumulative:
			return candidate
	
	return pool[0]  # fallback
```

### 8.4 与旧系统的对比

| 维度 | 旧系统 | 新系统 |
|------|--------|--------|
| 结果种类 | 4种（稀/杂/混/亲本） | 10种（分层级） |
| 亲本复制概率 | 70% | 20-55%（取决于兼容度） |
| "出新"概率 | 30%（含稀有3%） | 45-80%（取决于兼容度） |
| 策略深度 | 无 | 高——选同属提高出新率 |
| 反馈感 | 差——总是同一朵花 | 好——每次都有变化 |

---

## 9. 稀有变异与突变

### 9.1 双通道稀有系统

保留原有 15 种稀有变异花，但修改触发机制：

```
通道1: 随机突变（3-8%）
  → 不依赖颜色，纯概率触发
  → 触发后随机选择该组可用的稀有花
  → 保底机制：每 N 次培育无稀有，概率 +0.5%/次

通道2: 颜色条件触发（始终检测）
  → 无论是否触发突变，都检查子代颜色
  → 匹配稀有花颜色条件 → 强制转换为该稀有花
  → 但需要对应品种已在发现树中解锁
```

### 9.2 稀有花触发表（更新版）

保持现有的 15 种稀有花，仅微调触发条件使其更合理：

| 稀有花 | 组 | 颜色条件 | 触发概率 | 备注 |
|--------|-----|---------|---------|------|
| 彩虹玫瑰 | 蔷薇 | RGB均>200 | 条件+概率 | 原3%改为加权池内触发 |
| 黑玫瑰 | 蔷薇 | RGB均<30 | 条件 | 极暗红色 |
| 樱吹雪 | 蔷薇 | R>240,G>230,B>245 | 条件 | 粉白纯净 |
| 暗夜曼陀罗 | 任意 | RGB均<50 | 条件 | 纯黑 |
| 凤凰花 | 任意 | R>230,G∈(80,150),B<50 | 条件 | 烈焰橙红 |
| 永恒之花 | 兰系 | RGB均>230 | 条件 | 神话白花 |
| 雪后 | 百合 | R>230,G>240,B>245 | 条件 | 冰白 |
| 午夜百合 | 百合 | R<60,G<50,B>100 | 条件 | 深紫夜 |
| 月光百合 | 百合 | R<80,G>180,B>180 | 条件 | 蓝白月光 |
| 金色向日葵 | 菊系 | R>200,G>180,B<50 | 条件 | 金色 |
| 蓝色雏菊 | 菊系 | B>220,R<100 | 条件 | 蓝菊 |
| 幽灵兰 | 兰系 | G>230,R<220,B<220 | 条件 | 幽灵绿 |
| 极光花 | 兰系 | G>180,B>180,R<150 | 条件 | 极光蓝绿 |
| 水晶莲 | 多肉 | B>200,G>200,R<180 | 条件 | 水晶蓝 |
| 金琥 | 仙人掌 | R>200,G>180,B<80 | 条件 | 金色 |

### 9.3 保底机制（breeds_since_rare）

```gdscript
# 在 game_state.gd 中添加
var breeds_since_last_rare: int = 0

# 每次培育后累加，触发稀有后归零
# 随机突变基础概率: 3%
# 每 10 次未出稀有，概率 +1%
# 上限 15%
```

---

## 10. 初始种子重新设计

### 10.1 原则

- 每个组≥2个真实原生种作为起点
- 全部为**现实中存在的野生原始物种**
- 颜色朴素（不是饱和艳丽的园艺种）

### 10.2 初始种子表

| 品种ID | 游戏名 | 学名 | 真实物种 | 花色 |
|--------|-------|------|---------|------|
| rose_gallica | 法国蔷薇 | *Rosa gallica* | ✅ 原生蔷薇 | 深粉红 |
| rose_canina | 犬蔷薇 | *Rosa canina* | ✅ 欧洲野生 | 浅粉 |
| daisy_wild | 野生雏菊 | *Bellis perennis* | ✅ 欧洲/亚洲原生 | 白+黄心 |
| sunflower_wild | 野生向日葵 | *Helianthus annuus* | ✅ 北美原生 | 黄 |
| tulip_wild | 野生郁金香 | *Tulipa sylvestris* | ✅ 地中海原生 | 黄 |
| lily_candidum | 圣母百合 | *Lilium candidum* | ✅ 巴尔干原生 | 纯白 |
| orchid_wild | 姬蝴蝶兰 | *Phalaenopsis equestris* | ✅ 菲律宾原生 | 浅粉 |
| succulent_echeveria | 观音莲 | *Echeveria elegans* | ✅ 墨西哥原生 | 蓝绿 |
| cactus_barrel | 金琥 | *Echinocactus grusonii* | ✅ 墨西哥原生 | 绿 |

**初始总品种：9 种（vs 旧版 3 种）**

分布：
- ROSE: 2 种 (gallica + canina)
- LILY: 2 种 (tulip_wild + lily_candidum)
- DAISY: 2 种 (daisy_wild + sunflower_wild)
- ORCHID: 1 种 (orchid_wild)
- SUCCULENT: 1 种 (succulent_echeveria)
- CACTUS: 1 种 (cactus_barrel)

### 10.3 旧种迁移

旧版 83 种保留不动，新增 6 个真实原生种 → 总数 89 种
- 旧 `rose_red` → 保留，作为 `Rosa gallica` 的红色栽培变种（discover_method 改为 mix_color）
- 旧 `daisy_white` → 保留，作为 `Bellis perennis` 白色变种
- 旧 `tulip_yellow` → 保留，作为 `Tulipa sylvestris` 的栽培型
- 不再有 `initial` 品种从数据库消失

---

## 11. 完整培育流程

### 11.1 流程图

```
玩家选两朵花 A, B
  ↓
1. 计算兼容度等级
   get_family_id(A), get_family_id(B)
   get_genus_id(A), get_genus_id(B)
   → 输出 COMPAT_SAME_SPECIES / GENUS / FAMILY / GROUP / CROSS
  ↓
2. 构建加权候选池
   根据兼容度取权重模板
   填充具体候选 → 亲本A/B复制、杂交候选、变色、突变
  ↓
3. 加权随机抽取
   按权重决定最终结果类型
  ↓
4. 后处理
   ├── 颜色混合（不完全显性）
   ├── 突变检测（颜色条件 → 稀有花）
   ├── 渐进发现检测（是否解锁新品种）
   └── breeds_since_rare 计数器更新
  ↓
5. 返回结果
   品种类型、颜色、是否稀有
```

### 11.2 颜色混合 vs 品种选择

**重要解耦**：颜色和品种分开处理

```
品种决定 → 加权候选池抽取
颜色决定 → 不完全显性混合 + 突变偏移

品种和颜色的关系：
  - "混色"结果：品种不变，颜色混合（旧版同品种颜色变种通过此方式获得）
  - "杂交"结果：品种变为新种，颜色取亲本混合
  - 如果杂交结果的颜色匹配某稀有条件 → 可触发稀有花
```

### 11.3 "混色"品种的获得机制

旧系统 18 种 `mix_color` 品种无法自然获得。新系统中：

```
同种繁殖多次 → 触发颜色变异
颜色接近预设的混色品种阈值 → 触发发现通知 "你发现了 XX 粉玫瑰!"
```

具体：
- 每次同种繁殖，子代颜色在亲本基础上 ±20 随机偏移
- 连续同种繁殖，颜色逐渐漂移
- 当颜色漂移到接近某个 `mix_color` 品种的 base_color 时，触发发现
- 阈值：颜色距离 < 30（欧几里得距离）

```gdscript
static func check_color_variant_discovery(child_color: Dictionary, base_type: String) -> String:
	# 检查 base_type 所属品种的所有混色变种
	var variants := PlantData.get_color_variants(base_type)
	for variant_type in variants:
		var variant_data := PlantData.get_data(variant_type)
		var target := variant_data.base_color
		var dist := sqrt(pow(child_color.r - target.r, 2) + pow(child_color.g - target.g, 2) + pow(child_color.b - target.b, 2))
		if dist < COLOR_DISCOVERY_THRESHOLD:  # 30
			return variant_type
	return ""
```

---

## 12. 实现计划

### 阶段一：数据层改造（不动游戏逻辑）

1. 在 `PlantData` 中添加 `PlantFamily` 枚举
2. 为每个品种添加 `family_id` 和 `genus_id` 字段
3. 将旧 `CROSS_BREED_TABLE` 改造为 `DISCOVERY_TABLE`（保留兼容性）
4. 添加 6 个真实原生初始品种
5. 调整 `discover_method` 分布（部分 cross_breed → 移入 tier 结构）

### 阶段二：核心算法重构

1. 重写 `gene_system.gd`：
   - 添加 `compute_compatibility()` → 四层兼容度
   - 添加 `blend_color()` → 不完全显性混合
   - 添加 `select_outcome()` → 加权候选池
   - 添加 `check_color_variant_discovery()` → 混色发现
   - 保留 `check_rare()` 稀有检测通道
2. 在 `game_state.gd` 中添加 `breeds_since_last_rare` 计数器
3. 修改 `breed()` / `breed_multi()` 使用新流程

### 阶段三：UI/UX 配合（可选）

1. 培育室显示兼容度指示（S/A/B/C/D 等级）
2. 图鉴显示发现路径（"从红玫瑰+犬蔷薇获得"）
3. 培育结果增加发现动画特效

### 代码文件变更清单

| 文件 | 变更类型 | 说明 |
|------|---------|------|
| `scripts/core/plant_data.gd` | **重写** | 添加 family_id, genus_id, DISCOVERY_TABLE |
| `scripts/autoload/gene_system.gd` | **重写** | 新 breed 算法、兼容度、加权池 |
| `scripts/autoload/game_state.gd` | **修改** | 添加 breeds_since_last_rare，修改初始种子，添加 seed_pack 解锁逻辑 |
| `scripts/autoload/event_bus.gd` | **修改** | 添加 seed_pack_unlocked / milestone_reached 信号 |
| `scripts/ui/encyclopedia.gd` + .tscn | **重写** | 进度条、来源筛选、详情增强、解锁区域查看 |
| `scripts/ui/seed_pack_unlock.tscn` + .gd | **新增** | 种子包解锁弹窗动画 |
| `docs/references/gene-system.md` | **已更新** | 本文档 |

---

## 13. 图鉴种子解锁系统

### 13.1 设计理念

> 图鉴不仅是记录册，更是游戏的核心进程引擎

**核心理念**：收录的品种越多，解锁的"种子包"越多。每个种子包代表一个真实植物生境区域，包含该区域的特有花卉。

```
收获/培育 → 开花 → 收录图鉴
                  ↓
           检查里程碑（收录总数）
                  ↓
           达到阈值 → 解锁新区域种子包
                  ↓
           种子包内品种加入种子库
                  ↓
           玩家播种 → 继续探索
```

### 13.2 里程碑与种子包

| 顺序 | 里程碑 | 种子包 | 解锁品种数 | 累计可达 |
|------|--------|--------|-----------|---------|
| 0 | 初始 | 🌱 花园基础包 | 9 | 9 |
| 1 | 5 种 | 🌿 **温带花园** | 7 (5 现有 + 2 新增) | 16 |
| 2 | 10 种 | 🌸 **东方庭院** | 7 (5 现有 + 2 新增) | 23 |
| 3 | 18 种 | 🌊 **地中海花园** | 7 (5 现有 + 2 新增) | 30 |
| 4 | 28 种 | 🌺 **热带花境** | 7 (5 现有 + 2 新增) | 37 |
| 5 | 38 种 | ⛰️ **高山草甸** | 7 (5 现有 + 2 新增) | 44 |
| 6 | 48 种 | 🏜️ **荒漠奇境** | 7 (5 现有 + 2 新增) | 51 |
| 7 | 55 种 | 💧 **水生花园** | 5 (3 现有 + 2 新增) | 56 |
| 8 | 65 种 | 👑 **珍藏集** | 剩余品种 + 3 神秘花 | ~100+ |

### 13.3 种子包详细内容

#### 🌱 花园基础包（初始直接获得）

| 品种ID | 品种名 | 学名 | 真实原生种? | 现有/新增 |
|--------|-------|------|-----------|----------|
| rose_gallica | 法国蔷薇 | *Rosa gallica* | ✅ 原生 | 🆕 新增 |
| rose_canina | 犬蔷薇 | *Rosa canina* | ✅ 原生 | 🆕 新增 |
| daisy_wild | 野生雏菊 | *Bellis perennis* | ✅ 原生 | 🆕 新增 |
| sunflower_wild | 野生向日葵 | *Helianthus annuus* | ✅ 原生 | 🆕 新增 |
| tulip_wild | 野生郁金香 | *Tulipa sylvestris* | ✅ 原生 | 🆕 新增 |
| lily_candidum | 圣母百合 | *Lilium candidum* | ✅ 原生 | 🆕 新增 |
| orchid_wild | 姬蝴蝶兰 | *Phalaenopsis equestris* | ✅ 原生 | 🆕 新增 |
| succulent_echeveria | 观音莲 | *Echeveria elegans* | ✅ 原生 | 现有 |
| cactus_barrel | 金琥 | *Echinocactus grusonii* | ✅ 原生 | 🆕 新增 |

**旧初始种保留**：rose_red, daisy_white, tulip_yellow 保留在游戏中，discover_method 改为 `mix_color`，作为基础包的栽培变种。

#### 🌿 温带花园（5 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| peony | 牡丹 | ROSE | ✅ 现有 |
| gardenia | 栀子花 | ROSE | ✅ 现有 |
| lily | 百合 | LILY | ✅ 现有 |
| plum_blossom | 梅花 | ROSE | ✅ 现有 |
| peach_blossom | 桃花 | ROSE | ✅ 现有 |
| 🆕 foxglove | 毛地黄 | LILY | 🆕 |
| 🆕 delphinium | 飞燕草 | LILY | 🆕 |

#### 🌸 东方庭院（10 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| sakura | 樱花 | ROSE | ✅ 现有 |
| azalea | 杜鹃 | ROSE | ✅ 现有 |
| camellia | 山茶花 | ROSE | ✅ 现有 |
| wisteria | 紫藤 | ORCHID | ✅ 现有 |
| begonia | 海棠 | ROSE | ✅ 现有 |
| 🆕 cymbidium | 建兰 | ORCHID | 🆕 东方传统兰 |
| 🆕 kiku | 秋菊 | DAISY | 🆕 日本传统菊 |

#### 🌊 地中海花园（18 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| lavender | 薰衣草 | ORCHID | ✅ 现有 |
| violet | 紫罗兰 | ORCHID | ✅ 现有 |
| jasmine | 茉莉花 | ORCHID | ✅ 现有 |
| carnation | 康乃馨 | DAISY | ✅ 现有 |
| gypsophila | 满天星 | DAISY | ✅ 现有 |
| 🆕 rosemary | 迷迭香 | ORCHID | 🆕 地中海标志香草 |
| 🆕 bougainvillea | 三角梅 | ROSE | 🆕 地中海/热带藤本 |

#### 🌺 热带花境（28 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| hibiscus | 木槿花 | ROSE | ✅ 现有 |
| lotus | 荷花 | LILY | ✅ 现有 |
| canna | 美人蕉 | LILY | ✅ 现有 |
| magnolia | 玉兰 | ORCHID | ✅ 现有 |
| morning_glory | 牵牛花 | ORCHID | ✅ 现有 |
| 🆕 bird_of_paradise | 鹤望兰 | ORCHID | 🆕 热带标志花卉 |
| 🆕 frangipani | 鸡蛋花 | ROSE | 🆕 热带芳香 |

#### ⛰️ 高山草甸（38 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| anemone | 银莲花 | ROSE | ✅ 现有 |
| iris | 鸢尾花 | ORCHID | ✅ 现有 |
| narcissus | 水仙花 | LILY | ✅ 现有 |
| bluebell | 风铃草 | LILY | ✅ 现有 |
| ranunculus | 花毛茛 | LILY | ✅ 现有 |
| 🆕 edelweiss | 雪绒花 | DAISY | 🆕 阿尔卑斯标志花 |
| 🆕 gentian | 龙胆 | LILY | 🆕 高山蓝紫花 |

#### 🏜️ 荒漠奇境（48 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| cactus | 仙人掌 | CACTUS | ✅ 现有 |
| cactus_bloom | 仙人球 | CACTUS | ✅ 现有 |
| cactus_star | 星兜 | CACTUS | ✅ 现有 |
| succulent_haworthia | 玉露 | SUCCULENT | ✅ 现有 |
| succulent_bear | 熊童子 | SUCCULENT | ✅ 现有 |
| 🆕 aloe | 芦荟 | SUCCULENT | 🆕 经典沙漠植物 |
| 🆕 lithops | 生石花 | SUCCULENT | 🆕 拟态多肉 |

#### 💧 水生花园（55 种解锁）

| 品种ID | 品种名 | 组 | 状态 |
|--------|-------|-----|------|
| water_lily | 睡莲 | LILY | ✅ 现有 |
| hyacinth | 风信子 | LILY | ✅ 现有 |
| gladiolus | 剑兰 | LILY | ✅ 现有 |
| 🆕 cattail | 香蒲 | LILY | 🆕 水生植物 |
| 🆕 lotus_blue | 蓝荷花 | LILY | 🆕 荷花蓝色变种 |

#### 👑 珍藏集（65 种解锁）

剩余所有未解锁品种 + 2-3 个神秘花作为全收集奖励。

### 13.4 新增品种汇总

共约 **20 个新品种**，按组分布：

| 组 | 新增数量 | 新增品种 |
|----|---------|---------|
| ROSE | 3 | rose_gallica, rose_canina, bougainvillea, frangipani |
| LILY | 7 | foxglove, delphinium, gentian, cattail, lotus_blue, tulip_wild, lily_candidum |
| DAISY | 3 | kiku, edelweiss, sunflower_wild |
| ORCHID | 4 | cymbidium, rosemary, bird_of_paradise, orchid_wild |
| SUCCULENT | 2 | aloe, lithops |
| CACTUS | 1 | cactus_barrel |

> 注：以上不含 9 个初始野生种（作为花园基础包），实际新增品种约 20 个。

### 13.5 数据模型变更

```gdscript
# game_state.gd 新增
var unlocked_seed_packs: Dictionary = {}  # pack_id → true

# event_bus.gd 新增信号
signal seed_pack_unlocked(pack_id: String, pack_name: String)
signal milestone_reached(milestone: int, total: int)

# plant_data.gd 新增
static var SEED_PACKS: Dictionary = {
	"temperate_garden": {
		"name": "温带花园",
		"icon": "🌿",
		"milestone": 5,
		"description": "来自温带地区的经典庭院花卉",
		"species": ["peony", "gardenia", "lily", "plum_blossom", "peach_blossom",
			"foxglove", "delphinium"],
	},
	"eastern_garden": {
		"name": "东方庭院",
		"icon": "🌸",
		"milestone": 10,
		"description": "东亚传统园林中的典雅花卉",
		"species": ["sakura", "azalea", "camellia", "wisteria", "begonia",
			"cymbidium", "kiku"],
	},
	# ... 以下略
}
```

### 13.6 解锁逻辑

每次发现新物种时调用（hook 进现有的 `_check_discovery`）：

```gdscript
func _check_seed_pack_unlock() -> void:
	var count := encyclopedia.size()
	for pack_id in PlantData.SEED_PACKS:
		var pack := PlantData.SEED_PACKS[pack_id]
		if unlocked_seed_packs.has(pack_id):
			continue
		if count >= pack.milestone:
			unlocked_seed_packs[pack_id] = true
			for species in pack.species:
				if not species in seed_inventory:
					seed_inventory.append(species)
			EventBus.seed_pack_unlocked.emit(pack_id, pack.name)
```

### 13.7 图鉴 UI 改造

#### 进度条

图鉴顶部新增里程碑进度条：

```
已收录: ████████████░░░░░░ 28/83
                        ↓
下一次解锁: 🌺 热带花境（还需 10 种）
```

#### 发现途径显示

详情面板从：
```
同系杂交培育获得
```
改为：
```
📦 解锁途径：东方庭院种子包（收集 10 种后解锁）
🤝 也可通过：樱花 × 梅花 杂交获得
```

#### 按来源筛选

新增筛选标签："全部" | "初始" | 📦区域 | 🤝杂交 | 🎨色变 | ✨稀有

#### 种子包解锁动画

里程碑解锁时弹窗：

```
🌊━━━━━━━━━━━━━━━━🌊
   发现新区域！
   地中海花园
   ──────────
   薰衣草 · 紫罗兰 · 茉莉花
   康乃馨 · 满天星 · 迷迭香 · 三角梅
   ──────────
   7 个新品种已加入种子库！
🌊━━━━━━━━━━━━━━━━🌊
```

#### 功能开关

解锁动画可跳过（点击关闭），种子包记录可在图鉴"已解锁区域"中随时查看。

### 13.8 与现有系统关系

| 现有系统 | 关系 |
|---------|------|
| 花圃扩展 | **保留**：每 5 种新发现仍然扩展 3 格花圃 |
| 杂交系统 | **独立共存**：杂交仍然可以产出新品种 |
| 稀有突变 | **独立共存**：15 种稀有花仍然通过突变获得 |
| 颜色漂移 | **独立共存**：混色变种通过同种繁殖获得 |
| 种子库 | **延伸**：种子包解锁的品种自动加入种子库 |

### 13.9 选择路径：部分品种双途径

部分品种既可以：

1. **图鉴解锁**：达到里程碑后随种子包获得
2. **杂交提前解锁**：如果玩家凑出了正确的杂交组合，可以跳过里程碑提前获得

例如：
- sakura（樱花）→ 种子包"东方庭院"解锁 **或** rose × plum_blossom 杂交
- peony（牡丹）→ 种子包"温带花园"解锁 **或** rose × sakura 杂交
- lavender（薰衣草）→ 种子包"地中海花园"解锁 **或** orchid × violet 杂交

这保证了：**种子包是保底途径，杂交是高手捷径**。

### 13.10 实现计划

| 阶段 | 内容 | 涉及文件 |
|------|------|---------|
| 数据层 | 定义 SEED_PACKS 表、milestone 常量 | plant_data.gd |
| 状态层 | 添加 unlocked_seed_packs、解锁逻辑 | game_state.gd, event_bus.gd |
| UI 层 | 进度条、来源筛选、详情增强 | encyclopedia.gd |
| 动画层 | 种子包解锁弹窗 | 新场景 + gd |
| 内容层 | 新增 ~20 个品种数据 + 精灵图 | plant_data.gd + assets |

---

## 附录：真实原生种数据（可新增的初始花）

| 学名 | 中文名 | 所属科 | 花色 | 游戏品种ID |
|------|--------|-------|------|-----------|
| *Rosa gallica* | 法国蔷薇 | Rosaceae | 深粉红 | rose_gallica |
| *Rosa canina* | 犬蔷薇 | Rosaceae | 浅粉/白 | rose_canina |
| *Bellis perennis* | 雏菊 | Asteraceae | 白+黄心 | daisy_wild |
| *Helianthus annuus* | 向日葵 | Asteraceae | 黄 | sunflower_wild |
| *Tulipa sylvestris* | 野生郁金香 | Liliaceae | 黄 | tulip_wild |
| *Lilium candidum* | 圣母百合 | Liliaceae | 纯白 | lily_candidum |
| *Phalaenopsis equestris* | 姬蝴蝶兰 | Orchidaceae | 浅粉 | orchid_wild |
| *Echeveria elegans* | 观音莲 | Crassulaceae | 蓝绿 | succulent_echeveria |
| *Echinocactus grusonii* | 金琥 | Cactaceae | 绿 | cactus_barrel |

> **注意**：以上数据已包含当前版本已有的品种（如 succulent_echeveria），新增品种仅需补充缺失的野生种。

---

*文档结束*

# AI 美术资源生成提示词指南

> 为 Flower Desktop 所有美术资源提供 AI 绘图提示词（Prompts），涵盖植物、UI、背景、特效等。
>
> 推荐工具：Midjourney v6 / DALL-E 3 / Stable Diffusion SDXL
> 输出规格：PNG，单株去背景（transparent background），每株 5 阶段生长动画 + 1 剪影

---

## 目录

1. [已有资产清单（无需生成）](#1-已有资产清单)
2. [缺失资产总览](#2-缺失资产总览)
3. [新植物品种提示词（22 种）](#3-新植物品种提示词)
4. [野生初始种提示词（7 种）](#4-野生初始种提示词)
5. [稀有变异已有（15 种，仅补充说明）](#5-稀有变异)
6. [UI 图标提示词](#6-ui-图标提示词)
7. [场景背景提示词](#7-场景背景提示词)
8. [粒子特效提示词](#8-粒子特效提示词)
9. [花圃/Garden 环境提示词](#9-花圃环境提示词)
10. [通用生成指南](#10-通用生成指南)

---

## 1. 已有资产清单

以下资源**已有完整 PNG**，无需生成：

### 🌸 普通花卉（52 种 × 6 图=312 图）
| 品种 | 目录 | 说明 |
|------|------|------|
| anemone~zinnia 等 52 种 | `assets/sprites/plants/flower/` | seed/sprout/seedling/mature/flowering + silhouette |

### 🌵 仙人掌（3 种 × 6 图=18 图）
| 品种 | 说明 |
|------|------|
| cactus / cactus_bloom / cactus_star | 已有完整生长序列 |

### 🪴 多肉（6 种 × 6 图=36 图）
| 品种 | 说明 |
|------|------|
| succulent_echeveria / haworthia / bear / dragon / string / panda | 已有完整生长序列 |

### 🌟 稀有花（15 种 × 6 图=90 图）
全部 15 种稀有花已有完整生长序列 + 剪影：
- rare_rainbow_rose, rare_dark_mandrake, rare_golden_sunflower, rare_moonlight_lily
- rare_eternal_flower, rare_black_rose, rare_snow_queen, rare_blue_daisy
- rare_ghost_orchid, rare_crystal_succulent, rare_golden_cactus, rare_phoenix_flower
- rare_aurora_borealis, rare_sakura_blizzard, rare_midnight_lily

### 🔊 音效（全部已有）
BGM：bgm_breeding, bgm_desktop, bgm_garden, bgm_title
SFX：breed, click, coin, discover, fail, harvest, level_up, plant, success, water

### 🔤 字体
字体目录为空（使用 Godot 默认字体）

---

## 2. 缺失资产总览

需要 **AI 生成**的美术资源：

| 分类 | 数量 | 文件数 |
|------|------|--------|
| 新植物（种子包解锁，完整生长序列） | 14 种 | 14 × 6 = 84 图 |
| 野生初始种（完整生长序列） | 7 种 | 7 × 6 = 42 图 |
| UI 背景/纹理 | 4 个场景 | 4 图 |
| 花圃/桌面粒子特效 | 2~3 种 | 2~3 图 |
| 花圃 Garden 地面纹理 | 1 图 | 1 图 |
| UI 图标 | 10 个 | 10 图 |
| **总计** | | **~143 图** |

---

## 3. 新植物品种提示词（14 种）

> 每种需要 5 阶段生长 + 1 剪影（silhouette）。
> 阶段标识：`_0_seed` → `_1_sprout` → `_2_seedling` → `_3_mature` → `_4_flowering`
> 命名示例：`foxglove_4_flowering.png`
>
> **通用约束：**
> - 2D 俯视或正视角（top-down 或 front view）
> - 去背景（transparent background PNG）
> - 像素风格或扁平卡通（pixel art / flat cartoon），与本项目现有风格一致
> - 颜色与定义中的 base_color 接近
> - 不要在花盆/花盆里——只画植株本身

---

### 3.1 foxglove — 毛地黄

```
prompt 生成模板（5 张独立生成，改 stage 关键词）：
"A single [STAGE] of foxglove (Digitalis purpurea), 2D top-down pixel art game asset, 
transparent background, flat cartoon style, [COLOR]. 
[STAGE: 0_seed → tiny brown seed on soil]
[STAGE: 1_sprout → small green sprout with 2-3 rounded leaves]
[STAGE: 2_seedling → leafy rosette, 6-8 elongated leaves]
[STAGE: 3_mature → tall stalk with large lanceolate leaves, flower buds forming]
[STAGE: 4_flowering → tall spike with bell-shaped flowers in pink/purple, hanging downward]"

color: {"r": 200, "g": 140, "b": 220} → 粉紫色系
```

### 3.2 delphinium — 飞燕草

```
"A single [STAGE] of delphinium (Delphinium elatum), 2D top-down pixel art game asset,
transparent background, flat cartoon style, blue to purple flowers.
[STAGE: 0_seed → small dark brown seed]
[STAGE: 1_sprout → 2 small cotyledon leaves]
[STAGE: 2_seedling → palmate lobed leaves, 4-6 leaves]
[STAGE: 3_mature → tall leafy stalk with divided palmate leaves]
[STAGE: 4_flowering → tall spire of many blue/purple flowers with spur]"

color: {"r": 80, "g": 100, "b": 220} → 蓝色系
```

### 3.3 cymbidium — 建兰

```
"A single [STAGE] of cymbidium orchid (Cymbidium), 2D top-down pixel art game asset,
transparent background, flat cartoon style, light green leaves.
[STAGE: 0_seed → tiny dust-like seed (orchid)]
[STAGE: 1_sprout → small pseudobulb with 1-2 narrow green leaves]
[STAGE: 2_seedling → cluster of long narrow strap-like leaves]
[STAGE: 3_mature → dense clump of arching strap leaves]
[STAGE: 4_flowering → arching flower spike with multiple greenish-yellow orchid flowers]"

color: {"r": 200, "g": 220, "b": 180} → 黄绿色
```

### 3.4 kiku — 秋菊 (chrysanthemum 品种)

```
"A single [STAGE] of kiku (Japanese chrysanthemum), 2D top-down pixel art game asset,
transparent background, flat cartoon style, golden yellow.
[STAGE: 0_seed → small elongated seed]
[STAGE: 1_sprout → 2-3 scalloped leaves]
[STAGE: 2_seedling → deeply lobed dark green leaves, compact]
[STAGE: 3_mature → bushy plant with many lobed leaves, buds]
[STAGE: 4_flowering → large layered pom-pom chrysanthemum flower head, golden yellow]"

color: {"r": 255, "g": 200, "b": 50} → 金黄色
```

### 3.5 rosemary — 迷迭香

```
"A single [STAGE] of rosemary (Rosmarinus officinalis), 2D top-down pixel art game asset,
transparent background, flat cartoon style, gray-green needle leaves.
[STAGE: 0_seed → tiny round brown seed]
[STAGE: 1_sprout → small sprig with tiny needle-like leaves]
[STAGE: 2_seedling → upright stem with clustered needle leaves]
[STAGE: 3_mature → shrubby plant with gray-green needle leaves]
[STAGE: 4_flowering → same shrub with small blue flowers at leaf axils]"

color: {"r": 130, "g": 180, "b": 160} → 灰绿色
```

### 3.6 bougainvillea — 三角梅

```
"A single [STAGE] of bougainvillea, 2D top-down pixel art game asset,
transparent background, flat cartoon style, hot pink bracts.
[STAGE: 0_seed → small curved seed]
[STAGE: 1_sprout → green stem with small oval leaves]
[STAGE: 2_seedling → twining vine with green leaves, climbing]
[STAGE: 3_mature → woody vine with heart-shaped leaves]
[STAGE: 4_flowering → vine covered in bright magenta/pink papery bracts with small white flowers]"

color: {"r": 220, "g": 50, "b": 100} → 紫红色
```

### 3.7 bird_of_paradise — 鹤望兰

```
"A single [STAGE] of bird of paradise (Strelitzia reginae), 2D top-down pixel art game asset,
transparent background, flat cartoon style, tropical.
[STAGE: 0_seed → round hard black seed with orange tuft]
[STAGE: 1_sprout → 2 broad banana-like leaves from base]
[STAGE: 2_seedling → clump of large paddle-shaped leaves on long stalks]
[STAGE: 3_mature → large clump of banana-like gray-green leaves, thick stalks]
[STAGE: 4_flowering → tall stalk with bird-shaped flower: orange sepals + blue petals + crown]"

color: {"r": 255, "g": 160, "b": 30} → 橙蓝配色
```

### 3.8 frangipani — 鸡蛋花

```
"A single [STAGE] of frangipani (Plumeria), 2D top-down pixel art game asset,
transparent background, flat cartoon style, white and yellow.
[STAGE: 0_seed → winged seed pod]
[STAGE: 1_sprout → small green stem with few oval leaves]
[STAGE: 2_seedling → fleshy stem, large oval leaves in rosette]
[STAGE: 3_mature → thick woody stems with large dark green leaves at tips]
[STAGE: 4_flowering → cluster of 5-petal flowers, white with yellow center, waxy]"

color: {"r": 255, "g": 240, "b": 200} → 白黄奶油色
```

### 3.9 edelweiss — 雪绒花

```
"A single [STAGE] of edelweiss (Leontopodium alpinum), 2D top-down pixel art game asset,
transparent background, flat cartoon style, white woolly.
[STAGE: 0_seed → small light seed with pappus]
[STAGE: 1_sprout → small rosette of fuzzy gray-green leaves]
[STAGE: 2_seedling → compact rosette of lanceolate woolly leaves]
[STAGE: 3_mature → dense star-shaped rosette of fuzzy leaves]
[STAGE: 4_flowering → star-shaped white woolly bracts with small yellow center flowers]"

color: {"r": 240, "g": 240, "b": 230} → 灰白色
```

### 3.10 gentian — 龙胆

```
"A single [STAGE] of gentian (Gentiana), 2D top-down pixel art game asset,
transparent background, flat cartoon style, intense blue.
[STAGE: 0_seed → tiny brown seed]
[STAGE: 1_sprout → small rosette of oval green leaves]
[STAGE: 2_seedling → dense rosette of pointed leaves]
[STAGE: 3_mature → low clump of pointed dark green leaves]
[STAGE: 4_flowering → stalk with trumpet-shaped brilliant blue flowers, 5 petals]"

color: {"r": 50, "g": 80, "b": 200} → 深蓝色
```

### 3.11 aloe — 芦荟

```
"A single [STAGE] of aloe vera, 2D top-down pixel art game asset,
transparent background, flat cartoon style, fleshy green.
[STAGE: 0_seed → small black seed]
[STAGE: 1_sprout → small fleshy pointed leaf]
[STAGE: 2_seedling → rosette of 4-5 fleshy sword-shaped leaves with toothed edges]
[STAGE: 3_mature → large rosette of thick fleshy upward-pointing leaves]
[STAGE: 4_flowering → tall stalk from center with tubular yellow/orange flowers]"

color: {"r": 100, "g": 170, "b": 100} → 翠绿色
```

### 3.12 lithops — 生石花

```
"A single [STAGE] of lithops (living stone), 2D top-down pixel art game asset,
transparent background, flat cartoon style, stone-like.
[STAGE: 0_seed → tiny brown seed]
[STAGE: 1_sprout → 2 tiny fleshy leaf tips emerging]
[STAGE: 2_seedling → pair of small fleshy stone-like leaves with window tips]
[STAGE: 3_mature → two plump stone-like fused leaves, gray-brown with pattern]
[STAGE: 4_flowering → large daisy-like white/yellow flower emerging from center cleft]"

color: {"r": 200, "g": 180, "b": 130} → 灰褐色（石色）
```

### 3.13 cattail — 香蒲

```
"A single [STAGE] of cattail (Typha), 2D top-down pixel art game asset,
transparent background, flat cartoon style, marsh plant.
[STAGE: 0_seed → tiny wind-dispersed seed with fluff]
[STAGE: 1_sprout → thin blade-like leaf emerging from water]
[STAGE: 2_seedling → cluster of tall narrow upright leaves]
[STAGE: 3_mature → tall clump of strap-like leaves, thick stalk forming]
[STAGE: 4_flowering → tall stalk with cylindrical brown sausage-shaped flower head at top]"

color: {"r": 160, "g": 130, "b": 80} → 棕绿色
```

### 3.14 lotus_blue — 蓝荷花

```
"A single [STAGE] of blue lotus (Nymphaea caerulea), 2D top-down pixel art game asset,
transparent background, flat cartoon style, aquatic.
[STAGE: 0_seed → round black seed in pod]
[STAGE: 1_sprout → small floating heart-shaped leaf]
[STAGE: 2_seedling → cluster of round floating leaves with cleft]
[STAGE: 3_mature → large round floating leaves covering surface]
[STAGE: 4_flowering → large multi-petal lotus flower, sky blue, floating on water surface]"

color: {"r": 100, "g": 140, "b": 220} → 天蓝色
```

---

## 4. 野生初始种提示词（7 种）

> 这些品种是**原始野生祖先**，外观应比栽培品种更朴素、更自然、更小。
> 可以基于已有品种修改（tint + 简化），或完全按提示词生成。

### 4.1 rose_gallica — 法国蔷薇

```
"A single [STAGE] of wild rose (Rosa gallica), 2D top-down pixel art game asset,
transparent background, flat cartoon style, simple 5-petal flower.
Wild ancestor, simpler and smaller than modern garden roses.
[STAGE: 0_seed → small round red rose hip (fruit)]
[STAGE: 1_sprout → small woody stem with 3-5 serrated leaflets]
[STAGE: 2_seedling → bushy thorny stem with compound leaves]
[STAGE: 3_mature → branching woody shrub with dark green leaves]
[STAGE: 4_flowering → simple 5-petal pink-red flower, yellow stamens center]"

color: {"r": 210, "g": 80, "b": 100} → 粉红色
```

### 4.2 rose_canina — 犬蔷薇

```
"A single [STAGE] of dog rose (Rosa canina), 2D top-down pixel art game asset,
transparent background, flat cartoon style, very pale pink, wild-looking.
[STAGE: 0_seed → elongated red rose hip]
[STAGE: 1_sprout → thorny stem with 5-7 serrated leaflets]
[STAGE: 2_seedling → arching thorny canes, compound leaves]
[STAGE: 3_mature → dense arching shrub with hooked thorns]
[STAGE: 4_flowering → 5-petal single flower, pale pink to white, simple]"

color: {"r": 240, "g": 180, "b": 190} → 浅粉色
```

### 4.3 daisy_wild — 野生雏菊

```
"A single [STAGE] of wild daisy (Bellis perennis), 2D top-down pixel art game asset,
transparent background, flat cartoon style, small, meadow-like.
[STAGE: 0_seed → small dark seed]
[STAGE: 1_sprout → small spoon-shaped leaves in rosette]
[STAGE: 2_seedling → compact leaf rosette, slightly larger]
[STAGE: 3_mature → dense rosette of spatulate leaves]
[STAGE: 4_flowering → single flower head on short stalk, white petals + yellow center]"

color: {"r": 255, "g": 255, "b": 230} → 米白色
```

### 4.4 sunflower_wild — 野生向日葵

```
"A single [STAGE] of wild sunflower (Helianthus annuus), 2D top-down pixel art game asset,
transparent background, flat cartoon style, branching multi-head (not single giant head).
[STAGE: 0_seed → striped elongated seed]
[STAGE: 1_sprout → 2 broad cotyledon leaves]
[STAGE: 2_seedling → rough hairy leaves, opposite, heart-shaped]
[STAGE: 3_mature → tall stalk with large heart-shaped leaves, multiple buds]
[STAGE: 4_flowering → medium flower head, golden yellow petals + brown center disc]"

color: {"r": 240, "g": 200, "b": 30} → 金黄色
```

### 4.5 tulip_wild — 野生郁金香

```
"A single [STAGE] of wild tulip (Tulipa sylvestris), 2D top-down pixel art game asset,
transparent background, flat cartoon style, slender, star-shaped.
[STAGE: 0_seed → flat round brown seed]
[STAGE: 1_sprout → single narrow pointed leaf]
[STAGE: 2_seedling → 2-3 narrow strap-like leaves]
[STAGE: 3_mature → clump of waxy blue-green lanceolate leaves]
[STAGE: 4_flowering → slender cup-shaped flower, pointed petals, yellow with red tips]"

color: {"r": 240, "g": 210, "b": 50} → 黄色
```

### 4.6 lily_candidum — 圣母百合

```
"A single [STAGE] of Madonna lily (Lilium candidum), 2D top-down pixel art game asset,
transparent background, flat cartoon style, pure white trumpet.
[STAGE: 0_seed → flat papery seed]
[STAGE: 1_sprout → single unbranched stem with scattered leaves]
[STAGE: 2_seedling → stem with many lanceolate leaves, alternate arrangement]
[STAGE: 3_mature → tall stalk with whorls of lanceolate leaves]
[STAGE: 4_flowering → large pure white trumpet-shaped flower, golden stamens]"

color: {"r": 250, "g": 250, "b": 250} → 纯白色
```

### 4.7 orchid_wild — 姬蝴蝶兰

```
"A single [STAGE] of Phalaenopsis equestris (wild moth orchid), 2D top-down pixel art game asset,
transparent background, flat cartoon style, small graceful.
[STAGE: 0_seed → tiny dust-like seed]
[STAGE: 1_sprout → 2 small oval green leaves from base]
[STAGE: 2_seedling → 3-4 fleshy broad oval leaves in rosette]
[STAGE: 3_mature → clump of fleshy dark green oval leaves]
[STAGE: 4_flowering → arching spray of small pink orchid flowers, round petals]"

color: {"r": 240, "g": 190, "b": 200} → 浅粉色
```

---

## 5. 稀有变异

已有所有 15 种稀有花的完整 5 阶段 + 剪影 PNG。无需生成。

---

## 6. UI 图标提示词

> 现有 UI 图标位于 `assets/sprites/ui/`，均为 PNG 格式。
> 如有需要重新生成或补充的：

### 6.1 icon_close — 关闭按钮
```
"A simple 'X' close icon, flat vector style, white line art on transparent background,
16x16 or 24x24 px, for game UI."
```

### 6.2 icon_coin — 金币
```
"A gold coin icon, flat 2D game style, yellow circle with '$' or star symbol,
transparent background, 24x24 px."
```

### 6.3 icon_star — 星星
```
"A gold 5-pointed star icon, flat 2D game style, transparent background, 24x24 px."
```

### 6.4 icon_trophy — 奖杯
```
"A golden trophy cup icon with handles, flat 2D game style, transparent background, 24x24 px."
```

### 6.5 icon_settings — 设置
```
"A gear/cogwheel icon, flat 2D game style, 5-6 teeth, white line art on transparent background,
24x24 px."
```

### 6.6 icon_shop — 商店
```
"A shopping bag or market stall icon, flat 2D game style, white on transparent, 24x24 px."
```

### 6.7 icon_collection — 收藏/图鉴
```
"An open book with a flower on it, flat 2D game icon, white line art on transparent,
24x24 px."
```

### 6.8 icon_breed — 培育
```
"Two DNA strands or two flowers crossing, flat 2D game icon, white line art on transparent,
24x24 px."
```

### 6.9 icon_seed — 种子
```
"A small seed with a sprout emerging, flat 2D game icon, white line art on transparent,
24x24 px."
```

### 6.10 icon_water — 浇水
```
"A water drop icon, flat 2D game style, blue, transparent background, 24x24 px."
```

### 6.11 新增建议图标

如果后续需要，可以补充：

| 图标名 | 用途 | 提示词 |
|--------|------|--------|
| `icon_breed_success` | 培育成功 | "A glowing beaker with flower inside, flat game icon" |
| `icon_seed_pack` | 种子包 | "A wrapped seed packet icon, flat 2D game style" |
| `icon_storage` | 仓库 | "A wooden crate or warehouse icon, flat game style" |
| `icon_filter` | 筛选按钮 | "A funnel icon, flat 2D game style" |
| `icon_milestone` | 里程碑 | "A flag on mountain peak icon, flat 2D game style" |

---

## 7. 场景背景提示词

> 当前 4 个场景均使用纯色 ColorRect 作为背景，无纹理贴图。
> 如需替换为纹理背景，使用以下提示词生成。

### 7.1 花圃背景 — garden_bg

```
"A seamless top-down garden soil texture, pixel art style, dark brown earth with subtle
green grass tufts, 512x512 px tileable, for 2D game background.
No flowers, just ground texture. Warm natural lighting."
```
尺寸：512×512，可平铺（tileable）

### 7.2 桌面背景 — desktop_bg

```
"A cozy room desktop background, pixel art style, warm wooden desk surface seen from above,
subtle wood grain texture, 512x512 px tileable, for 2D game.
Soft warm lighting, no objects on desk."
```
尺寸：512×512，可平铺

### 7.3 培育室背景 — breeding_bg

```
"A laboratory or greenhouse table surface, pixel art style, smooth pale surface with subtle
scientific grid lines, 512x512 px tileable, for 2D game breeding room.
Clean well-lit environment, cool blue-white lighting."
```
尺寸：512×512，可平铺

### 7.4 种子包弹窗装饰 — seed_pack_deco

```
"A decorative border pattern for a seed pack unlock popup, pixel art style,
vintage botanical illustration border, subtle leaf/vine corner decorations,
dark purple theme, for 2D game UI panel."
```
尺寸：与弹窗面板匹配

---

## 8. 粒子特效提示词

> 当前 `assets/sprites/effects/` 为空。以下特效可用于增强游戏交互反馈：

### 8.1 浇水效果 — effect_water_splash

```
"A water splash effect spritesheet, 4x4 grid of splash frames, pixel art style,
blue water droplets in various splash positions, transparent background.
for 2D game particle effect."
```
尺寸：每帧 32×32，spritesheet 128×128

### 8.2 培育发光 — effect_breed_glow

```
"A magical breeding glow effect, 4 frames spritesheet, soft golden/white radial glow
pulsing outward, pixel art style, transparent background.
for 2D game breeding result effect."
```
尺寸：每帧 64×64，spritesheet 256×64

### 8.3 发现新花 — effect_discover_burst

```
"A discovery burst effect, 5 frames spritesheet, star-shaped sparkles expanding outward,
gold and rainbow colors, pixel art style, transparent background.
For 2D game new species discovered effect."
```
尺寸：每帧 64×64，spritesheet 320×64

### 8.4 种子包解锁弹入 — effect_pack_unlock

```
"A seed pack reveal effect, shimmering sparkle trail, soft green/gold light particles,
pixel art style, transparent background.
For seed pack unlock popup entrance animation."
```
尺寸：每帧 48×48，spritesheet 240×48

---

## 9. 花圃环境提示词

> 当前 `assets/sprites/garden/` 为空。以下为可选补充：

### 9.1 花圃围栏装饰 — garden_fence

```
"A decorative garden fence tile, pixel art style, wooden picket fence, light brown,
192x64 px, for lining the garden grid border.
2D top-down view, tileable horizontally."
```

### 9.2 花圃装饰石 — garden_stone

```
"A decorative garden stone pathway tile, pixel art style, gray cobblestone,
64x64 px tileable, for pathway between garden plots.
2D top-down view."
```

### 9.3 花圃草地 — garden_grass

```
"A lush green grass tile, pixel art style, 64x64 px seamless tile,
different shades of green for variety, 2D top-down view.
For garden plot background."
```

---

## 10. 通用生成指南

### 文件命名规则

```
{type}_{stage}.png        (如: foxglove_4_flowering.png)
silhouette_{type}.png     (如: silhouette_foxglove.png)
icon_{name}.png           (如: icon_water.png)
effect_{name}.png         (如: effect_water_splash.png)
{bg_name}_bg.png          (如: garden_bg.png)
```

### 阶段说明

| 后缀 | 含义 | 描述 |
|------|------|------|
| `_0_seed` | 种子 | 最小形态，种子或种球 |
| `_1_sprout` | 嫩芽 | 刚发芽，1~2 片子叶 |
| `_2_seedling` | 幼苗 | 多片真叶，婴儿植株 |
| `_3_mature` | 成株 | 成熟营养体，花蕾形成前 |
| `_4_flowering` | 开花 | 完全盛开 |

### 文件规格

- **格式**：PNG（Godot 原生支持）
- **背景**：透明（alpha channel）
- **尺寸**：每个品种统一尺寸（建议 64×64 或 48×48）
- **风格**：与现有 sprite 保持一致（2D 俯视像素风/扁平卡通）
- **颜色**：严格按 `base_color` 值生成（RGB 参考）

### 批量生成策略

1. **先生成 flowering（开花）** 图作为基础
2. 用 AI 的图生图（img2img）功能，将 flowering 图分别转为其他 4 个阶段
3. silhouette：将 flowering 图转为纯黑白剪影（或用 AI 直接生成）

### 颜色参考（RGB）

```
# 从 plant_data.gd 提取的主要配色
rosy系列: R=210~244, G=80~180, B=100~190 → 粉红系
blue系列: R=50~130, G=80~200, B=200~255 → 蓝紫系
yellow系列: R=240~255, G=179~235, B=0~59 → 黄橙系
white系列: R=240~255, G=240~255, B=224~255 → 白色系
green系列: R=100~200, G=160~230, B=80~150 → 绿色系（多肉/仙人掌）
```

### Silhouette 生成（剪影）

所有新品种都需要一张 silhouette PNG，用作图鉴中"未发现"状态的占位。生成 prompt：
```
"A solid black silhouette of {plant_name}, 2D top-down view, 
on transparent background, completely filled black #000000, 
clean edges, no details inside, game asset silhouette."
```

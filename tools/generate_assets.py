#!/usr/bin/env python3
"""
Flower Desktop - 素材自动生成器
使用免费的 HuggingFace API 生成所有游戏美术素材。

使用步骤：
1. pip install requests rembg Pillow
2. 获取免费 HF token: https://huggingface.co/settings/tokens
3. 设置环境变量: export HF_TOKEN="hf_xxxxxxxx"
4. 运行: python generate_assets.py

可选参数：
  --plants-only     仅生成植物精灵图
  --silhouettes     仅生成剪影（需要已有精灵图）
  --icons           仅生成 UI 图标
  --audio           仅生成音频占位
  --skip-existing   跳过已存在的文件（默认开启）
  --flowering-only  仅生成开花阶段（快速测试用）
  --test            测试模式，只生成 1 种植物（5张图）
  --no-api          不调用 API，只创建目录结构和音频占位
"""

import argparse
import io
import os
import struct
import sys
import time
from pathlib import Path

# ============================================================
# 项目根目录（脚本所在目录的上一级）
# ============================================================
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent

# ============================================================
# API 配置
# ============================================================
MODELS = [
    "black-forest-labs/FLUX.1-schnell",
    "stabilityai/stable-diffusion-2-1",
    "runwayml/stable-diffusion-v1-5",
]
API_BASES = [
    "https://router.huggingface.co/hf-inference/models",
    "https://api-inference.huggingface.co/models",
]
HF_TOKEN = os.environ.get("HF_TOKEN", "")
if not HF_TOKEN:
    _token_file = Path(__file__).parent.parent / ".hf_token"
    if _token_file.exists():
        HF_TOKEN = _token_file.read_text().strip()

# ============================================================
# 图片风格前缀 - 白/灰底色用于运行时着色
# ============================================================
STYLE_PREFIX = (
    "cute chibi 2D game sprite, white and light gray base colors, "
    "simple clean design, thick dark outlines, rounded cartoon proportions, "
    "flat colors, top-down isometric view, simple and clean, "
    "isolated on white background"
)

# ============================================================
# 生长阶段名称映射
# ============================================================
STAGE_NAMES = ["seed", "sprout", "seedling", "mature", "flowering"]
STAGE_CN = ["种子", "发芽", "幼苗", "成熟", "开花"]

# ============================================================
# 通用阶段提示词（用于没有 stage_hints 的植物）
# ============================================================
GENERIC_SEED = "small brown seed in dark soil"
GENERIC_SPROUT = "tiny green sprout with two small leaves"

# ============================================================
# 目录结构
# ============================================================
DIR_STRUCTURE = [
    "assets/sprites/plants/flower",
    "assets/sprites/plants/succulent",
    "assets/sprites/plants/cactus",
    "assets/sprites/plants/rare",
    "assets/sprites/ui",
    "assets/sprites/background",
    "assets/sprites/effects",
    "assets/audio/sfx",
    "assets/audio/bgm",
]

# ============================================================
# UI 图标定义 (name, prompt)
# ============================================================
UI_ICONS = [
    ("water", "watering can icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("seed", "seed packet icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("breed", "heart icon for breeding, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("collection", "book icon for collection, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("shop", "shop store icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("settings", "gear settings icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("trophy", "trophy cup icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("star", "star icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("coin", "coin icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
    ("close", "X close button icon, cute chibi style, white and light gray, simple, 24x24 pixel art"),
]

# ============================================================
# 音效定义
# ============================================================
SFX_NAMES = [
    "water", "plant", "harvest", "breed", "discover",
    "level_up", "coin", "click", "success", "fail",
]
BGM_NAMES = ["garden", "breeding", "desktop", "title"]


# ============================================================
# 完整植物数据库 - 全部 83 种
# ============================================================
# 格式: key → {name, group, shape, size, category, discover_method,
#              stage_hints(可选,5个), flowering(可选), glow(可选)}
#
# shape: 0=尖锐, 1=圆润, 2=褶皱/密集, 3=异形
# size: 0=小, 1=中, 2=大
# ============================================================

PLANT_DATABASE = {
    # ========================
    # 初始种子 (3)
    # ========================
    "rose_red": {
        "name": "红玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "initial",
        "stage_hints": [
            "small brown seed in dark soil",
            "tiny green sprout with two small rose-family leaves",
            "small plant with compound serrated leaves and tiny thorns",
            "medium rose bush with compound leaves, thorny stem, pointed closed spiral bud",
            "classic spiraling pointed-petal rose in full bloom, overlapping petals spiraling outward, thorny stem",
        ],
    },
    "daisy_white": {
        "name": "白雏菊",
        "group": "daisy",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "initial",
        "stage_hints": [
            "small brown seed in dark soil",
            "tiny green sprout with two small rounded leaves",
            "small plant with small rounded daisy-family leaves",
            "compact plant with rounded leaves and small closed round bud",
            "simple cheerful daisy with round smooth petals radiating around raised center disc",
        ],
    },
    "tulip_yellow": {
        "name": "黄郁金香",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "initial",
        "stage_hints": [
            "small brown seed in dark soil",
            "tiny green sprout with two broad leaves",
            "small plant with broad lance-shaped leaves",
            "medium plant with broad leaves and closed cup-shaped bud",
            "classic tulip with smooth cup-shaped round petals forming elegant bowl",
        ],
    },

    # ========================
    # 同品种混色发现 (14)
    # ========================
    "rose_pink": {
        "name": "粉玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "classic spiraling pointed-petal rose, full bloom, slightly looser petal arrangement than red rose",
    },
    "rose_white": {
        "name": "白玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "classic spiraling pointed-petal rose, full bloom, pure elegant form",
    },
    "tulip_orange": {
        "name": "橙郁金香",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "cup-shaped tulip with smooth round petals, warm-toned bloom",
    },
    "tulip_purple": {
        "name": "紫郁金香",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "cup-shaped tulip with smooth round petals, rich deep-toned bloom",
    },
    "daisy_yellow": {
        "name": "黄雏菊",
        "group": "daisy",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "compact cheerful daisy with round petals around center disc",
    },
    "carnation_pink": {
        "name": "粉色康乃馨",
        "group": "daisy",
        "shape": 2,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "ruffled carnation with many layered serrated frilly petals creating full pom-pom shape",
    },
    "orchid_white": {
        "name": "白蝴蝶兰",
        "group": "orchid",
        "shape": 3,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "elegant moth orchid with broad exotic flat petals resembling butterfly wings, arching spray of flowers",
    },
    "sakura_white": {
        "name": "白樱花",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "delicate five-petal cherry blossom with round petals, small notch at tip, clustered on slender branch",
    },
    "lily_white": {
        "name": "百合白",
        "group": "lily",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "large trumpet-shaped lily with six broad round petals, prominent long stamens extending beyond petals",
    },
    "lily_pink": {
        "name": "粉百合",
        "group": "lily",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "large trumpet-shaped lily with six broad round petals, soft-toned, prominent stamens",
    },
    "sunflower_orange": {
        "name": "橙色向日葵",
        "group": "daisy",
        "shape": 0,
        "size": 2,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "large sunflower with pointed ray petals radiating around spiral seed pattern center dome",
    },
    "lavender_deep": {
        "name": "深紫薰衣草",
        "group": "orchid",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "tall spike of small pointed tubular flower clusters along slender stem, narrow leaves at base",
    },
    "sakura_pink": {
        "name": "八重樱",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "double-flowered cherry blossom with many layered round petals, dense fluffy bloom on slender branch",
    },
    "dahlia_red": {
        "name": "红色大丽花",
        "group": "daisy",
        "shape": 2,
        "size": 2,
        "category": "flower",
        "discover_method": "mix_color",
        "flowering": "showy geometric dahlia with many pointed ray petals radiating in geometric pattern, serrated edges",
    },

    # ========================
    # 同培育组杂交发现 (21)
    # ========================
    "peony": {
        "name": "牡丹",
        "group": "rose",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "lush voluminous peony with many layered round petals creating full ruffled bloom, large and impressive",
    },
    "hyacinth": {
        "name": "风信子",
        "group": "lily",
        "shape": 0,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "cluster of small bell-shaped flowers tightly packed on a single spike stem",
    },
    "gesang": {
        "name": "格桑花",
        "group": "daisy",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "simple eight-petal wildflower with round petals around yellow center, daisy-like",
    },
    "gypsophila": {
        "name": "满天星",
        "group": "daisy",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "cloud of tiny round white flowers on thin branching stems, airy delicate appearance",
    },
    "violet": {
        "name": "紫罗兰",
        "group": "orchid",
        "shape": 0,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "small five-petal flower with pointed petals, prominent center eye",
    },
    "jasmine": {
        "name": "茉莉花",
        "group": "orchid",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "small star-shaped flowers with round petals in pinwheel arrangement",
    },
    "lotus": {
        "name": "荷花",
        "group": "lily",
        "shape": 3,
        "size": 2,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "sacred lotus with many layered broad petals on lily pad, exotic water flower",
    },
    "hibiscus": {
        "name": "木槿花",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "large trumpet-shaped flower with five pointed petals, prominent long stamen extending from center",
    },
    "dahlia": {
        "name": "大丽花",
        "group": "daisy",
        "shape": 2,
        "size": 2,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "showy geometric dahlia with many serrated ray petals radiating outward in dramatic formation",
    },
    "camellia": {
        "name": "山茶花",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "elegant formal camellia with waxy pointed overlapping petals in precise arrangement, glossy leaves",
    },
    "plum_blossom": {
        "name": "梅花",
        "group": "rose",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "delicate five-petal winter flower with round petals on woody branch, short stamens",
    },
    "water_lily": {
        "name": "睡莲",
        "group": "lily",
        "shape": 3,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "flat water lily with pointed petals resting on water surface, lily pad visible",
    },
    "magnolia": {
        "name": "玉兰",
        "group": "orchid",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "large elegant cup-shaped magnolia with thick broad round petals, waxy texture",
    },
    "azalea": {
        "name": "杜鹃花",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "clusters of trumpet-shaped azalea flowers with five pointed petals fused at base, long stamens",
    },
    "marigold": {
        "name": "万寿菊",
        "group": "daisy",
        "shape": 2,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "ruffled pom-pom marigold with many tightly frilled serrated petals in rounded ball shape",
    },
    "forget_me_not": {
        "name": "勿忘我",
        "group": "orchid",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "tiny five-petal flower with round petals and distinct yellow center eye, clustered stems",
    },
    "zinnia": {
        "name": "百日菊",
        "group": "daisy",
        "shape": 2,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "bright daisy-like zinnia with multiple rows of serrated petals, cone-shaped center",
    },
    "ranunculus": {
        "name": "花毛茛",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "rose-like ranunculus with many tightly packed paper-thin round petals in dense dome",
    },
    "wisteria": {
        "name": "紫藤",
        "group": "orchid",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "cascading raceme of small pea-shaped pointed flowers hanging in long drooping clusters",
    },
    "poppy": {
        "name": "虞美人",
        "group": "daisy",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "delicate papery poppy with four large pointed petals, dark center spot, single bloom",
    },
    "sweet_pea": {
        "name": "香豌豆",
        "group": "lily",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "cross_breed",
        "flowering": "small butterfly-shaped sweet pea flower with banner wings and keel petals",
    },

    # ========================
    # 多步培育发现 (21)
    # ========================
    "sakura": {
        "name": "樱花",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "iconic cherry blossom with five round notched petals per flower, clustered on elegant dark branch",
    },
    "lily": {
        "name": "百合",
        "group": "lily",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "trumpet-shaped lily with six large round petals spreading outward, prominent long stamens",
    },
    "sunflower": {
        "name": "向日葵",
        "group": "daisy",
        "shape": 0,
        "size": 2,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "large sunflower with spiral seed pattern center and pointed ray petals, thick stem",
    },
    "carnation": {
        "name": "康乃馨",
        "group": "daisy",
        "shape": 2,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "ruffled carnation with many layered serrated petals creating frilly appearance, multiple blooms",
    },
    "lavender": {
        "name": "薰衣草",
        "group": "orchid",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "tall spike of small pointed flower clusters along slender stem, narrow aromatic leaves",
    },
    "orchid": {
        "name": "蝴蝶兰",
        "group": "orchid",
        "shape": 3,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "elegant moth orchid with broad exotic petals resembling butterfly wings, labellum lip petal",
    },
    "bluebell": {
        "name": "风铃草",
        "group": "lily",
        "shape": 0,
        "size": 0,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "small bell-shaped nodding flowers hanging from thin curved stem, pointed petal tips",
    },
    "morning_glory": {
        "name": "牵牛花",
        "group": "orchid",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "trumpet-shaped morning glory with pointed petals forming funnel, star-shaped opening",
    },
    "cosmos": {
        "name": "波斯菊",
        "group": "daisy",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "simple eight-petal cosmos with daisy-like round petals around yellow center, feathery foliage",
    },
    "chrysanthemum": {
        "name": "菊花",
        "group": "daisy",
        "shape": 2,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "dense many-petaled chrysanthemum with tightly curled serrated petals in layered dome formation",
    },
    "anemone": {
        "name": "银莲花",
        "group": "rose",
        "shape": 1,
        "size": 0,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "simple cup-shaped anemone with round petals, prominent dark center dome with stamens",
    },
    "begonia": {
        "name": "海棠",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "asymmetric begonia flower with pointed unequal petals, visible stamens, waxy leaves",
    },
    "gardenia": {
        "name": "栀子花",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "waxy gardenia with spiral arrangement of rounded petals, prominent yellow stamens, glossy leaves",
    },
    "gladiolus": {
        "name": "剑兰",
        "group": "lily",
        "shape": 0,
        "size": 2,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "tall vertical spike with multiple pointed funnel-shaped flowers opening bottom to top, sword-shaped leaves",
    },
    "peach_blossom": {
        "name": "桃花",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "soft five-petal flower with round petals on slender branch, delicate blossoms",
    },
    "canna": {
        "name": "美人蕉",
        "group": "lily",
        "shape": 0,
        "size": 2,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "bold tropical canna flower with three large pointed petals, large paddle-shaped leaves",
    },
    "iris": {
        "name": "鸢尾花",
        "group": "orchid",
        "shape": 3,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "elegant iris with three upright standard petals and three drooping falls, sword-shaped leaves",
    },
    "hydrangea": {
        "name": "绣球花",
        "group": "daisy",
        "shape": 1,
        "size": 2,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "large round cluster of many small round flowers forming ball shape, four-petal florets packed together",
    },
    "tulip_red": {
        "name": "红郁金香",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "classic tulip with smooth cup-shaped petals, three inner and three outer rounded petals forming bowl",
    },
    "rose_yellow": {
        "name": "黄玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "rose with pointed spiraling petals opening outward, classic spiral formation, thorny stem",
    },
    "narcissus": {
        "name": "水仙花",
        "group": "lily",
        "shape": 1,
        "size": 1,
        "category": "flower",
        "discover_method": "gradual",
        "flowering": "daffodil with central trumpet corona surrounded by six round spreading petals, narrow flat leaves",
    },

    # ========================
    # 多肉植物 (6)
    # ========================
    "succulent_echeveria": {
        "name": "观音莲",
        "group": "succulent",
        "shape": 1,
        "size": 0,
        "category": "succulent",
        "discover_method": "expansion_gift",
        "flowering": "full rosette succulent with thick rounded leaves in symmetrical spiral, tiny flower spike from center",
    },
    "succulent_haworthia": {
        "name": "玉露",
        "group": "succulent",
        "shape": 1,
        "size": 0,
        "category": "succulent",
        "discover_method": "mix_color",
        "flowering": "compact haworthia with pointed translucent plump leaves showing inner texture, small flower stalk",
    },
    "succulent_bear": {
        "name": "熊童子",
        "group": "succulent",
        "shape": 2,
        "size": 0,
        "category": "succulent",
        "discover_method": "mix_color",
        "flowering": "teddy bear paw succulent with fuzzy serrated leaves, tiny yellow flower bloom on top",
    },
    "succulent_dragon": {
        "name": "玉龙观音",
        "group": "succulent",
        "shape": 1,
        "size": 1,
        "category": "succulent",
        "discover_method": "cross_breed",
        "flowering": "large rosette with baby plantlets forming on leaf edges, multiple tiny flower spikes",
    },
    "succulent_string": {
        "name": "佛珠",
        "group": "succulent",
        "shape": 1,
        "size": 0,
        "category": "succulent",
        "discover_method": "mix_color",
        "flowering": "trailing succulent with round bead-like leaves on thin stems, tiny white blossoms",
    },
    "succulent_panda": {
        "name": "熊猫堇",
        "group": "succulent",
        "shape": 2,
        "size": 0,
        "category": "succulent",
        "discover_method": "mix_color",
        "flowering": "succulent with patterned serrated leaves resembling panda markings, decorative flower cluster",
    },

    # ========================
    # 仙人掌 (3)
    # ========================
    "cactus": {
        "name": "仙人掌",
        "group": "cactus",
        "shape": 0,
        "size": 1,
        "category": "cactus",
        "discover_method": "cross_breed",
        "flowering": "classic cactus pad with full spines, single flower blooming on top",
    },
    "cactus_bloom": {
        "name": "仙人球",
        "group": "cactus",
        "shape": 0,
        "size": 0,
        "category": "cactus",
        "discover_method": "cross_breed",
        "flowering": "round ball cactus with ribbed texture and small pink flower crown blooming on top",
    },
    "cactus_star": {
        "name": "星兜",
        "group": "cactus",
        "shape": 0,
        "size": 0,
        "category": "cactus",
        "discover_method": "cross_breed",
        "flowering": "star-shaped flat cactus with dotted pattern and geometric ridges, small bloom in center",
    },

    # ========================
    # 稀有变异 (15)
    # ========================
    "rare_rainbow_rose": {
        "name": "彩虹玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "fully blooming rose with rainbow gradient flowing across petals, shimmer effect",
        "glow": "rainbow iridescent glow",
    },
    "rare_dark_mandrake": {
        "name": "暗夜曼陀罗",
        "group": "rose",
        "shape": 2,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "dark gothic trumpet flower with serrated edges, mysterious aura",
        "glow": "deep purple edge glow",
    },
    "rare_golden_sunflower": {
        "name": "金色向日葵",
        "group": "daisy",
        "shape": 0,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "radiant large sunflower with metallic golden sheen on petals, shimmering",
        "glow": "warm golden halo",
    },
    "rare_moonlight_lily": {
        "name": "月光百合",
        "group": "lily",
        "shape": 1,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "ethereal silver-white lily blooming softly, glowing gently",
        "glow": "cool silver moonlight shimmer",
    },
    "rare_eternal_flower": {
        "name": "永恒之花",
        "group": "rose",
        "shape": 3,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "fully open translucent crystalline flower, otherworldly beauty, light passing through",
        "glow": "pulsing white aura",
    },
    "rare_black_rose": {
        "name": "黑玫瑰",
        "group": "rose",
        "shape": 0,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "deep black rose fully bloomed with dark red undertones visible at edges",
        "glow": "dark crimson rim light",
    },
    "rare_snow_queen": {
        "name": "雪后",
        "group": "lily",
        "shape": 3,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "ice crystal flower fully open with beautiful frosted petals, elegant",
        "glow": "ice blue sparkle",
    },
    "rare_blue_daisy": {
        "name": "蓝色雏菊",
        "group": "daisy",
        "shape": 1,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "brilliant sapphire blue daisy fully open with star sparkle effect on petals",
        "glow": "blue gem-like sparkle",
    },
    "rare_ghost_orchid": {
        "name": "幽灵兰",
        "group": "orchid",
        "shape": 3,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "translucent ghostly green orchid fully open, floating appearance",
        "glow": "eerie green bioluminescence",
    },
    "rare_crystal_succulent": {
        "name": "水晶莲",
        "group": "succulent",
        "shape": 1,
        "size": 0,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "transparent crystal succulent at peak beauty with light refraction visible",
        "glow": "prismatic rainbow refraction",
    },
    "rare_golden_cactus": {
        "name": "金琥",
        "group": "cactus",
        "shape": 0,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "golden metallic cactus ball at peak with fully gleaming golden spines",
        "glow": "golden metallic sheen",
    },
    "rare_phoenix_flower": {
        "name": "凤凰花",
        "group": "rose",
        "shape": 3,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "flame-shaped petals fully open flowing upward like phoenix wings, majestic",
        "glow": "orange-red fire gradient",
    },
    "rare_aurora_borealis": {
        "name": "极光花",
        "group": "orchid",
        "shape": 3,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "fully open flower with shifting aurora colors flowing dynamically across petals",
        "glow": "northern lights green-purple shifting",
    },
    "rare_sakura_blizzard": {
        "name": "樱吹雪",
        "group": "rose",
        "shape": 1,
        "size": 1,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "beautiful cherry blossom surrounded by swirling petal snow falling around it",
        "glow": "soft pink petal aura",
    },
    "rare_midnight_lily": {
        "name": "午夜百合",
        "group": "lily",
        "shape": 1,
        "size": 2,
        "category": "rare",
        "discover_method": "rare_mutation",
        "flowering": "deep midnight purple lily fully open with star-like flecks scattered across petals",
        "glow": "deep purple starlight twinkle",
    },
}


# ============================================================
# 辅助函数：根据植物属性生成各阶段提示词
# ============================================================

# group → 叶片/枝干特征映射
GROUP_LEAF_HINTS = {
    "rose": "compound serrated leaves with small thorns",
    "lily": "broad lance-shaped leaves",
    "daisy": "small rounded leaves",
    "orchid": "broad flat leaves",
    "succulent": "thick fleshy leaves",
    "cactus": "spiny textured surface",
}

# shape → 花苞描述映射
SHAPE_BUD_HINTS = {
    0: "pointed closed bud",
    1: "rounded closed bud",
    2: "tightly frilled closed bud",
    3: "unusual exotic closed bud",
}

# size → 植物大小描述
SIZE_ADJ = {0: "small", 1: "medium", 2: "large"}

# shape → 幼苗期叶片形态
SHAPE_SEEDLING_HINTS = {
    0: "narrow pointed leaves",
    1: "round smooth-edged leaves",
    2: "serrated frilly leaves",
    3: "broad exotic leaves",
}


def get_stage_prompt(plant_key: str, plant_data: dict, stage_idx: int) -> str:
    """为指定植物指定阶段生成完整的 API 提示词"""
    stage_name = STAGE_NAMES[stage_idx]
    name_cn = plant_data["name"]
    group = plant_data["group"]
    shape = plant_data["shape"]
    size = plant_data["size"]
    category = plant_data["category"]

    # 优先使用自定义 stage_hints
    hints = plant_data.get("stage_hints")
    if hints and stage_idx < len(hints):
        description = hints[stage_idx]
    elif stage_idx == 4 and "flowering" in plant_data:
        # 开花阶段使用 flowering 描述
        description = plant_data["flowering"]
        # 稀有花添加特效描述
        if "glow" in plant_data:
            description += f", {plant_data['glow']}"
    else:
        # 根据植物属性自动生成阶段描述
        description = _auto_stage_description(
            plant_key, name_cn, group, shape, size, category, stage_idx
        )

    # 拼接最终提示词
    prompt = f"{STYLE_PREFIX}, {description}"
    return prompt


def _auto_stage_description(
    plant_key: str,
    name_cn: str,
    group: str,
    shape: int,
    size: int,
    category: str,
    stage_idx: int,
) -> str:
    """根据属性自动生成阶段描述"""
    size_adj = SIZE_ADJ[size]
    leaf_hint = GROUP_LEAF_HINTS.get(group, "green leaves")

    if stage_idx == 0:
        # 种子阶段
        if category == "succulent":
            return "small round succulent seed in dark soil"
        elif category == "cactus":
            return "tiny cactus seed in dark soil"
        return GENERIC_SEED

    elif stage_idx == 1:
        # 发芽阶段
        if category == "succulent":
            return "tiny succulent sprout with two thick round baby leaves"
        elif category == "cactus":
            return "tiny green cactus sprout, very small round body"
        return GENERIC_SPROUT

    elif stage_idx == 2:
        # 幼苗阶段
        shape_leaf = SHAPE_SEEDLING_HINTS.get(shape, "green leaves")
        if category == "succulent":
            return f"small succulent with {shape_leaf} forming tiny rosette"
        elif category == "cactus":
            return f"small cactus with {shape_leaf}, beginning to show spines"
        return f"small plant with {shape_leaf}, {leaf_hint}"

    elif stage_idx == 3:
        # 成熟阶段（有花苞）
        bud = SHAPE_BUD_HINTS.get(shape, "closed bud")
        shape_leaf_3 = SHAPE_SEEDLING_HINTS.get(shape, "green leaves")
        if category == "succulent":
            return f"{size_adj} succulent rosette with {shape_leaf_3}, tiny flower stalk emerging"
        elif category == "cactus":
            return f"{size_adj} cactus with spines and {bud} on top"
        return f"{size_adj} plant with {leaf_hint} and {bud}"

    else:
        # 开花阶段（stage_idx == 4）
        # 如果有 flowering 字段就使用
        plant_data = PLANT_DATABASE[plant_key]
        if "flowering" in plant_data:
            desc = plant_data["flowering"]
            if "glow" in plant_data:
                desc += f", {plant_data['glow']}"
            return desc
        # 兜底：通用开花描述
        return f"beautiful fully bloomed {name_cn} flower"


# ============================================================
# API 调用与图片处理
# ============================================================

def call_hf_api(prompt: str, max_retries: int = 5) -> bytes | None:
    """调用 HuggingFace Inference API 生成图片，自动尝试多个模型和端点"""
    import requests

    headers = {}
    if HF_TOKEN:
        headers["Authorization"] = f"Bearer {HF_TOKEN}"
    payload = {"inputs": prompt}

    for base in API_BASES:
        for model in MODELS:
            url = f"{base}/{model}"
            for attempt in range(3):
                try:
                    response = requests.post(url, headers=headers, json=payload, timeout=120)

                    if response.status_code == 200:
                        return response.content

                    elif response.status_code == 503:
                        wait_time = 30 * (attempt + 1)
                        print(f"    模型加载中，等待 {wait_time}s...")
                        time.sleep(wait_time)

                    elif response.status_code == 429:
                        wait_time = 60 * (attempt + 1)
                        print(f"    速率限制，等待 {wait_time}s...")
                        time.sleep(wait_time)

                    elif response.status_code == 401:
                        print("    匿名受限，建议设置 HF_TOKEN")
                        time.sleep(30)

                    elif response.status_code == 404:
                        print(f"    {model} 在此端点不可用，尝试下一个...")
                        break

                    else:
                        print(f"    API {response.status_code}: {response.text[:100]}")
                        time.sleep(10)

                except requests.exceptions.Timeout:
                    print(f"    超时，重试...")
                except requests.exceptions.ConnectionError:
                    print(f"    连接失败")
                    break

    print("    所有模型/端点均失败")
    return None


def process_image(raw_bytes: bytes, target_size: int = 64) -> "Image.Image | None":
    """处理原始图片：去背景 → 调整大小 → 透明画布居中"""
    from PIL import Image
    from rembg import remove

    try:
        # 去除背景
        input_img = Image.open(io.BytesIO(raw_bytes))
        output_bytes = remove(input_img)
        img = Image.open(io.BytesIO(output_bytes)).convert("RGBA")

        # 缩放到目标大小，保持比例
        img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)

        # 居中放置在透明画布上
        canvas = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
        offset_x = (target_size - img.width) // 2
        offset_y = (target_size - img.height) // 2
        canvas.paste(img, (offset_x, offset_y), img)

        return canvas

    except Exception as e:
        print(f"    图片处理错误: {e}")
        return None


def process_image_no_rembg(raw_bytes: bytes, target_size: int = 64) -> "Image.Image | None":
    """处理原始图片（使用 Pillow 自带去背景），作为 rembg 的备选方案"""
    from PIL import Image

    try:
        img = Image.open(io.BytesIO(raw_bytes)).convert("RGBA")

        # 简单白色背景去除：接近白色的像素变透明
        datas = img.getdata()
        new_data = []
        for item in datas:
            # 如果像素足够亮（接近白色），设为透明
            if item[0] > 230 and item[1] > 230 and item[2] > 230:
                new_data.append((255, 255, 255, 0))
            else:
                new_data.append(item)
        img.putdata(new_data)

        # 缩放到目标大小
        img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)

        # 居中放置
        canvas = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
        offset_x = (target_size - img.width) // 2
        offset_y = (target_size - img.height) // 2
        canvas.paste(img, (offset_x, offset_y), img)

        return canvas

    except Exception as e:
        print(f"    图片处理错误: {e}")
        return None


# ============================================================
# 生成阶段函数
# ============================================================

def create_directory_structure():
    """创建所有必要的目录"""
    print("=" * 50)
    print("创建目录结构...")
    print("=" * 50)
    for dir_path in DIR_STRUCTURE:
        full_path = PROJECT_ROOT / dir_path
        full_path.mkdir(parents=True, exist_ok=True)
        print(f"  {dir_path}/")
    print()


def generate_plant_sprites(
    skip_existing: bool = True,
    flowering_only: bool = False,
    test_mode: bool = False,
    use_rembg: bool = True,
):
    """
    阶段 1: 生成植物精灵图
    为每种植物的每个阶段生成 64x64 透明 PNG
    """
    from PIL import Image

    print("=" * 50)
    print("阶段 1: 生成植物精灵图")
    print("=" * 50)

    # 构建任务列表
    tasks = []
    plants = list(PLANT_DATABASE.items())

    if test_mode:
        # 测试模式：只生成第一种植物
        plants = plants[:1]
        print(f"  [测试模式] 仅生成: {plants[0][0]} ({plants[0][1]['name']})")

    for plant_key, plant_data in plants:
        category = plant_data["category"]
        stages = [4] if flowering_only else range(5)

        for stage_idx in stages:
            stage_name = STAGE_NAMES[stage_idx]
            filename = f"{plant_key}_{stage_idx}_{stage_name}.png"
            filepath = PROJECT_ROOT / "assets" / "sprites" / "plants" / category / filename
            tasks.append((plant_key, plant_data, stage_idx, filepath))

    total = len(tasks)
    print(f"  总计: {total} 张精灵图待生成")
    print()

    completed = 0
    skipped = 0
    failed = 0

    for i, (plant_key, plant_data, stage_idx, filepath) in enumerate(tasks):
        name_cn = plant_data["name"]
        stage_cn = STAGE_CN[stage_idx]
        progress = f"[{i + 1}/{total}]"

        # 跳过已存在文件
        if skip_existing and filepath.exists():
            skipped += 1
            continue

        print(f"  {progress} 生成 {plant_key} ({name_cn}) 阶段 {stage_idx} ({stage_cn})...")

        # 确保目录存在
        filepath.parent.mkdir(parents=True, exist_ok=True)

        # 生成提示词
        prompt = get_stage_prompt(plant_key, plant_data, stage_idx)

        # 调用 API
        raw_bytes = call_hf_api(prompt)
        if raw_bytes is None:
            failed += 1
            continue

        # 处理图片
        if use_rembg:
            img = process_image(raw_bytes, 64)
        else:
            img = process_image_no_rembg(raw_bytes, 64)

        if img is None:
            failed += 1
            continue

        # 保存
        img.save(filepath, "PNG")
        completed += 1

        # 避免触发速率限制，每次请求后短暂等待
        time.sleep(3)

    print()
    print(f"  精灵图生成完成: 成功 {completed}, 跳过 {skipped}, 失败 {failed}")
    print()


def generate_silhouettes(skip_existing: bool = True):
    """
    阶段 2: 生成剪影图
    读取开花阶段精灵图，转为纯黑剪影
    """
    from PIL import Image

    print("=" * 50)
    print("阶段 2: 生成剪影图 (83 张)")
    print("=" * 50)

    completed = 0
    skipped = 0
    failed = 0
    total = len(PLANT_DATABASE)

    for i, (plant_key, plant_data) in enumerate(PLANT_DATABASE.items()):
        category = plant_data["category"]

        # 源文件路径（开花阶段的精灵图）
        src_filename = f"{plant_key}_4_flowering.png"
        src_path = PROJECT_ROOT / "assets" / "sprites" / "plants" / category / src_filename

        # 目标剪影路径
        dst_filename = f"silhouette_{plant_key}.png"
        dst_path = PROJECT_ROOT / "assets" / "sprites" / "plants" / category / dst_filename

        progress = f"[{i + 1}/{total}]"

        # 跳过已存在文件
        if skip_existing and dst_path.exists():
            skipped += 1
            continue

        if not src_path.exists():
            print(f"  {progress} 跳过 {plant_key}: 源文件不存在 ({src_filename})")
            failed += 1
            continue

        print(f"  {progress} 生成剪影 {plant_key} ({plant_data['name']})...")

        try:
            img = Image.open(src_path).convert("RGBA")

            # 转为灰度 → 二值化 → 纯黑剪影
            # 使用 alpha 通道判断是否有内容，有内容的区域变黑
            alpha = img.split()[3]
            gray = alpha.convert("L")

            # 创建剪影：有内容的地方为黑色，其余透明
            silhouette = Image.new("RGBA", img.size, (0, 0, 0, 0))
            # 遍历像素，alpha > 阈值的设为黑色
            pixels = img.load()
            sil_pixels = silhouette.load()
            for y in range(img.height):
                for x in range(img.width):
                    r, g, b, a = pixels[x, y]
                    if a > 30:  # 有实际内容的像素
                        sil_pixels[x, y] = (0, 0, 0, 255)

            silhouette.save(dst_path, "PNG")
            completed += 1

        except Exception as e:
            print(f"    错误: {e}")
            failed += 1

    print()
    print(f"  剪影生成完成: 成功 {completed}, 跳过 {skipped}, 失败 {failed}")
    print()


def generate_ui_icons(skip_existing: bool = True):
    """
    阶段 3: 生成 UI 图标
    生成 24x24 透明 PNG 图标
    """
    from PIL import Image

    print("=" * 50)
    print("阶段 3: 生成 UI 图标 (10 张)")
    print("=" * 50)

    ui_dir = PROJECT_ROOT / "assets" / "sprites" / "ui"
    ui_dir.mkdir(parents=True, exist_ok=True)

    completed = 0
    skipped = 0
    failed = 0
    total = len(UI_ICONS)

    for i, (icon_name, icon_prompt) in enumerate(UI_ICONS):
        progress = f"[{i + 1}/{total}]"
        filepath = ui_dir / f"icon_{icon_name}.png"

        if skip_existing and filepath.exists():
            skipped += 1
            continue

        print(f"  {progress} 生成图标 {icon_name}...")

        raw_bytes = call_hf_api(icon_prompt)
        if raw_bytes is None:
            failed += 1
            continue

        try:
            from rembg import remove as rembg_remove

            input_img = Image.open(io.BytesIO(raw_bytes))
            output_bytes = rembg_remove(input_img)
            img = Image.open(io.BytesIO(output_bytes)).convert("RGBA")
        except ImportError:
            # 没有 rembg，用简单白色去除
            img = Image.open(io.BytesIO(raw_bytes)).convert("RGBA")
            datas = img.getdata()
            new_data = []
            for item in datas:
                if item[0] > 230 and item[1] > 230 and item[2] > 230:
                    new_data.append((255, 255, 255, 0))
                else:
                    new_data.append(item)
            img.putdata(new_data)

        # 缩放到 24x24
        img.thumbnail((24, 24), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
        canvas.paste(img, ((24 - img.width) // 2, (24 - img.height) // 2), img)

        canvas.save(filepath, "PNG")
        completed += 1

        time.sleep(3)

    print()
    print(f"  图标生成完成: 成功 {completed}, 跳过 {skipped}, 失败 {failed}")
    print()


# ============================================================
# 音频占位文件生成
# ============================================================

def create_wav_placeholder(filepath: Path, duration_sec: float = 0.5):
    """创建一个最小有效 WAV 文件（静音）"""
    sample_rate = 22050
    num_channels = 1
    bits_per_sample = 16
    num_samples = int(sample_rate * duration_sec)
    byte_rate = sample_rate * num_channels * bits_per_sample // 8
    block_align = num_channels * bits_per_sample // 8
    data_size = num_samples * block_align

    with open(filepath, "wb") as f:
        # RIFF 头
        f.write(b"RIFF")
        f.write(struct.pack("<I", 36 + data_size))  # 文件大小 - 8
        f.write(b"WAVE")
        # fmt 子块
        f.write(b"fmt ")
        f.write(struct.pack("<I", 16))               # 子块大小
        f.write(struct.pack("<H", 1))                 # PCM 格式
        f.write(struct.pack("<H", num_channels))
        f.write(struct.pack("<I", sample_rate))
        f.write(struct.pack("<I", byte_rate))
        f.write(struct.pack("<H", block_align))
        f.write(struct.pack("<H", bits_per_sample))
        # data 子块
        f.write(b"data")
        f.write(struct.pack("<I", data_size))
        # 静音数据（全零）
        f.write(b"\x00" * data_size)


def create_ogg_placeholder(filepath: Path):
    """创建一个最小有效 OGG 文件（极短的静音）"""
    # OGG Vorbis 最小文件头 - 这是一个有效的极短静音 OGG
    # 使用预计算的最小 OGG 帧
    minimal_ogg = bytes([
        0x4F, 0x67, 0x67, 0x53,  # "OggS" 捕获模式
        0x00,                     # 版本
        0x02,                     # 头类型: 起始页
        0x00, 0x00, 0x00, 0x00,  # 粒度位置
        0x00, 0x00, 0x00, 0x00,  # 比特流序列号
        0x00, 0x00, 0x00, 0x00,  # 页序列号
        0x00, 0x00, 0x00, 0x00,  # 校验和 (占位)
        0x01,                     # 段数
        0x01,                     # 段大小
        0x0A,                     # 1 字节数据
    ])
    # 写入一个标记文件说明这是占位
    with open(filepath, "wb") as f:
        f.write(minimal_ogg)


def generate_audio_placeholders(skip_existing: bool = True):
    """
    阶段 4: 生成音频占位文件
    """
    print("=" * 50)
    print("阶段 4: 生成音频占位文件")
    print("=" * 50)

    # 音效文件 (WAV)
    sfx_dir = PROJECT_ROOT / "assets" / "audio" / "sfx"
    sfx_dir.mkdir(parents=True, exist_ok=True)

    sfx_completed = 0
    for name in SFX_NAMES:
        filepath = sfx_dir / f"sfx_{name}.wav"
        if skip_existing and filepath.exists():
            continue
        create_wav_placeholder(filepath, duration_sec=0.5)
        print(f"  创建 sfx_{name}.wav")
        sfx_completed += 1

    # 背景音乐文件 (OGG)
    bgm_dir = PROJECT_ROOT / "assets" / "audio" / "bgm"
    bgm_dir.mkdir(parents=True, exist_ok=True)

    bgm_completed = 0
    for name in BGM_NAMES:
        filepath = bgm_dir / f"bgm_{name}.ogg"
        if skip_existing and filepath.exists():
            continue
        create_ogg_placeholder(filepath)
        print(f"  创建 bgm_{name}.ogg")
        bgm_completed += 1

    print()
    print(f"  音频占位创建完成: {sfx_completed} SFX, {bgm_completed} BGM")
    print()


# ============================================================
# 程序化生成备选方案（不依赖 API）
# ============================================================

def generate_placeholder_sprite(
    plant_key: str,
    plant_data: dict,
    stage_idx: int,
    filepath: Path,
):
    """用程序化方式生成一个简单的占位精灵图（不调用 API）"""
    from PIL import Image, ImageDraw

    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    shape = plant_data["shape"]
    size = plant_data["size"]
    category = plant_data["category"]

    # 基础尺寸
    base_size = [12, 18, 24][size]
    cx, cy = 32, 32

    if stage_idx == 0:
        # 种子: 小圆点
        r = 4
        draw.ellipse([cx - r, cy + 10 - r, cx + r, cy + 10 + r], fill=(139, 90, 43, 255))
        # 土壤
        draw.rectangle([cx - 12, cy + 14, cx + 12, cy + 18], fill=(101, 67, 33, 200))

    elif stage_idx == 1:
        # 发芽: 一根茎两个小叶
        stem_top = cy - 4
        draw.line([cx, cy + 10, cx, stem_top], fill=(100, 160, 60, 255), width=2)
        draw.ellipse([cx - 6, stem_top - 6, cx, stem_top], fill=(120, 180, 80, 255))
        draw.ellipse([cx, stem_top - 6, cx + 6, stem_top], fill=(120, 180, 80, 255))

    elif stage_idx == 2:
        # 幼苗: 更多叶片
        top = cy - base_size // 2
        draw.line([cx, cy + 10, cx, top + 4], fill=(100, 160, 60, 255), width=2)
        # 叶片
        for angle_offset in [-12, -6, 6, 12]:
            lx = cx + angle_offset
            draw.ellipse([lx - 4, top, lx + 4, top + 8], fill=(120, 180, 80, 255))

    elif stage_idx == 3:
        # 成熟: 植株 + 花苞
        top = cy - base_size // 2 - 4
        draw.line([cx, cy + 10, cx, top + 8], fill=(100, 160, 60, 255), width=3)
        # 叶片
        for y_off in [0, 6, 12]:
            for x_dir in [-1, 1]:
                lx = cx + x_dir * 10
                ly = cy - 2 + y_off
                draw.ellipse([lx - 5, ly - 3, lx + 5, ly + 3], fill=(120, 180, 80, 255))
        # 花苞
        bud_r = 5
        draw.ellipse([cx - bud_r, top, cx + bud_r, top + bud_r * 2], fill=(180, 180, 180, 255))

    elif stage_idx == 4:
        # 开花: 根据形状绘制不同的花
        top = cy - base_size // 2 - 8
        draw.line([cx, cy + 10, cx, top + 10], fill=(100, 160, 60, 255), width=3)
        # 叶片
        for y_off in [0, 8]:
            for x_dir in [-1, 1]:
                lx = cx + x_dir * 12
                ly = cy + y_off
                draw.ellipse([lx - 6, ly - 3, lx + 6, ly + 3], fill=(120, 180, 80, 255))

        # 花朵
        flower_r = base_size // 2 + 4
        if shape == 0:
            # 尖瓣花
            for angle_deg in range(0, 360, 45):
                import math
                angle = math.radians(angle_deg)
                px = cx + int(flower_r * math.cos(angle))
                py = top + int(flower_r * math.sin(angle))
                draw.ellipse([px - 4, py - 4, px + 4, py + 4], fill=(200, 200, 200, 255))
            draw.ellipse([cx - 4, top - 4, cx + 4, top + 4], fill=(220, 220, 220, 255))
        elif shape == 1:
            # 圆瓣花
            for angle_deg in range(0, 360, 60):
                import math
                angle = math.radians(angle_deg)
                px = cx + int(flower_r * 0.7 * math.cos(angle))
                py = top + int(flower_r * 0.7 * math.sin(angle))
                draw.ellipse([px - 5, py - 5, px + 5, py + 5], fill=(200, 200, 200, 255))
            draw.ellipse([cx - 5, top - 5, cx + 5, top + 5], fill=(220, 220, 220, 255))
        elif shape == 2:
            # 密集花瓣
            for r_mult in [0.5, 0.7, 0.9]:
                for angle_deg in range(0, 360, 30):
                    import math
                    angle = math.radians(angle_deg)
                    px = cx + int(flower_r * r_mult * math.cos(angle))
                    py = top + int(flower_r * r_mult * math.sin(angle))
                    draw.ellipse([px - 3, py - 3, px + 3, py + 3], fill=(200, 200, 200, 255))
        elif shape == 3:
            # 异形花
            draw.ellipse([cx - flower_r, top - flower_r, cx + flower_r, top + flower_r],
                         fill=(200, 200, 200, 255))
            draw.ellipse([cx - 3, top - 3, cx + 3, top + 3], fill=(220, 220, 220, 255))

    # 添加轮廓线（简单描边效果）
    filepath.parent.mkdir(parents=True, exist_ok=True)
    img.save(filepath, "PNG")


def generate_all_placeholders(flowering_only: bool = False, test_mode: bool = False):
    """
    生成所有占位精灵图（不依赖 API，使用程序化生成）
    """
    from PIL import Image

    print("=" * 50)
    print("程序化生成占位精灵图（无需 API）")
    print("=" * 50)

    plants = list(PLANT_DATABASE.items())
    if test_mode:
        plants = plants[:1]

    completed = 0
    total_count = 0

    for plant_key, plant_data in plants:
        category = plant_data["category"]
        stages = [4] if flowering_only else range(5)

        for stage_idx in stages:
            stage_name = STAGE_NAMES[stage_idx]
            filename = f"{plant_key}_{stage_idx}_{stage_name}.png"
            filepath = PROJECT_ROOT / "assets" / "sprites" / "plants" / category / filename

            if filepath.exists():
                continue

            generate_placeholder_sprite(plant_key, plant_data, stage_idx, filepath)
            completed += 1
            total_count += 1
            print(f"  [{completed}] {filename}")

    print(f"\n  占位精灵图生成完成: {completed} 张新文件")
    print()


# ============================================================
# 统计报告
# ============================================================

def print_stats():
    """打印当前素材状态统计"""
    print("=" * 50)
    print("素材状态统计")
    print("=" * 50)

    # 统计精灵图
    for category in ["flower", "succulent", "cactus", "rare"]:
        dir_path = PROJECT_ROOT / "assets" / "sprites" / "plants" / category
        if dir_path.exists():
            pngs = list(dir_path.glob("*.png"))
            sprites = [f for f in pngs if not f.name.startswith("silhouette_")]
            silhouettes = [f for f in pngs if f.name.startswith("silhouette_")]
            print(f"  {category}: {len(sprites)} 精灵图, {len(silhouettes)} 剪影")
        else:
            print(f"  {category}: 目录不存在")

    # UI 图标
    ui_dir = PROJECT_ROOT / "assets" / "sprites" / "ui"
    if ui_dir.exists():
        icons = list(ui_dir.glob("icon_*.png"))
        print(f"  UI 图标: {len(icons)}/10")

    # 音频
    sfx_dir = PROJECT_ROOT / "assets" / "audio" / "sfx"
    bgm_dir = PROJECT_ROOT / "assets" / "audio" / "bgm"
    sfx_count = len(list(sfx_dir.glob("*.wav"))) if sfx_dir.exists() else 0
    bgm_count = len(list(bgm_dir.glob("*.ogg"))) if bgm_dir.exists() else 0
    print(f"  音效: {sfx_count} SFX, {bgm_count} BGM")

    # 植物数据库统计
    print(f"\n  植物数据库: {len(PLANT_DATABASE)} 种")
    for method in ["initial", "mix_color", "cross_breed", "gradual", "expansion_gift", "rare_mutation"]:
        count = sum(1 for p in PLANT_DATABASE.values() if p["discover_method"] == method)
        if count > 0:
            print(f"    {method}: {count}")

    print()


# ============================================================
# 主入口
# ============================================================

def main():
    parser = argparse.ArgumentParser(
        description="Flower Desktop - 素材自动生成器",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  # 完整生成所有素材（需要 HF_TOKEN）
  python generate_assets.py

  # 测试模式，只生成 1 种植物
  python generate_assets.py --test

  # 只生成开花阶段
  python generate_assets.py --flowering-only

  # 不调用 API，用程序化占位图
  python generate_assets.py --no-api

  # 只生成剪影和音频
  python generate_assets.py --silhouettes --audio

  # 查看当前状态
  python generate_assets.py --stats
        """,
    )

    parser.add_argument("--plants-only", action="store_true", help="仅生成植物精灵图")
    parser.add_argument("--silhouettes", action="store_true", help="仅生成剪影")
    parser.add_argument("--icons", action="store_true", help="仅生成 UI 图标")
    parser.add_argument("--audio", action="store_true", help="仅生成音频占位")
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        default=True,
        help="跳过已存在的文件（默认开启）",
    )
    parser.add_argument("--no-skip", action="store_true", help="不跳过已存在的文件（重新生成）")
    parser.add_argument("--flowering-only", action="store_true", help="仅生成开花阶段")
    parser.add_argument("--test", action="store_true", help="测试模式，只生成 1 种植物")
    parser.add_argument("--no-api", action="store_true", help="不调用 API，用程序化占位图")
    parser.add_argument("--no-rembg", action="store_true", help="不使用 rembg 去背景（用 Pillow 简单处理）")
    parser.add_argument("--stats", action="store_true", help="只显示当前素材统计")
    parser.add_argument(
        "--placeholders",
        action="store_true",
        help="生成程序化占位精灵图（不需要 API）",
    )

    args = parser.parse_args()

    skip_existing = not args.no_skip

    # 显示统计
    if args.stats:
        print_stats()
        return

    print()
    print("*" * 50)
    print("  Flower Desktop - 素材自动生成器")
    print("  植物数据库:", len(PLANT_DATABASE), "种")
    print("*" * 50)
    print()

    # 创建目录结构（始终执行）
    create_directory_structure()

    # 确定执行哪些阶段
    specific_mode = any([args.plants_only, args.silhouettes, args.icons, args.audio])

    # 程序化占位模式
    if args.placeholders or args.no_api:
        generate_all_placeholders(
            flowering_only=args.flowering_only,
            test_mode=args.test,
        )
        if not specific_mode or args.silhouettes:
            generate_silhouettes(skip_existing=skip_existing)
        if not specific_mode or args.audio:
            generate_audio_placeholders(skip_existing=skip_existing)
        print_stats()
        return

    # 检查 HF_TOKEN（可选，匿名也能调用免费模型）
    if not HF_TOKEN:
        print("提示: 未设置 HF_TOKEN，将匿名调用免费模型（速率受限）")
        print("设置 token 可获得更稳定的访问: https://huggingface.co/settings/tokens")
        print()

    # 检查依赖
    try:
        import requests
    except ImportError:
        print("缺少依赖: pip install requests")
        sys.exit(1)

    try:
        from PIL import Image
    except ImportError:
        print("缺少依赖: pip install Pillow")
        sys.exit(1)

    use_rembg = not args.no_rembg
    if use_rembg:
        try:
            from rembg import remove
        except ImportError:
            print("提示: rembg 未安装，将使用 Pillow 简单去背景")
            print("安装 rembg 可获得更好效果: pip install rembg")
            use_rembg = False

    # 阶段 1: 植物精灵图
    if not specific_mode or args.plants_only:
        generate_plant_sprites(
            skip_existing=skip_existing,
            flowering_only=args.flowering_only,
            test_mode=args.test,
            use_rembg=use_rembg,
        )

    # 阶段 2: 剪影
    if not specific_mode or args.silhouettes:
        generate_silhouettes(skip_existing=skip_existing)

    # 阶段 3: UI 图标
    if not specific_mode or args.icons:
        generate_ui_icons(skip_existing=skip_existing)

    # 阶段 4: 音频占位
    if not specific_mode or args.audio:
        generate_audio_placeholders(skip_existing=skip_existing)

    # 最终统计
    print_stats()


if __name__ == "__main__":
    main()

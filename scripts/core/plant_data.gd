class_name PlantData extends RefCounted
## 植物数据库，定义所有植物品种的基础数据

## 培育组定义
enum BreedingGroup {
	ROSE,       ## 蔷薇系
	LILY,       ## 百合系
	DAISY,      ## 菊系
	ORCHID,     ## 兰系
	SUCCULENT,  ## 多肉系
	CACTUS,     ## 仙人掌
}

const GROUP_NAMES: Dictionary = {
	BreedingGroup.ROSE: "蔷薇系",
	BreedingGroup.LILY: "百合系",
	BreedingGroup.DAISY: "菊系",
	BreedingGroup.ORCHID: "兰系",
	BreedingGroup.SUCCULENT: "多肉系",
	BreedingGroup.CACTUS: "仙人掌",
}

## 植物数据库：type → 数据
static var PLANT_DATABASE: Dictionary = {
	# === 初始种子 ===
	"rose_red": {
		"name": "红玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 229, "g": 57, "b": 53},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	"daisy_white": {
		"name": "白雏菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "initial",
	},
	"tulip_yellow": {
		"name": "黄郁金香",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 253, "g": 216, "b": 53},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	# === 同品种混色发现 ===
	"rose_pink": {
		"name": "粉玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 244, "g": 143, "b": 177},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"rose_white": {
		"name": "白玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 250, "g": 250, "b": 250},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"tulip_orange": {
		"name": "橙郁金香",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 112, "b": 67},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"tulip_purple": {
		"name": "紫郁金香",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 126, "g": 87, "b": 194},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"daisy_yellow": {
		"name": "黄雏菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 235, "b": 59},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"carnation_pink": {
		"name": "粉色康乃馨",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 244, "g": 143, "b": 177},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"orchid_white": {
		"name": "白蝴蝶兰",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 255, "g": 255, "b": 250},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sakura_white": {
		"name": "白樱花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 245, "b": 245},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	# --- 新增同品种混色 ---
	"lily_white": {
		"name": "百合白",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 250, "g": 250, "b": 255},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"lily_pink": {
		"name": "粉百合",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 182, "b": 193},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sunflower_orange": {
		"name": "橙色向日葵",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 152, "b": 0},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"lavender_deep": {
		"name": "深紫薰衣草",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 106, "g": 27, "b": 154},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sakura_pink": {
		"name": "八重樱",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 150, "b": 170},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"dahlia_red": {
		"name": "红色大丽花",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 211, "g": 47, "b": 47},
		"shape": 2, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	# === 同培育组杂交发现 ===
	"peony": {
		"name": "牡丹",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 248, "g": 187, "b": 208},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"hyacinth": {
		"name": "风信子",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 100, "g": 100, "b": 220},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"gesang": {
		"name": "格桑花",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 220, "g": 120, "b": 180},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"gypsophila": {
		"name": "满天星",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 245, "g": 245, "b": 245},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"violet": {
		"name": "紫罗兰",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 123, "g": 31, "b": 162},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"jasmine": {
		"name": "茉莉花",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 255, "g": 255, "b": 224},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"lotus": {
		"name": "荷花",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 183, "b": 197},
		"shape": 3, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"hibiscus": {
		"name": "木槿花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 233, "g": 30, "b": 99},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"dahlia": {
		"name": "大丽花",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 183, "g": 28, "b": 28},
		"shape": 2, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	# --- 新增同培育组杂交 ---
	"camellia": {
		"name": "山茶花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 183, "g": 28, "b": 28},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"plum_blossom": {
		"name": "梅花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 235, "b": 245},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"water_lily": {
		"name": "睡莲",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 180, "g": 220, "b": 255},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"magnolia": {
		"name": "玉兰",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 255, "g": 250, "b": 240},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"azalea": {
		"name": "杜鹃花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 244, "g": 100, "b": 130},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"marigold": {
		"name": "万寿菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 179, "b": 0},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"forget_me_not": {
		"name": "勿忘我",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 100, "g": 149, "b": 237},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"zinnia": {
		"name": "百日菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 87, "b": 51},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"ranunculus": {
		"name": "花毛茛",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 200, "b": 150},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"wisteria": {
		"name": "紫藤",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 160, "g": 120, "b": 210},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"poppy": {
		"name": "虞美人",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 229, "g": 57, "b": 53},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"sweet_pea": {
		"name": "香豌豆",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 200, "b": 220},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	# === 多步培育发现 ===
	"sakura": {
		"name": "樱花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 205, "b": 210},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"lily": {
		"name": "百合",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 235, "b": 238},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"sunflower": {
		"name": "向日葵",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 193, "b": 7},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"carnation": {
		"name": "康乃馨",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 233, "g": 30, "b": 99},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"lavender": {
		"name": "薰衣草",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 149, "g": 117, "b": 205},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"orchid": {
		"name": "蝴蝶兰",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 206, "g": 147, "b": 216},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"bluebell": {
		"name": "风铃草",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 100, "g": 140, "b": 200},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "gradual",
	},
	"morning_glory": {
		"name": "牵牛花",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 63, "g": 81, "b": 181},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"cosmos": {
		"name": "波斯菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 240, "g": 98, "b": 146},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"chrysanthemum": {
		"name": "菊花",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 193, "b": 7},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"anemone": {
		"name": "银莲花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 179, "g": 136, "b": 255},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "gradual",
	},
	"begonia": {
		"name": "海棠",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 244, "g": 67, "b": 54},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"gardenia": {
		"name": "栀子花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 255, "b": 240},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	# --- 新增多步培育 ---
	"gladiolus": {
		"name": "剑兰",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 200, "g": 100, "b": 150},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"peach_blossom": {
		"name": "桃花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 180, "b": 180},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"canna": {
		"name": "美人蕉",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 230, "g": 50, "b": 50},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"iris": {
		"name": "鸢尾花",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 80, "g": 100, "b": 200},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"hydrangea": {
		"name": "绣球花",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 130, "g": 180, "b": 255},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"tulip_red": {
		"name": "红郁金香",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 220, "g": 30, "b": 30},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"rose_yellow": {
		"name": "黄玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 235, "b": 59},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"narcissus": {
		"name": "水仙花",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 255, "g": 255, "b": 200},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	# === 多肉 ===
	"succulent_echeveria": {
		"name": "观音莲",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 129, "g": 199, "b": 132},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "expansion_gift",
	},
	"succulent_haworthia": {
		"name": "玉露",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 102, "g": 187, "b": 106},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_bear": {
		"name": "熊童子",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 174, "g": 213, "b": 129},
		"shape": 2, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_dragon": {
		"name": "玉龙观音",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 77, "g": 182, "b": 172},
		"shape": 1, "size": 1,
		"category": "succulent",
		"discover_method": "cross_breed",
	},
	"cactus": {
		"name": "仙人掌",
		"group": BreedingGroup.CACTUS,
		"base_color": {"r": 139, "g": 195, "b": 74},
		"shape": 0, "size": 1,
		"category": "cactus",
		"discover_method": "cross_breed",
	},
	"cactus_bloom": {
		"name": "仙人球",
		"group": BreedingGroup.CACTUS,
		"base_color": {"r": 255, "g": 180, "b": 100},
		"shape": 0, "size": 0,
		"category": "cactus",
		"discover_method": "cross_breed",
	},
	"succulent_string": {
		"name": "佛珠",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 100, "g": 160, "b": 80},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_panda": {
		"name": "熊猫堇",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 200, "g": 160, "b": 180},
		"shape": 2, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"cactus_star": {
		"name": "星兜",
		"group": BreedingGroup.CACTUS,
		"base_color": {"r": 200, "g": 230, "b": 150},
		"shape": 0, "size": 0,
		"category": "cactus",
		"discover_method": "cross_breed",
	},
	# === 稀有变异 ===
	"rare_rainbow_rose": {
		"name": "彩虹玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "rainbow_rose",
	},
	"rare_dark_mandrake": {
		"name": "暗夜曼陀罗",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 26, "g": 26, "b": 26},
		"shape": 2, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "dark_mandrake",
	},
	"rare_golden_sunflower": {
		"name": "金色向日葵",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 255, "g": 215, "b": 0},
		"shape": 0, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "golden_sunflower",
	},
	"rare_moonlight_lily": {
		"name": "月光百合",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 192, "g": 192, "b": 192},
		"shape": 1, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "moonlight_lily",
	},
	"rare_eternal_flower": {
		"name": "永恒之花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "eternal_flower",
	},
	# --- 新增稀有变异 ---
	"rare_black_rose": {
		"name": "黑玫瑰",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 20, "g": 10, "b": 10},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "black_rose",
	},
	"rare_snow_queen": {
		"name": "雪后",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 240, "g": 248, "b": 255},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "snow_queen",
	},
	"rare_blue_daisy": {
		"name": "蓝色雏菊",
		"group": BreedingGroup.DAISY,
		"base_color": {"r": 60, "g": 120, "b": 255},
		"shape": 1, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "blue_daisy",
	},
	"rare_ghost_orchid": {
		"name": "幽灵兰",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 200, "g": 255, "b": 200},
		"shape": 3, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "ghost_orchid",
	},
	"rare_crystal_succulent": {
		"name": "水晶莲",
		"group": BreedingGroup.SUCCULENT,
		"base_color": {"r": 150, "g": 220, "b": 255},
		"shape": 1, "size": 0,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "crystal_succulent",
	},
	"rare_golden_cactus": {
		"name": "金琥",
		"group": BreedingGroup.CACTUS,
		"base_color": {"r": 255, "g": 215, "b": 0},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "golden_cactus",
	},
	"rare_phoenix_flower": {
		"name": "凤凰花",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 120, "b": 0},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "phoenix_flower",
	},
	"rare_aurora_borealis": {
		"name": "极光花",
		"group": BreedingGroup.ORCHID,
		"base_color": {"r": 100, "g": 220, "b": 200},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "aurora_borealis",
	},
	"rare_sakura_blizzard": {
		"name": "樱吹雪",
		"group": BreedingGroup.ROSE,
		"base_color": {"r": 255, "g": 240, "b": 255},
		"shape": 1, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "sakura_blizzard",
	},
	"rare_midnight_lily": {
		"name": "午夜百合",
		"group": BreedingGroup.LILY,
		"base_color": {"r": 40, "g": 20, "b": 80},
		"shape": 1, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "midnight_lily",
	},
}

## 同培育组杂交表："[group]_[type_a]_[type_b]" → 结果品种
## 键名排序无关，查询时双向检查
static var CROSS_BREED_TABLE: Dictionary = {
	# 蔷薇系内部
	"rose+sakura": "peony",
	"sakura+hibiscus": "begonia",
	"sakura+sakura": "gardenia",
	# 百合系内部
	"tulip+lily": "hyacinth",
	"lily+bluebell": "lotus",
	# 菊系内部
	"daisy+sunflower": "gesang",
	"daisy+carnation": "gypsophila",
	"sunflower+cosmos": "dahlia",
	"carnation+carnation": "chrysanthemum",
	# 兰系内部
	"orchid+orchid": "violet",
	"lavender+orchid": "jasmine",
	# 多肉系内部
	"succulent_echeveria+succulent_haworthia": "succulent_dragon",
	"succulent_echeveria+succulent_bear": "cactus",
	# --- 新增杂交组合 ---
	# 蔷薇系
	"rose+anemone": "plum_blossom",
	"rose+gardenia": "camellia",
	"peony+begonia": "azalea",
	# 百合系
	"tulip+bluebell": "ranunculus",
	"lily+tulip_red": "water_lily",
	"lotus+sweet_pea": "gladiolus",
	"canna+narcissus": "sweet_pea",
	# 菊系
	"daisy+poppy": "zinnia",
	"cosmos+poppy": "marigold",
	"carnation+zinnia": "poppy",
	"dahlia+chrysanthemum": "hydrangea",
	# 兰系
	"orchid+violet": "wisteria",
	"lavender+jasmine": "forget_me_not",
	"jasmine+magnolia": "iris",
	# 多肉系
	"succulent_bear+succulent_dragon": "succulent_string",
	"succulent_haworthia+succulent_bear": "succulent_panda",
	# 仙人掌系
	"cactus+cactus_bloom": "cactus_star",
}


static func get_data(type: String) -> Dictionary:
	if not PLANT_DATABASE.has(type):
		push_warning("Unknown plant type: %s" % type)
	return PLANT_DATABASE.get(type, {})


static func get_name(type: String) -> String:
	return PLANT_DATABASE.get(type, {}).get("name", "???")


static func get_group(type: String) -> int:
	return PLANT_DATABASE.get(type, {}).get("group", BreedingGroup.ROSE)


static func get_category(type: String) -> String:
	return PLANT_DATABASE.get(type, {}).get("category", "flower")


static func is_rare_type(type: String) -> bool:
	return PLANT_DATABASE.get(type, {}).get("category", "") == "rare"


static func get_all_types() -> Array:
	return PLANT_DATABASE.keys()


## 查询杂交表，返回结果品种或空字符串
static func lookup_cross_breed(type_a: String, type_b: String) -> String:
	## 提取品种简称（去掉前缀如 rose_red → rose）
	var short_a := _get_short_type(type_a)
	var short_b := _get_short_type(type_b)
	var key1 := short_a + "+" + short_b
	var key2 := short_b + "+" + short_a
	if CROSS_BREED_TABLE.has(key1):
		return CROSS_BREED_TABLE[key1]
	if CROSS_BREED_TABLE.has(key2):
		return CROSS_BREED_TABLE[key2]
	return ""


static func _get_short_type(type: String) -> String:
	## rose_red → rose, daisy_white → daisy, succulent_echeveria → succulent_echeveria
	var parts := type.split("_")
	if parts.size() >= 2:
		var prefix := parts[0]
		# 花型前缀，缩短到品种组名
		if prefix in ["rose", "tulip", "daisy", "sunflower", "lily", "sakura",
				"carnation", "lavender", "orchid", "peony", "hyacinth",
				"gesang", "gypsophila", "violet", "jasmine", "lotus",
				"hibiscus", "dahlia", "bluebell", "morning", "cosmos",
				"chrysanthemum", "anemone", "begonia", "gardenia",
				"camellia", "plum", "water", "magnolia", "azalea",
				"marigold", "forget", "zinnia", "ranunculus", "wisteria",
				"poppy", "sweet", "gladiolus", "peach", "canna",
				"iris", "hydrangea", "narcissus"]:
			return prefix
		if prefix == "succulent":
			return type  # 多肉用全名
		if prefix == "cactus":
			return type  # 仙人掌用全名（和多肉一样）
		if prefix == "rare":
			return type  # 稀有花不参与杂交表查询
	return type

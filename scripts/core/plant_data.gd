class_name PlantData extends RefCounted
## 植物数据库，定义所有植物品种的基础数据
## 包含植物学分类（科/属）、种子包、发现表等完整数据层

## 植物科属定义（基于真实植物学分类）
enum PlantFamily {
	ROSACEAE,       ## 蔷薇科
	PAEONIACEAE,    ## 芍药科
	BEGONIACEAE,    ## 秋海棠科
	RUBIACEAE,      ## 茜草科
	THEACEAE,       ## 山茶科
	ERICACEAE,      ## 杜鹃花科
	RANUNCULACEAE,  ## 毛茛科
	MALVACEAE,      ## 锦葵科
	LILIACEAE,      ## 百合科
	ASPARAGACEAE,   ## 天门冬科
	NELUMBONACEAE,  ## 莲科
	NYMPHAEACEAE,   ## 睡莲科
	IRIDACEAE,      ## 鸢尾科
	AMARYLLIDACEAE, ## 石蒜科
	CANNACEAE,      ## 美人蕉科
	FABACEAE,       ## 豆科
	ASTERACEAE,     ## 菊科
	CARYOPHYLLACEAE,## 石竹科
	PAPAVERACEAE,   ## 罂粟科
	HYDRANGEACEAE,  ## 绣球花科
	ORCHIDACEAE,    ## 兰科
	LAMIACEAE,      ## 唇形科
	VIOLACEAE,      ## 堇菜科
	OLEACEAE,       ## 木犀科
	MAGNOLIACEAE,   ## 木兰科
	CONVOLVULACEAE, ## 旋花科
	BORAGINACEAE,   ## 紫草科
	CRASSULACEAE,   ## 景天科
	ASPHODELACEAE,  ## 阿福花科
	CACTACEAE,      ## 仙人掌科
	PLANTAGINACEAE, ## 车前科
	GENTIANACEAE,   ## 龙胆科
	TYPHACEAE,      ## 香蒲科
	NYCTAGINACEAE,  ## 紫茉莉科
	STRELITZIACEAE, ## 鹤望兰科
	APOCYNACEAE,    ## 夹竹桃科
	AIZOACEAE,      ## 番杏科
}

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

const FAMILY_NAMES: Dictionary = {
	PlantFamily.ROSACEAE: "蔷薇科",
	PlantFamily.PAEONIACEAE: "芍药科",
	PlantFamily.BEGONIACEAE: "秋海棠科",
	PlantFamily.RUBIACEAE: "茜草科",
	PlantFamily.THEACEAE: "山茶科",
	PlantFamily.ERICACEAE: "杜鹃花科",
	PlantFamily.RANUNCULACEAE: "毛茛科",
	PlantFamily.MALVACEAE: "锦葵科",
	PlantFamily.LILIACEAE: "百合科",
	PlantFamily.ASPARAGACEAE: "天门冬科",
	PlantFamily.NELUMBONACEAE: "莲科",
	PlantFamily.NYMPHAEACEAE: "睡莲科",
	PlantFamily.IRIDACEAE: "鸢尾科",
	PlantFamily.AMARYLLIDACEAE: "石蒜科",
	PlantFamily.CANNACEAE: "美人蕉科",
	PlantFamily.FABACEAE: "豆科",
	PlantFamily.ASTERACEAE: "菊科",
	PlantFamily.CARYOPHYLLACEAE: "石竹科",
	PlantFamily.PAPAVERACEAE: "罂粟科",
	PlantFamily.HYDRANGEACEAE: "绣球花科",
	PlantFamily.ORCHIDACEAE: "兰科",
	PlantFamily.LAMIACEAE: "唇形科",
	PlantFamily.VIOLACEAE: "堇菜科",
	PlantFamily.OLEACEAE: "木犀科",
	PlantFamily.MAGNOLIACEAE: "木兰科",
	PlantFamily.CONVOLVULACEAE: "旋花科",
	PlantFamily.BORAGINACEAE: "紫草科",
	PlantFamily.CRASSULACEAE: "景天科",
	PlantFamily.ASPHODELACEAE: "阿福花科",
	PlantFamily.CACTACEAE: "仙人掌科",
	PlantFamily.PLANTAGINACEAE: "车前科",
	PlantFamily.GENTIANACEAE: "龙胆科",
	PlantFamily.TYPHACEAE: "香蒲科",
	PlantFamily.NYCTAGINACEAE: "紫茉莉科",
	PlantFamily.STRELITZIACEAE: "鹤望兰科",
	PlantFamily.APOCYNACEAE: "夹竹桃科",
	PlantFamily.AIZOACEAE: "番杏科",
}

## 植物数据库：type → 数据
static var PLANT_DATABASE: Dictionary = {
	# === 初始野生种 ===
	"rose_gallica": {
		"name": "法国蔷薇",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 210, "g": 80, "b": 100},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	"rose_canina": {
		"name": "犬蔷薇",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 240, "g": 180, "b": 190},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	"daisy_wild": {
		"name": "野生雏菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "bellis",
		"base_color": {"r": 255, "g": 255, "b": 230},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "initial",
	},
	"sunflower_wild": {
		"name": "野生向日葵",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "helianthus",
		"base_color": {"r": 240, "g": 200, "b": 30},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "initial",
	},
	"tulip_wild": {
		"name": "野生郁金香",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "tulipa",
		"base_color": {"r": 240, "g": 210, "b": 50},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	"lily_candidum": {
		"name": "圣母百合",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 250, "g": 250, "b": 250},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "initial",
	},
	"orchid_wild": {
		"name": "姬蝴蝶兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "phalaenopsis",
		"base_color": {"r": 240, "g": 190, "b": 200},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "initial",
	},
	"cactus_barrel": {
		"name": "金琥",
		"group": BreedingGroup.CACTUS,
		"family_id": PlantFamily.CACTACEAE,
		"genus_id": "echinocactus",
		"base_color": {"r": 130, "g": 180, "b": 80},
		"shape": 0, "size": 1,
		"category": "cactus",
		"discover_method": "initial",
	},

	# === 旧初始种（保留为栽培变种）===
	"rose_red": {
		"name": "红玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 229, "g": 57, "b": 53},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"daisy_white": {
		"name": "白雏菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "bellis",
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"tulip_yellow": {
		"name": "黄郁金香",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "tulipa",
		"base_color": {"r": 253, "g": 216, "b": 53},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},

	# === 同品种混色发现 ===
	"rose_pink": {
		"name": "粉玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 244, "g": 143, "b": 177},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"rose_white": {
		"name": "白玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 250, "g": 250, "b": 250},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"tulip_orange": {
		"name": "橙郁金香",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "tulipa",
		"base_color": {"r": 255, "g": 112, "b": 67},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"tulip_purple": {
		"name": "紫郁金香",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "tulipa",
		"base_color": {"r": 126, "g": 87, "b": 194},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"daisy_yellow": {
		"name": "黄雏菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "bellis",
		"base_color": {"r": 255, "g": 235, "b": 59},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"carnation_pink": {
		"name": "粉色康乃馨",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.CARYOPHYLLACEAE,
		"genus_id": "dianthus",
		"base_color": {"r": 244, "g": 143, "b": 177},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"orchid_white": {
		"name": "白蝴蝶兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "phalaenopsis",
		"base_color": {"r": 255, "g": 255, "b": 250},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sakura_white": {
		"name": "白樱花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 245, "b": 245},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	# --- 同品种混色（扩展）---
	"lily_white": {
		"name": "百合白",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 250, "g": 250, "b": 255},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"lily_pink": {
		"name": "粉百合",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 255, "g": 182, "b": 193},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sunflower_orange": {
		"name": "橙色向日葵",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "helianthus",
		"base_color": {"r": 255, "g": 152, "b": 0},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"lavender_deep": {
		"name": "深紫薰衣草",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.LAMIACEAE,
		"genus_id": "lavandula",
		"base_color": {"r": 106, "g": 27, "b": 154},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"sakura_pink": {
		"name": "八重樱",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 150, "b": 170},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "mix_color",
	},
	"dahlia_red": {
		"name": "红色大丽花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "dahlia",
		"base_color": {"r": 211, "g": 47, "b": 47},
		"shape": 2, "size": 2,
		"category": "flower",
		"discover_method": "mix_color",
	},

	# === 同培育组杂交发现 ===
	"peony": {
		"name": "牡丹",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.PAEONIACEAE,
		"genus_id": "paeonia",
		"base_color": {"r": 248, "g": 187, "b": 208},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"hyacinth": {
		"name": "风信子",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.ASPARAGACEAE,
		"genus_id": "hyacinthus",
		"base_color": {"r": 100, "g": 100, "b": 220},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"gesang": {
		"name": "格桑花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "cosmos",
		"base_color": {"r": 220, "g": 120, "b": 180},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"gypsophila": {
		"name": "满天星",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.CARYOPHYLLACEAE,
		"genus_id": "gypsophila",
		"base_color": {"r": 245, "g": 245, "b": 245},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"violet": {
		"name": "紫罗兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.VIOLACEAE,
		"genus_id": "viola",
		"base_color": {"r": 123, "g": 31, "b": 162},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"jasmine": {
		"name": "茉莉花",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.OLEACEAE,
		"genus_id": "jasminum",
		"base_color": {"r": 255, "g": 255, "b": 224},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"lotus": {
		"name": "荷花",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.NELUMBONACEAE,
		"genus_id": "nelumbo",
		"base_color": {"r": 255, "g": 183, "b": 197},
		"shape": 3, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"hibiscus": {
		"name": "木槿花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.MALVACEAE,
		"genus_id": "hibiscus",
		"base_color": {"r": 233, "g": 30, "b": 99},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"dahlia": {
		"name": "大丽花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "dahlia",
		"base_color": {"r": 183, "g": 28, "b": 28},
		"shape": 2, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	# --- 同培育组杂交（扩展）---
	"camellia": {
		"name": "山茶花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.THEACEAE,
		"genus_id": "camellia",
		"base_color": {"r": 183, "g": 28, "b": 28},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"plum_blossom": {
		"name": "梅花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 235, "b": 245},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"water_lily": {
		"name": "睡莲",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.NYMPHAEACEAE,
		"genus_id": "nymphaea",
		"base_color": {"r": 180, "g": 220, "b": 255},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"magnolia": {
		"name": "玉兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.MAGNOLIACEAE,
		"genus_id": "magnolia",
		"base_color": {"r": 255, "g": 250, "b": 240},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"azalea": {
		"name": "杜鹃花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ERICACEAE,
		"genus_id": "rhododendron",
		"base_color": {"r": 244, "g": 100, "b": 130},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"marigold": {
		"name": "万寿菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "tagetes",
		"base_color": {"r": 255, "g": 179, "b": 0},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"forget_me_not": {
		"name": "勿忘我",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.BORAGINACEAE,
		"genus_id": "myosotis",
		"base_color": {"r": 100, "g": 149, "b": 237},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"zinnia": {
		"name": "百日菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "zinnia",
		"base_color": {"r": 255, "g": 87, "b": 51},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"ranunculus": {
		"name": "花毛茛",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.RANUNCULACEAE,
		"genus_id": "ranunculus",
		"base_color": {"r": 255, "g": 200, "b": 150},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"wisteria": {
		"name": "紫藤",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.FABACEAE,
		"genus_id": "wisteria",
		"base_color": {"r": 160, "g": 120, "b": 210},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"poppy": {
		"name": "虞美人",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.PAPAVERACEAE,
		"genus_id": "papaver",
		"base_color": {"r": 229, "g": 57, "b": 53},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "cross_breed",
	},
	"sweet_pea": {
		"name": "香豌豆",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.FABACEAE,
		"genus_id": "lathyrus",
		"base_color": {"r": 255, "g": 200, "b": 220},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "cross_breed",
	},

	# === 多步培育发现 ===
	"sakura": {
		"name": "樱花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 205, "b": 210},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"lily": {
		"name": "百合",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 255, "g": 235, "b": 238},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"sunflower": {
		"name": "向日葵",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "helianthus",
		"base_color": {"r": 255, "g": 193, "b": 7},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"carnation": {
		"name": "康乃馨",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.CARYOPHYLLACEAE,
		"genus_id": "dianthus",
		"base_color": {"r": 233, "g": 30, "b": 99},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"lavender": {
		"name": "薰衣草",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.LAMIACEAE,
		"genus_id": "lavandula",
		"base_color": {"r": 149, "g": 117, "b": 205},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"orchid": {
		"name": "蝴蝶兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "phalaenopsis",
		"base_color": {"r": 206, "g": 147, "b": 216},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"bluebell": {
		"name": "风铃草",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.ASPARAGACEAE,
		"genus_id": "hyacinthoides",
		"base_color": {"r": 100, "g": 140, "b": 200},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "gradual",
	},
	"morning_glory": {
		"name": "牵牛花",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.CONVOLVULACEAE,
		"genus_id": "ipomoea",
		"base_color": {"r": 63, "g": 81, "b": 181},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"cosmos": {
		"name": "波斯菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "cosmos",
		"base_color": {"r": 240, "g": 98, "b": 146},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"chrysanthemum": {
		"name": "菊花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "chrysanthemum",
		"base_color": {"r": 255, "g": 193, "b": 7},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"anemone": {
		"name": "银莲花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.RANUNCULACEAE,
		"genus_id": "anemone",
		"base_color": {"r": 179, "g": 136, "b": 255},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "gradual",
	},
	"begonia": {
		"name": "海棠",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.BEGONIACEAE,
		"genus_id": "begonia",
		"base_color": {"r": 244, "g": 67, "b": 54},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"gardenia": {
		"name": "栀子花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.RUBIACEAE,
		"genus_id": "gardenia",
		"base_color": {"r": 255, "g": 255, "b": 240},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	# --- 多步培育（扩展）---
	"gladiolus": {
		"name": "剑兰",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.IRIDACEAE,
		"genus_id": "gladiolus",
		"base_color": {"r": 200, "g": 100, "b": 150},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"peach_blossom": {
		"name": "桃花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 180, "b": 180},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"canna": {
		"name": "美人蕉",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.CANNACEAE,
		"genus_id": "canna",
		"base_color": {"r": 230, "g": 50, "b": 50},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"iris": {
		"name": "鸢尾花",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.IRIDACEAE,
		"genus_id": "iris",
		"base_color": {"r": 80, "g": 100, "b": 200},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"hydrangea": {
		"name": "绣球花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.HYDRANGEACEAE,
		"genus_id": "hydrangea",
		"base_color": {"r": 130, "g": 180, "b": 255},
		"shape": 1, "size": 2,
		"category": "flower",
		"discover_method": "gradual",
	},
	"tulip_red": {
		"name": "红郁金香",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "tulipa",
		"base_color": {"r": 220, "g": 30, "b": 30},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"rose_yellow": {
		"name": "黄玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 255, "g": 235, "b": 59},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},
	"narcissus": {
		"name": "水仙花",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.AMARYLLIDACEAE,
		"genus_id": "narcissus",
		"base_color": {"r": 255, "g": 255, "b": 200},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "gradual",
	},

	# === 多肉系 ===
	"succulent_echeveria": {
		"name": "观音莲",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.CRASSULACEAE,
		"genus_id": "echeveria",
		"base_color": {"r": 129, "g": 199, "b": 132},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "expansion_gift",
	},
	"succulent_haworthia": {
		"name": "玉露",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.ASPHODELACEAE,
		"genus_id": "haworthia",
		"base_color": {"r": 102, "g": 187, "b": 106},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_bear": {
		"name": "熊童子",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.CRASSULACEAE,
		"genus_id": "cotyledon",
		"base_color": {"r": 174, "g": 213, "b": 129},
		"shape": 2, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_dragon": {
		"name": "玉龙观音",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.CRASSULACEAE,
		"genus_id": "echeveria",
		"base_color": {"r": 77, "g": 182, "b": 172},
		"shape": 1, "size": 1,
		"category": "succulent",
		"discover_method": "cross_breed",
	},
	"cactus": {
		"name": "仙人掌",
		"group": BreedingGroup.CACTUS,
		"family_id": PlantFamily.CACTACEAE,
		"genus_id": "opuntia",
		"base_color": {"r": 139, "g": 195, "b": 74},
		"shape": 0, "size": 1,
		"category": "cactus",
		"discover_method": "cross_breed",
	},
	"cactus_bloom": {
		"name": "仙人球",
		"group": BreedingGroup.CACTUS,
		"family_id": PlantFamily.CACTACEAE,
		"genus_id": "echinopsis",
		"base_color": {"r": 255, "g": 180, "b": 100},
		"shape": 0, "size": 0,
		"category": "cactus",
		"discover_method": "cross_breed",
	},
	"succulent_string": {
		"name": "佛珠",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "senecio",
		"base_color": {"r": 100, "g": 160, "b": 80},
		"shape": 1, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"succulent_panda": {
		"name": "熊猫堇",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.CRASSULACEAE,
		"genus_id": "kalanchoe",
		"base_color": {"r": 200, "g": 160, "b": 180},
		"shape": 2, "size": 0,
		"category": "succulent",
		"discover_method": "mix_color",
	},
	"cactus_star": {
		"name": "星兜",
		"group": BreedingGroup.CACTUS,
		"family_id": PlantFamily.CACTACEAE,
		"genus_id": "astrophytum",
		"base_color": {"r": 200, "g": 230, "b": 150},
		"shape": 0, "size": 0,
		"category": "cactus",
		"discover_method": "cross_breed",
	},

	# === 种子包解锁品种 ===
	# --- 温带花园 ---
	"foxglove": {
		"name": "毛地黄",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.PLANTAGINACEAE,
		"genus_id": "digitalis",
		"base_color": {"r": 200, "g": 140, "b": 220},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"delphinium": {
		"name": "飞燕草",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.RANUNCULACEAE,
		"genus_id": "delphinium",
		"base_color": {"r": 80, "g": 100, "b": 220},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	# --- 东方庭院 ---
	"cymbidium": {
		"name": "建兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "cymbidium",
		"base_color": {"r": 200, "g": 220, "b": 180},
		"shape": 3, "size": 1,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"kiku": {
		"name": "秋菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "chrysanthemum",
		"base_color": {"r": 255, "g": 200, "b": 50},
		"shape": 2, "size": 1,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	# --- 地中海花园 ---
	"rosemary": {
		"name": "迷迭香",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.LAMIACEAE,
		"genus_id": "rosmarinus",
		"base_color": {"r": 130, "g": 180, "b": 160},
		"shape": 0, "size": 0,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"bougainvillea": {
		"name": "三角梅",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.NYCTAGINACEAE,
		"genus_id": "bougainvillea",
		"base_color": {"r": 220, "g": 50, "b": 100},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	# --- 热带花境 ---
	"bird_of_paradise": {
		"name": "鹤望兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.STRELITZIACEAE,
		"genus_id": "strelitzia",
		"base_color": {"r": 255, "g": 160, "b": 30},
		"shape": 3, "size": 2,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"frangipani": {
		"name": "鸡蛋花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.APOCYNACEAE,
		"genus_id": "plumeria",
		"base_color": {"r": 255, "g": 240, "b": 200},
		"shape": 1, "size": 1,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	# --- 高山草甸 ---
	"edelweiss": {
		"name": "雪绒花",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "leontopodium",
		"base_color": {"r": 240, "g": 240, "b": 230},
		"shape": 1, "size": 0,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"gentian": {
		"name": "龙胆",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.GENTIANACEAE,
		"genus_id": "gentiana",
		"base_color": {"r": 50, "g": 80, "b": 200},
		"shape": 0, "size": 1,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	# --- 荒漠奇境 ---
	"aloe": {
		"name": "芦荟",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.ASPHODELACEAE,
		"genus_id": "aloe",
		"base_color": {"r": 100, "g": 170, "b": 100},
		"shape": 1, "size": 1,
		"category": "succulent",
		"discover_method": "seed_pack",
	},
	"lithops": {
		"name": "生石花",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.AIZOACEAE,
		"genus_id": "lithops",
		"base_color": {"r": 200, "g": 180, "b": 130},
		"shape": 2, "size": 0,
		"category": "succulent",
		"discover_method": "seed_pack",
	},
	# --- 水生花园 ---
	"cattail": {
		"name": "香蒲",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.TYPHACEAE,
		"genus_id": "typha",
		"base_color": {"r": 160, "g": 130, "b": 80},
		"shape": 0, "size": 2,
		"category": "flower",
		"discover_method": "seed_pack",
	},
	"lotus_blue": {
		"name": "蓝荷花",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.NELUMBONACEAE,
		"genus_id": "nelumbo",
		"base_color": {"r": 100, "g": 140, "b": 220},
		"shape": 3, "size": 2,
		"category": "flower",
		"discover_method": "seed_pack",
	},

	# === 稀有变异 ===
	"rare_rainbow_rose": {
		"name": "彩虹玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "rainbow_rose",
	},
	"rare_dark_mandrake": {
		"name": "暗夜曼陀罗",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 26, "g": 26, "b": 26},
		"shape": 2, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "dark_mandrake",
	},
	"rare_golden_sunflower": {
		"name": "金色向日葵",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "helianthus",
		"base_color": {"r": 255, "g": 215, "b": 0},
		"shape": 0, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "golden_sunflower",
	},
	"rare_moonlight_lily": {
		"name": "月光百合",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 192, "g": 192, "b": 192},
		"shape": 1, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "moonlight_lily",
	},
	"rare_eternal_flower": {
		"name": "永恒之花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 255, "g": 255, "b": 255},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "eternal_flower",
	},
	# --- 稀有变异（扩展）---
	"rare_black_rose": {
		"name": "黑玫瑰",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 20, "g": 10, "b": 10},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "black_rose",
	},
	"rare_snow_queen": {
		"name": "雪后",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 240, "g": 248, "b": 255},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "snow_queen",
	},
	"rare_blue_daisy": {
		"name": "蓝色雏菊",
		"group": BreedingGroup.DAISY,
		"family_id": PlantFamily.ASTERACEAE,
		"genus_id": "bellis",
		"base_color": {"r": 60, "g": 120, "b": 255},
		"shape": 1, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "blue_daisy",
	},
	"rare_ghost_orchid": {
		"name": "幽灵兰",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "phalaenopsis",
		"base_color": {"r": 200, "g": 255, "b": 200},
		"shape": 3, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "ghost_orchid",
	},
	"rare_crystal_succulent": {
		"name": "水晶莲",
		"group": BreedingGroup.SUCCULENT,
		"family_id": PlantFamily.CRASSULACEAE,
		"genus_id": "echeveria",
		"base_color": {"r": 150, "g": 220, "b": 255},
		"shape": 1, "size": 0,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "crystal_succulent",
	},
	"rare_golden_cactus": {
		"name": "黄金仙人球",
		"group": BreedingGroup.CACTUS,
		"family_id": PlantFamily.CACTACEAE,
		"genus_id": "echinocactus",
		"base_color": {"r": 255, "g": 215, "b": 0},
		"shape": 0, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "golden_cactus",
	},
	"rare_phoenix_flower": {
		"name": "凤凰花",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "rosa",
		"base_color": {"r": 255, "g": 120, "b": 0},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "phoenix_flower",
	},
	"rare_aurora_borealis": {
		"name": "极光花",
		"group": BreedingGroup.ORCHID,
		"family_id": PlantFamily.ORCHIDACEAE,
		"genus_id": "phalaenopsis",
		"base_color": {"r": 100, "g": 220, "b": 200},
		"shape": 3, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "aurora_borealis",
	},
	"rare_sakura_blizzard": {
		"name": "樱吹雪",
		"group": BreedingGroup.ROSE,
		"family_id": PlantFamily.ROSACEAE,
		"genus_id": "prunus",
		"base_color": {"r": 255, "g": 240, "b": 255},
		"shape": 1, "size": 1,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "sakura_blizzard",
	},
	"rare_midnight_lily": {
		"name": "午夜百合",
		"group": BreedingGroup.LILY,
		"family_id": PlantFamily.LILIACEAE,
		"genus_id": "lilium",
		"base_color": {"r": 40, "g": 20, "b": 80},
		"shape": 1, "size": 2,
		"category": "rare",
		"discover_method": "rare_mutation",
		"rare_type": "midnight_lily",
	},
}

## 种子包定义：图鉴里程碑解锁
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
	"mediterranean": {
		"name": "地中海花园",
		"icon": "🌊",
		"milestone": 18,
		"description": "地中海沿岸的芳香花卉",
		"species": ["lavender", "violet", "jasmine", "carnation", "gypsophila",
			"rosemary", "bougainvillea"],
	},
	"tropical": {
		"name": "热带花境",
		"icon": "🌺",
		"milestone": 28,
		"description": "热带雨林中的艳丽花卉",
		"species": ["hibiscus", "lotus", "canna", "magnolia", "morning_glory",
			"bird_of_paradise", "frangipani"],
	},
	"alpine": {
		"name": "高山草甸",
		"icon": "⛰️",
		"milestone": 38,
		"description": "高山环境中的坚韧花卉",
		"species": ["anemone", "iris", "narcissus", "bluebell", "ranunculus",
			"edelweiss", "gentian"],
	},
	"desert": {
		"name": "荒漠奇境",
		"icon": "🏜️",
		"milestone": 48,
		"description": "干旱环境中的奇特植物",
		"species": ["cactus", "cactus_bloom", "cactus_star", "succulent_haworthia",
			"succulent_bear", "aloe", "lithops"],
	},
	"aquatic": {
		"name": "水生花园",
		"icon": "💧",
		"milestone": 55,
		"description": "水生环境中的清雅植物",
		"species": ["water_lily", "hyacinth", "gladiolus", "cattail", "lotus_blue"],
	},
	"master": {
		"name": "珍藏集",
		"icon": "👑",
		"milestone": 65,
		"description": "珍稀品种的终极收藏",
		"species": ["gesang", "cosmos", "chrysanthemum", "dahlia", "zinnia",
			"marigold", "poppy", "sweet_pea", "hydrangea", "forget_me_not",
			"succulent_dragon", "succulent_string"],
	},
}

## 发现表：属级组合 → 可能结果（取代旧 CROSS_BREED_TABLE）
## 键名按字母序排列（genus_a+genus_b，a < b）
static var DISCOVERY_TABLE: Dictionary = {
	# === 蔷薇系 ===
	# Rosa × Prunus（蔷薇科核心 × 同科李属）
	"prunus+rosa": {
		"results": ["peony", "sakura"],
		"min_discoveries": 3,
	},
	# Prunus × Hibiscus（李属 × 锦葵科）
	"hibiscus+prunus": {
		"results": ["begonia"],
		"min_discoveries": 5,
	},
	# Rosa × Anemone（蔷薇科 × 毛茛科）
	"anemone+rosa": {
		"results": ["plum_blossom"],
		"min_discoveries": 5,
	},
	# Rosa × Gardenia（蔷薇科 × 茜草科）
	"gardenia+rosa": {
		"results": ["camellia"],
		"min_discoveries": 5,
	},
	# Paeonia × Begonia（芍药科 × 秋海棠科）
	"begonia+paeonia": {
		"results": ["azalea"],
		"min_discoveries": 8,
	},

	# === 百合系 ===
	# Lilium × Tulipa（百合科核心 × 同科郁金香属）
	"lilium+tulipa": {
		"results": ["hyacinth", "water_lily"],
		"min_discoveries": 3,
	},
	# Lilium × Hyacinthoides（百合科 × 天门冬科）
	"hyacinthoides+lilium": {
		"results": ["lotus"],
		"min_discoveries": 3,
	},
	# Tulipa × Hyacinthoides（郁金香属 × 风铃草属）
	"hyacinthoides+tulipa": {
		"results": ["ranunculus"],
		"min_discoveries": 5,
	},
	# Nelumbo × Lathyrus（莲科 × 豆科）
	"lathyrus+nelumbo": {
		"results": ["gladiolus"],
		"min_discoveries": 8,
	},
	# Canna × Narcissus（美人蕉科 × 石蒜科）
	"canna+narcissus": {
		"results": ["sweet_pea"],
		"min_discoveries": 8,
	},

	# === 菊系 ===
	# Bellis × Helianthus（菊科核心 × 同科向日葵属）
	"bellis+helianthus": {
		"results": ["gesang"],
		"min_discoveries": 3,
	},
	# Bellis × Dianthus（菊科 × 石竹科）
	"bellis+dianthus": {
		"results": ["gypsophila"],
		"min_discoveries": 3,
	},
	# Helianthus × Cosmos（向日葵属 × 秋英属）
	"cosmos+helianthus": {
		"results": ["dahlia"],
		"min_discoveries": 3,
	},
	# Dianthus × Dianthus（石竹科同属）
	"dianthus+dianthus": {
		"results": ["chrysanthemum"],
		"min_discoveries": 5,
	},
	# Bellis × Papaver（菊科 × 罂粟科）
	"bellis+papaver": {
		"results": ["zinnia"],
		"min_discoveries": 5,
	},
	# Cosmos × Papaver（秋英属 × 罂粟科）
	"cosmos+papaver": {
		"results": ["marigold"],
		"min_discoveries": 5,
	},
	# Dianthus × Zinnia（石竹科 × 菊科百日菊属）
	"dianthus+zinnia": {
		"results": ["poppy"],
		"min_discoveries": 5,
	},
	# Dahlia × Chrysanthemum（大丽花属 × 菊属）
	"chrysanthemum+dahlia": {
		"results": ["hydrangea"],
		"min_discoveries": 8,
	},

	# === 兰系 ===
	# Phalaenopsis × Phalaenopsis（兰科同属）
	"phalaenopsis+phalaenopsis": {
		"results": ["violet"],
		"min_discoveries": 3,
	},
	# Lavandula × Phalaenopsis（唇形科 × 兰科）
	"lavandula+phalaenopsis": {
		"results": ["jasmine"],
		"min_discoveries": 3,
	},
	# Phalaenopsis × Viola（兰科 × 堇菜科）
	"phalaenopsis+viola": {
		"results": ["wisteria"],
		"min_discoveries": 5,
	},
	# Lavandula × Jasminum（唇形科 × 木犀科）
	"jasminum+lavandula": {
		"results": ["forget_me_not"],
		"min_discoveries": 5,
	},
	# Jasminum × Magnolia（木犀科 × 木兰科）
	"jasminum+magnolia": {
		"results": ["iris"],
		"min_discoveries": 8,
	},

	# === 多肉系 ===
	# Echeveria × Haworthia（景天科 × 阿福花科）
	"echeveria+haworthia": {
		"results": ["succulent_dragon"],
		"min_discoveries": 3,
	},
	# Cotyledon × Echeveria（景天科不同属）
	"cotyledon+echeveria": {
		"results": ["cactus", "succulent_string"],
		"min_discoveries": 5,
	},
	# Cotyledon × Haworthia（景天科 × 阿福花科）
	"cotyledon+haworthia": {
		"results": ["succulent_panda"],
		"min_discoveries": 5,
	},

	# === 仙人掌系 ===
	# Opuntia × Echinopsis（仙人掌科不同属）
	"echinopsis+opuntia": {
		"results": ["cactus_star"],
		"min_discoveries": 5,
	},
}

## [已弃用] 旧版杂交表，保留以兼容旧存档
## 请使用 DISCOVERY_TABLE 替代
static var CROSS_BREED_TABLE: Dictionary = {
	"rose+sakura": "peony",
	"sakura+hibiscus": "begonia",
	"tulip+lily": "hyacinth",
	"lily+bluebell": "lotus",
	"daisy+sunflower": "gesang",
	"daisy+carnation": "gypsophila",
	"sunflower+cosmos": "dahlia",
	"carnation+carnation": "chrysanthemum",
	"orchid+orchid": "violet",
	"lavender+orchid": "jasmine",
	"succulent_echeveria+succulent_haworthia": "succulent_dragon",
	"succulent_echeveria+succulent_bear": "cactus",
	"rose+anemone": "plum_blossom",
	"rose+gardenia": "camellia",
	"peony+begonia": "azalea",
	"tulip+bluebell": "ranunculus",
	"lily+tulip_red": "water_lily",
	"lotus+sweet_pea": "gladiolus",
	"canna+narcissus": "sweet_pea",
	"daisy+poppy": "zinnia",
	"cosmos+poppy": "marigold",
	"carnation+zinnia": "poppy",
	"dahlia+chrysanthemum": "hydrangea",
	"orchid+violet": "wisteria",
	"lavender+jasmine": "forget_me_not",
	"jasmine+magnolia": "iris",
	"succulent_bear+succulent_dragon": "succulent_string",
	"succulent_haworthia+succulent_bear": "succulent_panda",
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


## 获取品种的植物学科 ID
static func get_family_id(type: String) -> int:
	return PLANT_DATABASE.get(type, {}).get("family_id", PlantFamily.ASTERACEAE)


## 获取品种的属标记（用于同属兼容度判定）
static func get_genus_id(type: String) -> String:
	return PLANT_DATABASE.get(type, {}).get("genus_id", "")


## 获取指定图鉴收录数解锁的种子包 ID 列表
static func get_seed_packs_for_milestone(count: int) -> Array:
	var unlocked := []
	for pack_id in SEED_PACKS:
		var pack: Dictionary = SEED_PACKS[pack_id]
		if count >= pack.milestone:
			unlocked.append(pack_id)
	return unlocked


## [已弃用] 请使用 DISCOVERY_TABLE 和 genus_id 替代
static func lookup_cross_breed(type_a: String, type_b: String) -> String:
	var short_a := _get_short_type(type_a)
	var short_b := _get_short_type(type_b)
	var key1 := short_a + "+" + short_b
	var key2 := short_b + "+" + short_a
	if CROSS_BREED_TABLE.has(key1):
		return CROSS_BREED_TABLE[key1]
	if CROSS_BREED_TABLE.has(key2):
		return CROSS_BREED_TABLE[key2]
	return ""


## [已弃用] 内部辅助：提取品种简称
static func _get_short_type(type: String) -> String:
	var parts := type.split("_")
	if parts.size() >= 2:
		var prefix := parts[0]
		if prefix in ["rose", "tulip", "daisy", "sunflower", "lily", "sakura",
				"carnation", "lavender", "orchid", "peony", "hyacinth",
				"gesang", "gypsophila", "violet", "jasmine", "lotus",
				"hibiscus", "dahlia", "bluebell", "morning", "cosmos",
				"chrysanthemum", "anemone", "begonia", "gardenia",
				"camellia", "plum", "water", "magnolia", "azalea",
				"marigold", "forget", "zinnia", "ranunculus", "wisteria",
				"poppy", "sweet", "gladiolus", "peach", "canna",
				"iris", "hydrangea", "narcissus",
				"foxglove", "delphinium", "cymbidium", "kiku",
				"rosemary", "bougainvillea", "bird", "frangipani",
				"edelweiss", "gentian", "aloe", "lithops",
				"cattail", "lotus_blue"]:
			return prefix
		if prefix == "succulent":
			return type
		if prefix == "cactus":
			return type
		if prefix == "rare":
			return type
	return type

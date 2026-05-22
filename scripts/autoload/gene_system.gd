extends Node
## 基因系统 v2.0：植物学兼容度、加权候选池、不完全显性、稀有变异检测
## 基于真实植物学杂交生物学研究的全面重设计

## === 兼容度等级常量 ===
const COMPAT_SAME_SPECIES: int = 4  ## S级：同品种
const COMPAT_SAME_GENUS: int = 3    ## A级：同属
const COMPAT_SAME_FAMILY: int = 2   ## B级：同科
const COMPAT_SAME_GROUP: int = 1    ## C级：同培育组
const COMPAT_CROSS_GROUP: int = 0   ## D级：跨培育组

## === 颜色参数 ===
const COLOR_BLEND_NOISE: float = 15.0        ## 不完全显性随机偏移量
const COLOR_DISCOVERY_THRESHOLD: float = 30.0 ## 颜色变种发现阈值（欧氏距离）
const MIX_COLOR_OFFSET: float = 20.0         ## 旧版混色偏移（保留兼容）

## === 稀有花颜色阈值 ===
const RARE_RGB_HIGH: int = 200
const RARE_RGB_LOW: int = 50
const RARE_GOLDEN_G: int = 180
const RARE_MOONLIGHT_G: int = 180
const RARE_MOONLIGHT_LOW: int = 80

## === 稀有突变参数 ===
const RARE_BASE_CHANCE: float = 0.03         ## 基础突变概率 3%
const RARE_CHANCE_PER_BREED: float = 0.001   ## 每次培育增加 0.1%（即每10次 +1%）
const RARE_MAX_CHANCE: float = 0.15          ## 突变概率上限 15%

## === 加权候选池权重表（设计文档 Section 8.2）===
## same_genus: 同属自交杂交权重
## cross_genus: 跨属杂交权重（same_family + same_group + cross_group 合并）
## 因为 same_family/same_group/cross_group 都使用 genus_a+genus_b 查表
const COMPAT_WEIGHTS := {
	COMPAT_SAME_SPECIES: {
		"parent_a": 20, "parent_b": 20,
		"same_genus": 0, "cross_genus": 0,
		"color_variant": 30, "mutation": 20, "mixed_a": 10,
	},
	COMPAT_SAME_GENUS: {
		"parent_a": 15, "parent_b": 15,
		"same_genus": 40, "cross_genus": 0,
		"color_variant": 15, "mutation": 10, "mixed_a": 5,
	},
	COMPAT_SAME_FAMILY: {
		"parent_a": 20, "parent_b": 10,
		"same_genus": 20, "cross_genus": 25,
		"color_variant": 10, "mutation": 8, "mixed_a": 7,
	},
	COMPAT_SAME_GROUP: {
		"parent_a": 25, "parent_b": 15,
		"same_genus": 5, "cross_genus": 27,
		"color_variant": 10, "mutation": 8, "mixed_a": 10,
	},
	COMPAT_CROSS_GROUP: {
		"parent_a": 35, "parent_b": 20,
		"same_genus": 0, "cross_genus": 10,
		"color_variant": 10, "mutation": 10, "mixed_a": 15,
	},
}


## ============================================================
## 公开 API
## ============================================================

## 计算两株植物的兼容度等级（S/A/B/C/D）
static func compute_compatibility(a_type: String, b_type: String) -> int:
	# S级：同品种
	if a_type == b_type:
		return COMPAT_SAME_SPECIES

	var a_data := PlantData.get_data(a_type)
	var b_data := PlantData.get_data(b_type)

	# A级：同属（相同 genus_id）
	var a_genus: String = a_data.get("genus_id", "")
	var b_genus: String = b_data.get("genus_id", "")
	if a_genus != "" and a_genus == b_genus:
		return COMPAT_SAME_GENUS

	# B级：同科（相同 family_id）
	var a_family: int = a_data.get("family_id", -1)
	var b_family: int = b_data.get("family_id", -1)
	if a_family != -1 and a_family == b_family:
		return COMPAT_SAME_FAMILY

	# C级：同培育组（相同 group）
	var a_group: int = a_data.get("group", -1)
	var b_group: int = b_data.get("group", -1)
	if a_group == b_group:
		return COMPAT_SAME_GROUP

	# D级：跨培育组
	return COMPAT_CROSS_GROUP


## 查询发现表：根据属对组合查找可发现的杂交物种
static func lookup_discovery(genus_a: String, genus_b: String, discovered_count: int) -> String:
	if genus_a == "" or genus_b == "":
		return ""

	# 按字母序排列以匹配 DISCOVERY_TABLE 键名格式
	var key: String
	if genus_a < genus_b:
		key = genus_a + "+" + genus_b
	else:
		key = genus_b + "+" + genus_a

	if not PlantData.DISCOVERY_TABLE.has(key):
		return ""

	var entry: Dictionary = PlantData.DISCOVERY_TABLE[key]
	if discovered_count < entry.get("min_discoveries", 0):
		return ""

	var results: Array = entry.get("results", [])
	if results.is_empty():
		return ""

	return results[randi() % results.size()]


## 不完全显性颜色混合（取代旧版随机选择）
## dominance: 显性亲本权重（0.5=均等混合, >0.5=偏向primary）
static func blend_color(primary: Dictionary, secondary: Dictionary, dominance: float = 0.5) -> Dictionary:
	var inv := 1.0 - dominance
	return {
		"r": clampi(int(primary.r * dominance + secondary.r * inv + randf_range(-COLOR_BLEND_NOISE, COLOR_BLEND_NOISE)), 0, 255),
		"g": clampi(int(primary.g * dominance + secondary.g * inv + randf_range(-COLOR_BLEND_NOISE, COLOR_BLEND_NOISE)), 0, 255),
		"b": clampi(int(primary.b * dominance + secondary.b * inv + randf_range(-COLOR_BLEND_NOISE, COLOR_BLEND_NOISE)), 0, 255),
	}


## 旧版颜色混合（保留兼容，新代码应使用 blend_color）
static func mix_colors(color_a: Dictionary, color_b: Dictionary) -> Dictionary:
	var weight := randf()
	return {
		"r": clampi(int(lerpf(color_a.r, color_b.r, weight) + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
		"g": clampi(int(lerpf(color_a.g, color_b.g, weight) + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
		"b": clampi(int(lerpf(color_a.b, color_b.b, weight) + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
	}


## 颜色变种发现检测：检查子代颜色是否接近某个同属混色变种
## 返回匹配的变种品种 ID，无匹配返回 ""
static func check_color_variant_discovery(child_color: Dictionary, base_type: String) -> String:
	var genus := PlantData.get_genus_id(base_type)
	if genus == "":
		return ""

	for type in PlantData.get_all_types():
		if type == base_type:
			continue
		var data := PlantData.get_data(type)
		if data.get("genus_id", "") != genus:
			continue
		if data.get("discover_method", "") != "mix_color":
			continue

		var target: Dictionary = data.get("base_color", {})
		if target.is_empty():
			continue

		var dr: float = child_color.get("r", 0.0) - target.get("r", 0.0)
		var dg: float = child_color.get("g", 0.0) - target.get("g", 0.0)
		var db: float = child_color.get("b", 0.0) - target.get("b", 0.0)
		var dist := sqrt(dr * dr + dg * dg + db * db)
		if dist < COLOR_DISCOVERY_THRESHOLD:
			return type

	return ""


## 加权候选池选择：根据兼容度等级构建候选池并加权随机抽取
## 返回 {"type": String, "species": String, "weight": int}
static func select_outcome(parent_a: String, parent_b: String, compat: int, discovered_count: int) -> Dictionary:
	var weights: Dictionary = COMPAT_WEIGHTS[compat]
	var genus_a: String = PlantData.get_genus_id(parent_a)
	var genus_b: String = PlantData.get_genus_id(parent_b)

	var pool: Array = []

	# 1. 亲本复制（始终可用）
	var w_pa: int = weights.get("parent_a", 0)
	if w_pa > 0:
		pool.append({"type": "parent_a", "species": parent_a, "weight": w_pa})

	var w_pb: int = weights.get("parent_b", 0)
	if w_pb > 0:
		pool.append({"type": "parent_b", "species": parent_b, "weight": w_pb})

	# 2. 同属自交杂交（genus_a+genus_a 或 genus_b+genus_b）
	var w_sg: int = weights.get("same_genus", 0)
	if w_sg > 0:
		var sg_result := lookup_discovery(genus_a, genus_a, discovered_count)
		if sg_result == "" and genus_a != genus_b:
			sg_result = lookup_discovery(genus_b, genus_b, discovered_count)
		if sg_result != "":
			pool.append({"type": "hybrid", "species": sg_result, "weight": w_sg})

	# 3. 跨属杂交（genus_a+genus_b，合并 same_family + same_group + cross_group 权重）
	var w_cg: int = weights.get("cross_genus", 0)
	if w_cg > 0 and genus_a != genus_b:
		var cg_result := lookup_discovery(genus_a, genus_b, discovered_count)
		if cg_result != "":
			pool.append({"type": "hybrid", "species": cg_result, "weight": w_cg})

	# 4. 颜色变异
	var w_cv: int = weights.get("color_variant", 0)
	if w_cv > 0:
		pool.append({"type": "color_variant", "species": parent_a, "weight": w_cv})

	# 5. 稀有突变
	var w_mt: int = weights.get("mutation", 0)
	if w_mt > 0:
		pool.append({"type": "mutation", "species": "", "weight": w_mt})

	# 6. 亲本A混色
	var w_ma: int = weights.get("mixed_a", 0)
	if w_ma > 0:
		pool.append({"type": "mixed_a", "species": parent_a, "weight": w_ma})

	# 加权随机选择
	var total_weight := 0
	for candidate in pool:
		total_weight += candidate.weight

	if total_weight == 0:
		return {"type": "parent_a", "species": parent_a, "weight": 1}

	var roll := randf_range(0, total_weight)
	var cumulative := 0.0
	for candidate in pool:
		cumulative += candidate.weight
		if roll <= cumulative:
			return candidate

	return pool[0]


## 培育主逻辑：给定两个亲本，返回子代结果
## 返回 Dictionary: { "plant_type": String, "color": Dictionary, "is_rare": bool, "rare_type": String }
## discovered_count: 当前已发现品种数（用于发现表 min_discoveries 门控）
## breeds_since_rare: 自上次稀有变异以来的培育次数（保底增强）
static func breed(parent_a_type: String, parent_b_type: String,
		parent_a_color: Dictionary, parent_b_color: Dictionary,
		discovered_count: int = 0, breeds_since_rare: int = 0) -> Dictionary:

	# 1. 计算兼容度
	var compat := compute_compatibility(parent_a_type, parent_b_type)

	# 2. 加权候选池选择结果类型
	var outcome := select_outcome(parent_a_type, parent_b_type, compat, discovered_count)
	var outcome_type: String = outcome.type
	var result_type: String = outcome.species

	# 3. 颜色混合（不完全显性）
	var child_color := blend_color(parent_a_color, parent_b_color)

	# 4. 根据结果类型处理
	if outcome_type == "color_variant":
		# 颜色变种：检查子代颜色是否匹配某个同属混色变种
		var variant := check_color_variant_discovery(child_color, parent_a_type)
		if variant != "":
			result_type = variant
			child_color = PlantData.get_data(variant).get("base_color", child_color)

	elif outcome_type == "mutation":
		# 稀有突变通道：检查颜色条件
		var group: int = PlantData.get_group(parent_a_type)
		var rare_type := check_rare(child_color, group)
		if rare_type != "":
			var rare_plant := _rare_type_to_plant(rare_type)
			if rare_plant != "":
				return {
					"plant_type": rare_plant,
					"color": PlantData.get_data(rare_plant).get("base_color", child_color),
					"is_rare": true,
					"rare_type": rare_type,
				}
		# 突变失败，回退到亲本A
		result_type = parent_a_type

	# outcome_type in ["parent_a", "parent_b", "hybrid", "mixed_a"] → 直接使用 result_type

	# 5. 颜色条件稀有检测（保底增强，非突变通道也检测）
	if outcome_type != "mutation":
		var group: int = PlantData.get_group(result_type)
		var rare_chance := RARE_BASE_CHANCE + breeds_since_rare * RARE_CHANCE_PER_BREED
		rare_chance = minf(rare_chance, RARE_MAX_CHANCE)
		if randf() < rare_chance:
			var rare_type := check_rare(child_color, group)
			if rare_type != "":
				var rare_plant := _rare_type_to_plant(rare_type)
				if rare_plant != "":
					return {
						"plant_type": rare_plant,
						"color": PlantData.get_data(rare_plant).get("base_color", child_color),
						"is_rare": true,
						"rare_type": rare_type,
					}

	# 6. 返回普通结果
	return {
		"plant_type": result_type,
		"color": child_color,
		"is_rare": false,
		"rare_type": "",
	}


## 多亲本培育（2-5朵花）
## 使用前两个亲本计算兼容度和选择结果，所有亲本参与颜色混合
static func breed_multi(parents: Array, discovered_count: int = 0, breeds_since_rare: int = 0) -> Dictionary:
	if parents.size() < 2:
		return {}

	var first_type: String = parents[0].plant_type
	var second_type: String = parents[1].plant_type

	# 使用前两个亲本做兼容度计算和结果选择
	var compat := compute_compatibility(first_type, second_type)
	var outcome := select_outcome(first_type, second_type, compat, discovered_count)
	var outcome_type: String = outcome.type
	var result_type: String = outcome.species

	# 多亲本颜色混合
	var child_color := _mix_multi_colors(parents)

	# 处理结果类型
	if outcome_type == "color_variant":
		var variant := check_color_variant_discovery(child_color, first_type)
		if variant != "":
			result_type = variant
			child_color = PlantData.get_data(variant).get("base_color", child_color)

	elif outcome_type == "mutation":
		var group: int = PlantData.get_group(first_type)
		var rare_type := check_rare(child_color, group)
		if rare_type != "":
			var rare_plant := _rare_type_to_plant(rare_type)
			if rare_plant != "":
				return {
					"plant_type": rare_plant,
					"color": PlantData.get_data(rare_plant).get("base_color", child_color),
					"is_rare": true,
					"rare_type": rare_type,
				}
		result_type = first_type

	# 多亲本保底稀有检测（亲本越多概率越高）
	if outcome_type != "mutation":
		var group: int = PlantData.get_group(result_type)
		var rare_chance: float = (RARE_BASE_CHANCE + breeds_since_rare * RARE_CHANCE_PER_BREED) * parents.size() * 0.8
		rare_chance = minf(rare_chance, RARE_MAX_CHANCE * 2.0)
		if randf() < rare_chance:
			var rare_type := check_rare(child_color, group)
			if rare_type != "":
				var rare_plant := _rare_type_to_plant(rare_type)
				if rare_plant != "":
					return {
						"plant_type": rare_plant,
						"color": PlantData.get_data(rare_plant).get("base_color", child_color),
						"is_rare": true,
						"rare_type": rare_type,
					}

	return {
		"plant_type": result_type,
		"color": child_color,
		"is_rare": false,
		"rare_type": "",
	}


## 两个不同培育组能否培育
static func can_breed_across_groups(group_a: int, group_b: int) -> bool:
	# SUCCULENT × CACTUS 现在允许（同属干旱植物大类）
	if group_a == PlantData.BreedingGroup.SUCCULENT and group_b == PlantData.BreedingGroup.CACTUS:
		return true
	if group_a == PlantData.BreedingGroup.CACTUS and group_b == PlantData.BreedingGroup.SUCCULENT:
		return true

	# 花 × 多肉/仙人掌 → 不行
	var is_flower_a := group_a in [PlantData.BreedingGroup.ROSE, PlantData.BreedingGroup.LILY,
		PlantData.BreedingGroup.DAISY, PlantData.BreedingGroup.ORCHID]
	var is_flower_b := group_b in [PlantData.BreedingGroup.ROSE, PlantData.BreedingGroup.LILY,
		PlantData.BreedingGroup.DAISY, PlantData.BreedingGroup.ORCHID]
	var is_succulent_a := group_a in [PlantData.BreedingGroup.SUCCULENT, PlantData.BreedingGroup.CACTUS]
	var is_succulent_b := group_b in [PlantData.BreedingGroup.SUCCULENT, PlantData.BreedingGroup.CACTUS]
	if is_flower_a and is_succulent_b:
		return false
	if is_succulent_a and is_flower_b:
		return false
	return true


## ============================================================
## 稀有花检测（15种稀有花完整保留）
## ============================================================

## 检查颜色是否触发稀有花
static func check_rare(color: Dictionary, group: int) -> String:
	# 黑玫瑰：蔷薇系，极暗
	if group == PlantData.BreedingGroup.ROSE:
		if color.r < 30 and color.g < 30 and color.b < 30:
			return "black_rose"
	# 樱吹雪：蔷薇系，纯净粉白
	if group == PlantData.BreedingGroup.ROSE:
		if color.r > 240 and color.g > 230 and color.b > 245:
			return "sakura_blizzard"
	# 彩虹玫瑰：蔷薇系，RGB均>200
	if group == PlantData.BreedingGroup.ROSE:
		if color.r > RARE_RGB_HIGH and color.g > RARE_RGB_HIGH and color.b > RARE_RGB_HIGH:
			return "rainbow_rose"
	# 雪后：百合系，冰白
	if group == PlantData.BreedingGroup.LILY:
		if color.r > 230 and color.g > 240 and color.b > 245:
			return "snow_queen"
	# 午夜百合：百合系，深邃紫夜
	if group == PlantData.BreedingGroup.LILY:
		if color.r < 60 and color.b > 100 and color.g < 50:
			return "midnight_lily"
	# 月光百合：百合系
	if group == PlantData.BreedingGroup.LILY:
		if color.r < RARE_MOONLIGHT_LOW and color.g > RARE_MOONLIGHT_G and color.b > RARE_MOONLIGHT_G:
			return "moonlight_lily"
	# 蓝色雏菊：菊系，蓝色主导
	if group == PlantData.BreedingGroup.DAISY:
		if color.b > 220 and color.r < 100:
			return "blue_daisy"
	# 金色向日葵：菊系
	if group == PlantData.BreedingGroup.DAISY:
		if color.r > RARE_RGB_HIGH and color.g > RARE_GOLDEN_G and color.b < RARE_RGB_LOW:
			return "golden_sunflower"
	# 幽灵兰：兰系，幽灵绿
	if group == PlantData.BreedingGroup.ORCHID:
		if color.g > 230 and color.r < 220 and color.b < 220:
			return "ghost_orchid"
	# 极光花：兰系，极光绿蓝
	if group == PlantData.BreedingGroup.ORCHID:
		if color.g > 180 and color.b > 180 and color.r < 150:
			return "aurora_borealis"
	# 永恒之花：兰系，RGB均>230（神话白花）
	if group == PlantData.BreedingGroup.ORCHID:
		if color.r > 230 and color.g > 230 and color.b > 230:
			return "eternal_flower"
	# 水晶莲：多肉系，水晶蓝绿
	if group == PlantData.BreedingGroup.SUCCULENT:
		if color.b > 200 and color.g > 200 and color.r < 180:
			return "crystal_succulent"
	# 金琥：仙人掌系，金色
	if group == PlantData.BreedingGroup.CACTUS:
		if color.r > 200 and color.g > 180 and color.b < 80:
			return "golden_cactus"
	# 凤凰花：任意组，烈焰橙红
	if color.r > 230 and color.g > 80 and color.g < 150 and color.b < 50:
		return "phoenix_flower"
	# 暗夜曼陀罗：任意培育
	if color.r < RARE_RGB_LOW and color.g < RARE_RGB_LOW and color.b < RARE_RGB_LOW:
		return "dark_mandrake"
	# 未触发任何稀有条件
	return ""


## ============================================================
## 内部辅助函数
## ============================================================

## 多亲本颜色混合（加权随机平均）
static func _mix_multi_colors(parents: Array) -> Dictionary:
	var total_r: float = 0.0
	var total_g: float = 0.0
	var total_b: float = 0.0
	var total_weight: float = 0.0
	for p in parents:
		var w: float = randf_range(0.5, 1.5)
		total_r += p.color.r * w
		total_g += p.color.g * w
		total_b += p.color.b * w
		total_weight += w
	return {
		"r": clampi(int(total_r / total_weight + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
		"g": clampi(int(total_g / total_weight + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
		"b": clampi(int(total_b / total_weight + randf_range(-MIX_COLOR_OFFSET, MIX_COLOR_OFFSET)), 0, 255),
	}


## 稀有花类型 → 植物品种 ID 映射
static func _rare_type_to_plant(rare_type: String) -> String:
	var mapping := {
		"rainbow_rose": "rare_rainbow_rose",
		"dark_mandrake": "rare_dark_mandrake",
		"golden_sunflower": "rare_golden_sunflower",
		"moonlight_lily": "rare_moonlight_lily",
		"eternal_flower": "rare_eternal_flower",
		"black_rose": "rare_black_rose",
		"snow_queen": "rare_snow_queen",
		"blue_daisy": "rare_blue_daisy",
		"ghost_orchid": "rare_ghost_orchid",
		"crystal_succulent": "rare_crystal_succulent",
		"golden_cactus": "rare_golden_cactus",
		"phoenix_flower": "rare_phoenix_flower",
		"aurora_borealis": "rare_aurora_borealis",
		"sakura_blizzard": "rare_sakura_blizzard",
		"midnight_lily": "rare_midnight_lily",
	}
	return mapping.get(rare_type, "")

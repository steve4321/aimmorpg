extends Node
## 全局游戏状态：花圃、桌面、种子库、图鉴、花仓库

## 花圃格子：Array of Plant or null
var garden_plots: Array = []
var garden_size: int = 6

## 桌面花瓶：插花的花 plant_id 列表（可多朵）
var vase_flower_ids: Array = []
## 花瓶中每朵花的位置（id -> {x, y}）
var vase_flower_positions: Dictionary = {}

## 花仓库：收藏的已开花植物（Array of Plant）
var flower_storage: Array = []

## 种子库：已经发现的品种列表
var seed_inventory: Array[String] = []

## 图鉴：已收录的品种
var encyclopedia: Dictionary = {}  # plant_type → true

## 花圃扩展参数
const EXPAND_TRIGGER: int = 5   # 每收集5种新花
const EXPAND_AMOUNT: int = 3    # 解锁3格
const MAX_GARDEN_SIZE: int = 20 # 最大20格


func _ready() -> void:
	garden_plots.resize(garden_size)
	garden_plots.fill(null)
	seed_inventory = ["rose_red", "daisy_white", "tulip_yellow"]


## 获取指定格位的植物
func get_plant(plot_index: int) -> Plant:
	if plot_index < 0 or plot_index >= garden_plots.size():
		return null
	return garden_plots[plot_index]


## 种下种子
func plant_seed(plot_index: int, plant_type: String) -> Plant:
	if plot_index < 0 or plot_index >= garden_plots.size():
		return null
	if garden_plots[plot_index] != null:
		return null
	if not plant_type in seed_inventory:
		return null

	var data := PlantData.get_data(plant_type)
	if data.is_empty():
		return null

	var p := Plant.new(plant_type, data.get("base_color", {}))
	p.display_name = data.get("name", "???")
	p.breeding_group = PlantData.GROUP_NAMES.get(data.get("group", 0), "")
	p.shape = data.get("shape", 0)
	p.size = data.get("size", 1)
	garden_plots[plot_index] = p
	EventBus.plant_planted.emit(plot_index, plant_type)
	EventBus.garden_changed.emit()
	return p


## 浇水
func water_plant(plot_index: int) -> bool:
	var p := get_plant(plot_index)
	if p == null:
		return false
	var old_stage := p.stage
	if not p.water():
		return false
	EventBus.plant_watered.emit(plot_index)
	if p.stage != old_stage:
		EventBus.stage_advanced.emit(plot_index, p.stage)
		if p.stage == Plant.Stage.FLOWERING:
			_check_discovery(p)
	return true


## 移除植物
func remove_plant(plot_index: int) -> void:
	if plot_index < 0 or plot_index >= garden_plots.size():
		return
	var p: Plant = garden_plots[plot_index]
	if p != null and p.id in vase_flower_ids:
		vase_flower_ids.erase(p.id)
		EventBus.desktop_changed.emit()
	garden_plots[plot_index] = null
	EventBus.plant_removed.emit(plot_index)
	EventBus.garden_changed.emit()


## 培育两株花（旧版，已废弃 — 请使用 breed_from_storage / breed_from_storage_multi）
## TODO: 待确认无外部引用后删除
func breed_plants(plot_a: int, plot_b: int, target_plot: int) -> Plant:
	push_warning("breed_plants is deprecated, use breed_from_storage instead")
	var parent_a := get_plant(plot_a)
	var parent_b := get_plant(plot_b)
	if parent_a == null or parent_b == null:
		return null
	if parent_a.stage != Plant.Stage.FLOWERING or parent_b.stage != Plant.Stage.FLOWERING:
		return null
	if target_plot < 0 or target_plot >= garden_plots.size():
		return null
	if garden_plots[target_plot] != null:
		return null
	if not GeneSystem.can_breed_across_groups(
		PlantData.get_group(parent_a.plant_type),
		PlantData.get_group(parent_b.plant_type)):
		return null

	var result: Dictionary = GeneSystem.breed(
		parent_a.plant_type, parent_b.plant_type,
		parent_a.color, parent_b.color)

	var data := PlantData.get_data(result.plant_type)
	var child := Plant.new(result.plant_type)
	child.display_name = data.get("name", "???")
	child.breeding_group = PlantData.GROUP_NAMES.get(data.get("group", 0), "")
	child.shape = data.get("shape", 0)
	child.size = data.get("size", 1)
	child.is_rare = result.is_rare
	child.rare_type = result.rare_type
	child.setup_breeding_sprout(result.color)

	if not result.plant_type in seed_inventory:
		seed_inventory.append(result.plant_type)

	_check_discovery_for_type(result.plant_type, result.is_rare)

	garden_plots[target_plot] = child
	EventBus.breeding_started.emit(target_plot, plot_a, plot_b)
	EventBus.garden_changed.emit()
	return child


## === 桌面花瓶 ===

## 插花到桌面花瓶（从仓库选，可指定位置）
func arrange_flower(storage_index: int, pos: Vector2 = Vector2(-1, -1)) -> bool:
	if storage_index < 0 or storage_index >= flower_storage.size():
		return false
	var p: Plant = flower_storage[storage_index]
	if p.id in vase_flower_ids:
		return false
	if vase_flower_ids.size() >= 10:
		return false
	vase_flower_ids.append(p.id)
	vase_flower_positions[p.id] = {"x": pos.x, "y": pos.y}
	EventBus.desktop_changed.emit()
	return true


## 移动花瓶中花朵的位置
func set_vase_flower_position(flower_id: String, pos: Vector2) -> void:
	if not flower_id in vase_flower_ids:
		return
	vase_flower_positions[flower_id] = {"x": pos.x, "y": pos.y}
	EventBus.desktop_changed.emit()


## 从花瓶移除一朵花
func remove_vase_flower(flower_id: String) -> void:
	vase_flower_ids.erase(flower_id)
	vase_flower_positions.erase(flower_id)
	EventBus.desktop_changed.emit()


## 清空花瓶
func clear_vase() -> void:
	vase_flower_ids.clear()
	vase_flower_positions.clear()
	EventBus.desktop_changed.emit()


## 获取花瓶中所有植物
func get_vase_plants() -> Array:
	# 构建ID→Plant查找表，避免O(n²)遍历
	var lookup: Dictionary = {}
	for p in garden_plots:
		if p != null:
			lookup[p.id] = p
	for p in flower_storage:
		if p != null:
			lookup[p.id] = p
	var result: Array = []
	for fid in vase_flower_ids:
		if lookup.has(fid):
			result.append(lookup[fid])
	return result


## 获取花瓶花朵位置
func get_vase_flower_positions() -> Dictionary:
	return vase_flower_positions


## === 花仓库 ===

## 将花园中开花的植物收入仓库
func store_flower_from_garden(plot_index: int) -> bool:
	var p := get_plant(plot_index)
	if p == null:
		return false
	if p.stage != Plant.Stage.FLOWERING:
		return false
	# 清除花瓶引用
	if p.id in vase_flower_ids:
		vase_flower_ids.erase(p.id)
		EventBus.desktop_changed.emit()
	flower_storage.append(p)
	garden_plots[plot_index] = null
	EventBus.flower_stored.emit(plot_index)
	EventBus.garden_changed.emit()
	return true


## 从仓库取花放回花园空格
func retrieve_flower_to_garden(storage_index: int, plot_index: int) -> bool:
	if storage_index < 0 or storage_index >= flower_storage.size():
		return false
	if plot_index < 0 or plot_index >= garden_plots.size():
		return false
	if garden_plots[plot_index] != null:
		return false
	var p: Plant = flower_storage[storage_index]
	flower_storage.remove_at(storage_index)
	garden_plots[plot_index] = p
	EventBus.flower_retrieved.emit(plot_index)
	EventBus.garden_changed.emit()
	return true


## 培育两株仓库里的花（不消耗，结果直接变种子）
func breed_from_storage(storage_a: int, storage_b: int) -> Dictionary:
	if storage_a < 0 or storage_a >= flower_storage.size():
		return {}
	if storage_b < 0 or storage_b >= flower_storage.size():
		return {}
	var parent_a: Plant = flower_storage[storage_a]
	var parent_b: Plant = flower_storage[storage_b]
	if parent_a.stage != Plant.Stage.FLOWERING or parent_b.stage != Plant.Stage.FLOWERING:
		return {}
	if not GeneSystem.can_breed_across_groups(
		PlantData.get_group(parent_a.plant_type),
		PlantData.get_group(parent_b.plant_type)):
		return {"error": "incompatible"}

	var result: Dictionary = GeneSystem.breed(
		parent_a.plant_type, parent_b.plant_type,
		parent_a.color, parent_b.color)

	# 结果直接加入种子库
	var new_type: String = result.plant_type
	if not new_type in seed_inventory:
		seed_inventory.append(new_type)

	# 检查新发现
	var new_data: Dictionary = PlantData.get_data(new_type)
	var is_new_discovery := not encyclopedia.has(new_type)
	if is_new_discovery:
		encyclopedia[new_type] = true
		if result.is_rare:
			EventBus.rare_flower_found.emit(new_type)
		_check_garden_expansion()

	EventBus.breeding_done.emit(new_type, result.is_rare, is_new_discovery)
	return {
		"plant_type": new_type,
		"plant_name": new_data.get("name", "???"),
		"is_rare": result.is_rare,
		"rare_type": result.rare_type,
		"color": result.color,
		"is_new": is_new_discovery,
	}


## 多亲本培育（2-5朵仓库花，不消耗花朵）
func breed_from_storage_multi(storage_indices: Array) -> Dictionary:
	if storage_indices.size() < 2 or storage_indices.size() > 5:
		return {}

	# 验证索引并构建亲本数据
	var parents_data: Array = []
	for idx in storage_indices:
		if idx < 0 or idx >= flower_storage.size():
			return {}
		var plant: Plant = flower_storage[idx]
		if plant.stage != Plant.Stage.FLOWERING:
			return {}
		parents_data.append({
			"plant_type": plant.plant_type,
			"color": plant.color,
		})

	# 兼容性检查：花卉×多肉/仙人掌不可培育
	for i in range(parents_data.size()):
		for j in range(i + 1, parents_data.size()):
			if not GeneSystem.can_breed_across_groups(
				PlantData.get_group(parents_data[i].plant_type),
				PlantData.get_group(parents_data[j].plant_type)):
				return {"error": "incompatible"}

	# 执行培育
	var result: Dictionary = GeneSystem.breed_multi(parents_data)
	if result.is_empty():
		return {}

	# 加入种子库
	var new_type: String = result.plant_type
	if not new_type in seed_inventory:
		seed_inventory.append(new_type)

	# 检查新发现
	var new_data: Dictionary = PlantData.get_data(new_type)
	var is_new_discovery := not encyclopedia.has(new_type)
	if is_new_discovery:
		encyclopedia[new_type] = true
		if result.is_rare:
			EventBus.rare_flower_found.emit(new_type)
		_check_garden_expansion()

	EventBus.breeding_done.emit(new_type, result.is_rare, is_new_discovery)
	return {
		"plant_type": new_type,
		"plant_name": new_data.get("name", "???"),
		"is_rare": result.is_rare,
		"rare_type": result.rare_type,
		"color": result.color,
		"is_new": is_new_discovery,
	}


## 检查新发现
func _check_discovery(plant: Plant) -> void:
	var type := plant.plant_type
	if encyclopedia.has(type):
		return
	encyclopedia[type] = true
	EventBus.flower_discovered.emit(type)

	if plant.is_rare:
		EventBus.rare_flower_found.emit(type)

	# 加入种子库
	if not type in seed_inventory:
		seed_inventory.append(type)

	# 检查花圃扩展
	_check_garden_expansion()


## 检查新发现（按品种名和稀有度）
func _check_discovery_for_type(type: String, is_rare: bool) -> void:
	if encyclopedia.has(type):
		return
	encyclopedia[type] = true
	EventBus.flower_discovered.emit(type)

	if is_rare:
		EventBus.rare_flower_found.emit(type)

	# 加入种子库
	if not type in seed_inventory:
		seed_inventory.append(type)

	# 检查花圃扩展
	_check_garden_expansion()


func _check_garden_expansion() -> void:
	var collected := encyclopedia.size()
	# 首次: 6格时需5个发现 → 扩展到9格
	# 二次: 9格时需10个发现 → 扩展到12格
	# 三次: 12格时需15个发现 → 扩展到15格
	var threshold := ((garden_size - 6) / EXPAND_AMOUNT + 1) * EXPAND_TRIGGER
	if collected >= threshold and garden_size < MAX_GARDEN_SIZE:
		garden_size = mini(garden_size + EXPAND_AMOUNT, MAX_GARDEN_SIZE)
		garden_plots.resize(garden_size)
		# 首次扩展赠送多肉种子
		if garden_size == 9 and not "succulent_echeveria" in seed_inventory:
			seed_inventory.append("succulent_echeveria")
		EventBus.garden_expanded.emit(garden_size)


## 序列化
func to_dictionary() -> Dictionary:
	var plots_data: Array = []
	for p in garden_plots:
		if p != null:
			plots_data.append(p.to_dictionary())
		else:
			plots_data.append(null)
	var storage_data: Array = []
	for p in flower_storage:
		if p != null:
			storage_data.append(p.to_dictionary())
	return {
		"garden_size": garden_size,
		"garden_plots": plots_data,
		"vase_flower_ids": vase_flower_ids,
		"vase_flower_positions": vase_flower_positions,
		"seed_inventory": seed_inventory,
		"encyclopedia": encyclopedia,
		"flower_storage": storage_data,
	}


func from_dictionary(data: Dictionary) -> void:
	garden_size = data.get("garden_size", 6)
	var plots_data: Array = data.get("garden_plots", [])
	garden_plots.clear()
	for entry in plots_data:
		if entry != null and entry is Dictionary:
			garden_plots.append(Plant.from_dictionary(entry))
		else:
			garden_plots.append(null)
	while garden_plots.size() < garden_size:
		garden_plots.append(null)
	encyclopedia = data.get("encyclopedia", {})
	flower_storage.clear()
	for entry in data.get("flower_storage", []):
		if entry != null and entry is Dictionary:
			flower_storage.append(Plant.from_dictionary(entry))
	# 验证花瓶ID有效性：构建所有现存植物ID集合
	var valid_ids: Dictionary = {}
	for p in garden_plots:
		if p != null:
			valid_ids[p.id] = true
	for p in flower_storage:
		if p != null:
			valid_ids[p.id] = true
	vase_flower_ids.clear()
	for fid in data.get("vase_flower_ids", []):
		if valid_ids.has(fid):
			vase_flower_ids.append(fid)
	vase_flower_positions = data.get("vase_flower_positions", {})
	# 清理无效位置
	var invalid_keys: Array = []
	for fid in vase_flower_positions.keys():
		if not fid in valid_ids:
			invalid_keys.append(fid)
	for fid in invalid_keys:
		vase_flower_positions.erase(fid)
	seed_inventory.clear()
	for s in data.get("seed_inventory", ["rose_red", "daisy_white", "tulip_yellow"]):
		seed_inventory.append(s)

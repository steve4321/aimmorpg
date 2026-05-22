extends Control
## 图鉴界面：展示已发现/未发现的花，分类筛选
## 支持里程碑进度、来源筛选、植物学分类详情

signal closed()

@onready var grid: GridContainer = $Panel/Margin/VBox/Scroll/Grid
@onready var filter_all: Button = $Panel/Margin/VBox/FilterBar/FilterAll
@onready var filter_flower: Button = $Panel/Margin/VBox/FilterBar/FilterFlower
@onready var filter_succulent: Button = $Panel/Margin/VBox/FilterBar/FilterSucculent
@onready var filter_rare: Button = $Panel/Margin/VBox/FilterBar/FilterRare
@onready var count_label: Label = $Panel/Margin/VBox/FilterBar/CountLabel
@onready var close_btn: Button = $Panel/Margin/VBox/FilterBar/CloseButton
@onready var detail_panel: PanelContainer = $Panel/Margin/VBox/DetailPanel
@onready var detail_icon: Label = $Panel/Margin/VBox/DetailPanel/HBox/Icon
@onready var detail_name: Label = $Panel/Margin/VBox/DetailPanel/HBox/VBox/NameLabel
@onready var detail_group: Label = $Panel/Margin/VBox/DetailPanel/HBox/VBox/GroupLabel
@onready var detail_desc: Label = $Panel/Margin/VBox/DetailPanel/HBox/VBox/DescLabel

## 代码创建的 UI 元素
var _progress_label: Label
var _filter_seed_pack: Button
var _detail_source: Label

var _current_filter: String = "all"

## 总品种数（从数据库动态获取）
var _total_species: int = 0


func _ready() -> void:
	filter_all.pressed.connect(func(): _set_filter("all"))
	filter_flower.pressed.connect(func(): _set_filter("flower"))
	filter_succulent.pressed.connect(func(): _set_filter("succulent"))
	filter_rare.pressed.connect(func(): _set_filter("rare"))
	close_btn.pressed.connect(func(): closed.emit(); hide())
	detail_panel.visible = false

	_total_species = PlantData.get_all_types().size()

	_create_progress_label()
	_create_seed_pack_filter_button()
	_create_detail_source_label()

	EventBus.seed_pack_unlocked.connect(_on_seed_pack_unlocked)


func _create_progress_label() -> void:
	_progress_label = Label.new()
	_progress_label.name = "ProgressLabel"
	# 插入到 FilterBar 之后、Scroll 之前
	var vbox: VBoxContainer = $Panel/Margin/VBox
	var scroll_index := vbox.get_children().find($Panel/Margin/VBox/Scroll)
	vbox.add_child(_progress_label)
	vbox.move_child(_progress_label, scroll_index)


func _create_seed_pack_filter_button() -> void:
	_filter_seed_pack = Button.new()
	_filter_seed_pack.name = "FilterSeedPack"
	_filter_seed_pack.text = "📦 区域"
	# 插入到 FilterRare 之后、CountLabel 之前
	var filter_bar: HBoxContainer = $Panel/Margin/VBox/FilterBar
	var count_index := filter_bar.get_children().find(count_label)
	filter_bar.add_child(_filter_seed_pack)
	filter_bar.move_child(_filter_seed_pack, count_index)
	_filter_seed_pack.pressed.connect(func(): _set_filter("seed_pack"))


func _create_detail_source_label() -> void:
	_detail_source = Label.new()
	_detail_source.name = "SourceLabel"
	_detail_source.add_theme_font_size_override("font_size", 11)
	var detail_vbox: VBoxContainer = $Panel/Margin/VBox/DetailPanel/HBox/VBox
	detail_vbox.add_child(_detail_source)


func popup() -> void:
	_current_filter = "all"
	_refresh()
	show()


func _set_filter(filter: String) -> void:
	_current_filter = filter
	_refresh()


func _refresh() -> void:
	# 清除旧格子
	for child in grid.get_children():
		child.queue_free()

	detail_panel.visible = false

	var all_types: Array = PlantData.get_all_types()
	var filtered: Array = []
	for plant_type in all_types:
		var data: Dictionary = PlantData.get_data(plant_type)
		if data.is_empty():
			continue
		var category: String = data.get("category", "flower")
		var discover_method: String = data.get("discover_method", "")
		# "succulent" 筛选同时包含仙人掌类
		var match_filter := (_current_filter == "all"
			or _current_filter == category
			or (_current_filter == "succulent" and category == "cactus")
			or (_current_filter == "seed_pack" and discover_method == "seed_pack"))
		if match_filter:
			filtered.append(plant_type)

	var discovered: int = 0
	for plant_type in filtered:
		var data: Dictionary = PlantData.get_data(plant_type)
		var is_found: bool = GameState.encyclopedia.has(plant_type)
		if is_found:
			discovered += 1

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(64, 64)

		if is_found:
			var name: String = data.get("name", "???")
			var color: Dictionary = data.get("base_color", {})
			var c := Color(color.get("r", 128) / 255.0, color.get("g", 128) / 255.0, color.get("b", 128) / 255.0)
			btn.text = "🌸"
			btn.modulate = c
			btn.tooltip_text = name
			var _type: String = plant_type
			btn.pressed.connect(_show_detail.bind(_type))
		else:
			btn.text = "❓"
			btn.modulate = Color(0.3, 0.3, 0.3, 1.0)
			btn.tooltip_text = "???"
			btn.disabled = true

		grid.add_child(btn)

	var total_in_filter: int = filtered.size()
	count_label.text = "%d/%d" % [discovered, total_in_filter]

	_update_progress_label()


func _update_progress_label() -> void:
	var collected: int = GameState.encyclopedia.size()
	var line1: String = "已收录: %d/%d" % [collected, _total_species]
	var line2: String = _get_next_milestone_text(collected)
	if line2 != "":
		_progress_label.text = line1 + "\n" + line2
	else:
		_progress_label.text = line1 + "\n✨ 全部种子包已解锁！"


func _get_next_milestone_text(collected: int) -> String:
	var next_pack_id: String = ""
	var next_milestone: int = -1
	for pack_id in PlantData.SEED_PACKS:
		var pack: Dictionary = PlantData.SEED_PACKS[pack_id]
		if GameState.unlocked_seed_packs.has(pack_id):
			continue
		if next_milestone == -1 or pack.milestone < next_milestone:
			next_milestone = pack.milestone
			next_pack_id = pack_id
	if next_milestone == -1:
		return ""
	var pack_data: Dictionary = PlantData.SEED_PACKS[next_pack_id]
	var remaining: int = next_milestone - collected
	return "%s %s（再发现 %d 种）" % [pack_data.get("icon", "📦"), pack_data.get("name", ""), remaining]


func _show_detail(plant_type: String) -> void:
	var data: Dictionary = PlantData.get_data(plant_type)
	if data.is_empty():
		return

	var name: String = data.get("name", "???")
	var group: int = data.get("group", 0)
	var category: String = data.get("category", "flower")
	var color: Dictionary = data.get("base_color", {})
	var c := Color(color.get("r", 128) / 255.0, color.get("g", 128) / 255.0, color.get("b", 128) / 255.0)

	detail_icon.text = "🌸"
	detail_icon.modulate = c
	detail_name.text = name

	var group_name: String = PlantData.GROUP_NAMES.get(group, "未知")
	# 植物学科名
	var family_id: int = data.get("family_id", -1)
	var family_name: String = PlantData.FAMILY_NAMES.get(family_id, "") if family_id >= 0 else ""
	var group_part: String = "系: %s | 类: %s" % [group_name, category]
	if family_name != "":
		group_part = "科: %s | %s" % [family_name, group_part]
	detail_group.text = group_part

	# 发现来源
	var discover_method: String = data.get("discover_method", "")
	var method_text: String = _method_description(discover_method)
	detail_desc.text = method_text

	# 种子包来源详情
	var source_text: String = _get_source_description(plant_type, discover_method)
	if _detail_source:
		_detail_source.text = source_text

	detail_panel.visible = true


func _get_source_description(plant_type: String, discover_method: String) -> String:
	if discover_method == "seed_pack":
		# 找到包含该品种的种子包
		for pack_id in PlantData.SEED_PACKS:
			var pack: Dictionary = PlantData.SEED_PACKS[pack_id]
			var species_list: Array = pack.get("species", [])
			if plant_type in species_list:
				var icon: String = pack.get("icon", "📦")
				var pack_name: String = pack.get("name", "")
				var milestone: int = pack.get("milestone", 0)
				var unlocked: bool = GameState.unlocked_seed_packs.has(pack_id)
				if unlocked:
					return "%s %s（已解锁 · 里程碑 %d 种）" % [icon, pack_name, milestone]
				else:
					return "%s %s（里程碑 %d 种）" % [icon, pack_name, milestone]
		return "📦 区域种子包解锁"
	return ""


func _method_description(method: String) -> String:
	match method:
		"initial":
			return "初始种子"
		"mix_color":
			return "同品种混色培育获得"
		"cross_breed":
			return "同系杂交培育获得"
		"gradual":
			return "多步培育发现"
		"expansion_gift":
			return "花圃扩展赠送"
		"rare_mutation":
			return "✨ 稀有变异！极低概率出现"
		"seed_pack":
			return "📦 区域种子包解锁"
		"collection":
			return "📦 区域种子包解锁"
		_:
			return ""


func _on_seed_pack_unlocked(_pack_id: String, _pack_name: String) -> void:
	if visible:
		_refresh()

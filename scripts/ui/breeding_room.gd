extends Control
## 培育室：仓库内联 + 拖拽培育（2-5朵花）

const MAX_SLOTS := 5

@onready var back_btn: Button = $Background/Margin/MainVBox/BottomBar/BackButton
@onready var desktop_btn: Button = $Background/Margin/MainVBox/BottomBar/DesktopButton
@onready var storage_count_label: Label = $Background/Margin/MainVBox/BottomBar/StorageCount
@onready var warehouse_list: VBoxContainer = $Background/Margin/MainVBox/ContentHBox/LeftPanel/LeftVBox/WarehouseScroll/WarehouseList
@onready var slots_container: HFlowContainer = $Background/Margin/MainVBox/ContentHBox/RightPanel/SlotsContainer
@onready var slot_count_label: Label = $Background/Margin/MainVBox/ContentHBox/RightPanel/SlotCount
@onready var breed_btn: Button = $Background/Margin/MainVBox/ContentHBox/RightPanel/BreedButton
@onready var result_label: Label = $Background/Margin/MainVBox/ContentHBox/RightPanel/ResultArea/ResultLabel

var _slot_indices: Array[int] = []   # 每个槽位对应的仓库索引，-1=空
var _slot_controls: Array[PanelContainer] = []
var _slot_icon_labels: Array[Label] = []
var _slot_name_labels: Array[Label] = []
var _drag_pending_index: int = -1
var _drag_start_pos: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _drag_preview: Label = null
var _drag_from_slot: int = -1  # 从哪个槽位拖出（-1=从仓库拖出）


func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	desktop_btn.pressed.connect(_on_desktop_pressed)
	breed_btn.pressed.connect(_on_breed_pressed)
	EventBus.breeding_done.connect(_on_breeding_done)
	EventBus.flower_stored.connect(_on_storage_changed)

	# 创建5个培育槽位
	for i in range(MAX_SLOTS):
		_slot_indices.append(-1)
		var slot := PanelContainer.new()
		var icon_lbl := Label.new()
		var name_lbl := Label.new()
		_setup_drop_slot(slot, icon_lbl, name_lbl, i)
		_slot_controls.append(slot)
		_slot_icon_labels.append(icon_lbl)
		_slot_name_labels.append(name_lbl)
		slots_container.add_child(slot)

	_update_display()


## 全局拖拽：手动实现，不依赖 Godot 内置 drag/drop
func _input(event: InputEvent) -> void:
	if _drag_pending_index < 0 and not _is_dragging:
		return

	# 松开鼠标 → 完成拖拽
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if _is_dragging:
			_finish_drag()
		_drag_pending_index = -1
		return

	# 鼠标移动 → 启动或更新拖拽
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = get_global_mouse_position()

		# 还没开始拖拽，检测阈值
		if not _is_dragging and _drag_pending_index >= 0:
			if mouse_pos.distance_to(_drag_start_pos) > 8.0:
				_start_drag(_drag_pending_index)

		# 更新预览位置 + 高亮目标槽位
		if _is_dragging and _drag_preview != null:
			_drag_preview.global_position = mouse_pos - _drag_preview.size * 0.5
			_highlight_target_slot(mouse_pos)


func _start_drag(storage_index: int) -> void:
	if storage_index < 0 or storage_index >= GameState.flower_storage.size():
		return
	_is_dragging = true
	var plant: Plant = GameState.flower_storage[storage_index]
	_drag_preview = Label.new()
	_drag_preview.text = "🌸 %s" % plant.display_name
	_drag_preview.add_theme_font_size_override("font_size", 14)
	_drag_preview.z_index = 100
	_drag_preview.set_meta("storage_index", storage_index)
	add_child(_drag_preview)
	# 从槽位拖出时，清空源槽位（交换模式）
	if _drag_from_slot >= 0:
		_slot_indices[_drag_from_slot] = -1
		_update_display()


func _finish_drag() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()

	# 获取被拖拽的花朵 storage_index（统一从 preview 读取）
	var storage_index: int = int(_drag_preview.get_meta("storage_index", -1)) if _drag_preview != null else -1

	# 清理预览
	if _drag_preview != null:
		_drag_preview.queue_free()
		_drag_preview = null
	_is_dragging = false

	# 清除所有高亮
	for slot in _slot_controls:
		if is_instance_valid(slot):
			slot.remove_theme_stylebox_override("panel")

	if storage_index < 0:
		_drag_from_slot = -1
		return

	# 检测落点在哪个槽位上
	for i in range(MAX_SLOTS):
		var slot: Control = _slot_controls[i]
		var slot_rect: Rect2 = slot.get_global_rect()
		if slot_rect.has_point(mouse_pos):
			if _drag_from_slot >= 0 and i != _drag_from_slot:
				# 槽位之间交换
				var temp: int = _slot_indices[i]
				_slot_indices[i] = storage_index
				_slot_indices[_drag_from_slot] = temp
			else:
				_slot_indices[i] = storage_index
			_drag_from_slot = -1
			_update_display()
			return

	# 不在槽位上，找第一个空槽位（仅从仓库拖出时）
	if _drag_from_slot < 0:
		for i in range(MAX_SLOTS):
			if _slot_indices[i] == -1:
				_slot_indices[i] = storage_index
				_update_display()
				return

	# 从槽位拖出但未放到任何槽位 → 放回原槽位
	if _drag_from_slot >= 0:
		_slot_indices[_drag_from_slot] = storage_index

	_drag_from_slot = -1
	_update_display()


## === 仓库列表 ===

func _build_warehouse_list() -> void:
	for child in warehouse_list.get_children():
		child.queue_free()

	if GameState.flower_storage.is_empty():
		var label := Label.new()
		label.text = "仓库是空的\n先把花圃里的花收入仓库"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warehouse_list.add_child(label)
		return

	for i in range(GameState.flower_storage.size()):
		var plant: Plant = GameState.flower_storage[i]
		var item := PanelContainer.new()
		item.custom_minimum_size = Vector2(0, 48)

		# 检查是否已在槽位中
		if i in _slot_indices:
			item.modulate.a = 0.4

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		item.add_child(hbox)

		var icon := Label.new()
		icon.text = "🌸"
		icon.modulate = plant.get_display_color()
		icon.add_theme_font_size_override("font_size", 20)
		icon.custom_minimum_size = Vector2(30, 0)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(icon)

		var info_vbox := VBoxContainer.new()
		info_vbox.add_theme_constant_override("separation", 0)
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var name_lbl := Label.new()
		name_lbl.text = plant.display_name
		name_lbl.add_theme_font_size_override("font_size", 13)
		info_vbox.add_child(name_lbl)

		var group_lbl := Label.new()
		group_lbl.text = plant.breeding_group
		group_lbl.add_theme_font_size_override("font_size", 10)
		group_lbl.modulate.a = 0.6
		info_vbox.add_child(group_lbl)

		# 拖拽：通过 gui_input + force_drag
		var idx := i
		item.gui_input.connect(_on_warehouse_item_input.bind(idx, item))

		warehouse_list.add_child(item)


func _on_warehouse_item_input(event: InputEvent, storage_index: int, _item: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_pending_index = storage_index
			_drag_start_pos = get_global_mouse_position()
		else:
			_drag_pending_index = -1


## === 培育槽位 ===

func _setup_drop_slot(slot: PanelContainer, icon_lbl: Label, name_lbl: Label, slot_index: int) -> void:
	slot.custom_minimum_size = Vector2(64, 80)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	slot.add_child(vbox)

	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 24)
	icon_lbl.text = "➕"
	vbox.add_child(icon_lbl)

	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.text = "拖入"
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)

	# 点击清除槽位
	slot.gui_input.connect(_on_slot_gui_input.bind(slot_index))


## 拖拽时高亮目标槽位
func _highlight_target_slot(mouse_pos: Vector2) -> void:
	for i in range(MAX_SLOTS):
		var slot: Control = _slot_controls[i]
		var slot_rect: Rect2 = slot.get_global_rect()
		if slot_rect.has_point(mouse_pos):
			var style := StyleBoxFlat.new()
			style.bg_color = Color(1, 1, 1, 0.2)
			style.set_corner_radius_all(8)
			style.set_border_width_all(2)
			style.border_color = Color(1, 1, 0.5, 0.8)
			slot.add_theme_stylebox_override("panel", style)
		else:
			_update_slot_display(i)


func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# 右键：放回仓库
			if _slot_indices[slot_index] >= 0:
				_slot_indices[slot_index] = -1
				_update_display()
		elif event.button_index == MOUSE_BUTTON_LEFT and _slot_indices[slot_index] >= 0:
			# 左键拖拽已填充的槽位（和其他槽位交换）
			_drag_pending_index = _slot_indices[slot_index]
			_drag_start_pos = get_global_mouse_position()
			_drag_from_slot = slot_index


func _update_slot_display(slot_index: int) -> void:
	var slot: PanelContainer = _slot_controls[slot_index]
	var icon_lbl: Label = _slot_icon_labels[slot_index]
	var name_lbl: Label = _slot_name_labels[slot_index]
	var storage_index: int = _slot_indices[slot_index]

	if storage_index < 0 or storage_index >= GameState.flower_storage.size():
		icon_lbl.text = "➕"
		icon_lbl.modulate = Color.WHITE
		name_lbl.text = "拖入"
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.08)
		style.set_corner_radius_all(8)
		style.set_border_width_all(1)
		style.border_color = Color(1, 1, 1, 0.15)
		slot.add_theme_stylebox_override("panel", style)
	else:
		var plant: Plant = GameState.flower_storage[storage_index]
		icon_lbl.text = "🌸"
		icon_lbl.modulate = plant.get_display_color()
		name_lbl.text = plant.display_name
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.12)
		style.set_corner_radius_all(8)
		style.set_border_width_all(2)
		style.border_color = plant.get_display_color()
		slot.add_theme_stylebox_override("panel", style)


## === 整体刷新 ===

func _update_display() -> void:
	_build_warehouse_list()
	for i in range(MAX_SLOTS):
		_update_slot_display(i)
	_update_breed_button()
	var filled := _get_filled_count()
	slot_count_label.text = "已选 %d/%d" % [filled, MAX_SLOTS]
	storage_count_label.text = "仓库: %d朵花" % GameState.flower_storage.size()


func _update_breed_button() -> void:
	var filled := _get_filled_count()
	breed_btn.disabled = filled < 2

	if filled >= 2:
		var indices := _get_filled_indices()
		for i in range(indices.size()):
			for j in range(i + 1, indices.size()):
				var plant_a: Plant = GameState.flower_storage[indices[i]]
				var plant_b: Plant = GameState.flower_storage[indices[j]]
				if not GeneSystem.can_breed_across_groups(
					PlantData.get_group(plant_a.plant_type),
					PlantData.get_group(plant_b.plant_type)):
					result_label.text = "⚠️ 花卉和多肉/仙人掌无法培育"
					breed_btn.disabled = true
					return


func _get_filled_count() -> int:
	var count := 0
	for idx in _slot_indices:
		if idx >= 0:
			count += 1
	return count


func _get_filled_indices() -> Array[int]:
	var result: Array[int] = []
	for idx in _slot_indices:
		if idx >= 0:
			result.append(idx)
	return result


## === 培育逻辑 ===

func _on_breed_pressed() -> void:
	var indices := _get_filled_indices()
	if indices.size() < 2:
		return

	result_label.text = "培育中..."
	breed_btn.disabled = true

	var result: Dictionary = GameState.breed_from_storage_multi(indices)
	if result.is_empty():
		result_label.text = "⚠️ 培育失败"
		_update_breed_button()
		return
	if result.has("error"):
		if result.error == "incompatible":
			result_label.text = "⚠️ 花卉和多肉/仙人掌无法培育"
		else:
			result_label.text = "⚠️ 培育失败"
		_update_breed_button()
		return

	var msg: String = "🌱 获得：%s" % result.plant_name
	if result.is_rare:
		msg = "✨ 稀有花！获得：%s" % result.plant_name
	if result.is_new:
		msg += " 🎉新发现！"
	msg += "（已加入种子库）"
	result_label.text = msg

	get_tree().create_timer(2.0).timeout.connect(_reset_slots)


func _reset_slots() -> void:
	for i in range(MAX_SLOTS):
		_slot_indices[i] = -1
	_update_display()


## === 信号回调 ===

func _on_breeding_done(_plant_type: String, _is_rare: bool, _is_new: bool) -> void:
	_update_display()


func _on_storage_changed(_plot_index: int) -> void:
	for i in range(MAX_SLOTS):
		if _slot_indices[i] >= 0 and _slot_indices[i] >= GameState.flower_storage.size():
			_slot_indices[i] = -1
	_update_display()


## === 场景切换 ===

func _on_back_pressed() -> void:
	SFXPlayer.play_click()
	get_tree().change_scene_to_file("res://scenes/garden.tscn")


func _on_desktop_pressed() -> void:
	SFXPlayer.play_click()
	get_tree().change_scene_to_file("res://scenes/desktop.tscn")

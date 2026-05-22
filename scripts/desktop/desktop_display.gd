extends Control
## 桌面展示：花瓶（自由布局，1-10朵花）+ 仓库鲜花面板

const IDLE_SCRIPT: GDScript = preload("res://scripts/desktop/idle_animator.gd")

@onready var warehouse_panel: PanelContainer = $VBox/MainHBox/WarehousePanel
@onready var warehouse_list: VBoxContainer = $VBox/MainHBox/WarehousePanel/WarehouseVBox/WarehouseScroll/WarehouseList
@onready var warehouse_hint: Label = $VBox/MainHBox/WarehousePanel/WarehouseVBox/WarehouseHint
@onready var vase_panel: PanelContainer = $VBox/MainHBox/VasePanel
@onready var vase_area: PanelContainer = $VBox/MainHBox/VasePanel/VaseArea
@onready var vase_content: Control = $VBox/MainHBox/VasePanel/VaseArea/VaseContent
@onready var empty_hint: Label = $VBox/MainHBox/VasePanel/VaseArea/VaseContent/EmptyHint
@onready var add_btn: Button = $VBox/MainHBox/VasePanel/VaseArea/VaseContent/AddBtn
@onready var garden_btn: Button = $VBox/BottomBar/GardenButton
@onready var breeding_room_btn: Button = $VBox/BottomBar/BreedingRoomButton
@onready var clear_vase_btn: Button = $VBox/BottomBar/ClearVaseButton

var _flower_widgets: Array = []  # [{ "id": String, "widget": Control, "animator": Node }]

var _is_dragging_vase: bool = false
var _drag_flower_id: String = ""
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_preview: Control = null

## 仓库到花瓶的拖拽
var _is_dragging_from_warehouse: bool = false
var _drag_from_storage_index: int = -1
var _drag_wh_start_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	_load_save()
	_connect_signals()
	_refresh_vase()
	_build_warehouse_list()
	_update_warehouse_visibility()


func _load_save() -> void:
	if SaveManager.has_save():
		SaveManager.load_game()
	else:
		GameState.new_game()


func _connect_signals() -> void:
	garden_btn.pressed.connect(_on_garden_btn_pressed)
	breeding_room_btn.pressed.connect(_on_breeding_room_btn_pressed)
	clear_vase_btn.pressed.connect(_on_clear_vase_pressed)
	EventBus.desktop_changed.connect(_on_desktop_changed)
	EventBus.game_loaded.connect(_on_game_loaded)
	EventBus.flower_stored.connect(_on_storage_changed)

	add_btn.pressed.connect(_toggle_warehouse_panel)


func _toggle_warehouse_panel() -> void:
	warehouse_panel.visible = not warehouse_panel.visible
	if warehouse_panel.visible:
		_build_warehouse_list()


func _update_warehouse_visibility() -> void:
	# 如果仓库为空且面板隐藏，则不显示
	var has_storage: bool = not GameState.flower_storage.is_empty()
	if not has_storage and not warehouse_panel.visible:
		warehouse_panel.visible = false


## ============================================================
## 仓库鲜花列表
## ============================================================

func _build_warehouse_list() -> void:
	# 清除旧列表
	for child in warehouse_list.get_children():
		child.queue_free()

	var storage: Array = GameState.flower_storage
	if storage.is_empty():
		warehouse_hint.visible = true
		warehouse_list.visible = false
		return

	warehouse_hint.visible = false
	warehouse_list.visible = true

	for i in range(storage.size()):
		var plant: Plant = storage[i]
		var item := _make_warehouse_item(plant, i)
		warehouse_list.add_child(item)


func _make_warehouse_item(plant: Plant, storage_index: int) -> Control:
	var in_vase: bool = plant.id in GameState.vase_flower_ids

	var item := PanelContainer.new()
	item.custom_minimum_size = Vector2(0, 56)
	item.set_meta("storage_index", storage_index)
	item.set_meta("in_vase", in_vase)

	var style := StyleBoxFlat.new()
	if in_vase:
		style.bg_color = Color(0.3, 0.3, 0.3, 0.2)
	else:
		style.bg_color = Color(1, 1, 1, 0.06)
	style.set_corner_radius_all(6)
	item.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	item.add_child(hbox)

	var icon := Label.new()
	icon.text = "🌸"
	icon.modulate = plant.get_display_color()
	if in_vase:
		icon.modulate = Color(0.5, 0.5, 0.5)
	icon.add_theme_font_size_override("font_size", 24)
	icon.custom_minimum_size = Vector2(40, 0)
	hbox.add_child(icon)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = plant.display_name
	name_lbl.add_theme_font_size_override("font_size", 12)
	if in_vase:
		name_lbl.modulate = Color(0.5, 0.5, 0.5)
	vbox.add_child(name_lbl)

	var type_lbl := Label.new()
	if in_vase:
		type_lbl.text = "已在花瓶中"
		type_lbl.modulate = Color(0.6, 0.6, 0.6)
	else:
		type_lbl.text = plant.plant_type
		type_lbl.modulate = Color(0.6, 0.6, 0.6)
	type_lbl.add_theme_font_size_override("font_size", 10)
	vbox.add_child(type_lbl)

	# 已使用的不能拖拽
	if not in_vase:
		item.gui_input.connect(_on_warehouse_item_input.bind(storage_index))
	return item


func _input(event: InputEvent) -> void:
	if not _is_dragging_from_warehouse:
		return
	if event is InputEventMouseMotion:
		if _drag_preview != null:
			_drag_preview.position = get_viewport().get_mouse_position() - Vector2(40, 18)
		_highlight_vase_drop(get_viewport().get_mouse_position())
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finish_warehouse_drag()
		_is_dragging_from_warehouse = false


func _on_warehouse_item_input(event: InputEvent, storage_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_is_dragging_from_warehouse = true
		_drag_from_storage_index = storage_index
		# 创建预览
		var preview := PanelContainer.new()
		preview.custom_minimum_size = Vector2(80, 36)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.5, 0.2, 0.9)
		style.set_corner_radius_all(8)
		preview.add_theme_stylebox_override("panel", style)
		preview.z_index = 1000
		var lbl := Label.new()
		lbl.text = "🌸 %s" % GameState.flower_storage[storage_index].display_name
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		preview.add_child(lbl)
		get_tree().root.add_child(preview)
		preview.position = get_viewport().get_mouse_position() - Vector2(40, 18)
		_drag_preview = preview


func _finish_warehouse_drag() -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

	# 清理预览
	if _drag_preview != null:
		_drag_preview.queue_free()
		_drag_preview = null
	_is_dragging_from_warehouse = false

	# 检查是否落在花瓶上
	var vase_rect: Rect2 = vase_area.get_global_rect()
	if vase_rect.has_point(mouse_pos):
		# 计算在 VaseContent 中的局部位置
		var local_pos: Vector2 = mouse_pos - vase_content.global_position
		# 居中一下，防止太靠边
		local_pos.x = clamp(local_pos.x - 30.0, 4.0, vase_content.size.x - 64.0)
		local_pos.y = clamp(local_pos.y - 40.0, 4.0, vase_content.size.y - 84.0)
		# 添加到花瓶
		var result: bool = GameState.arrange_flower(_drag_from_storage_index, local_pos)
		if result:
			_refresh_vase()
			_build_warehouse_list()
			EventBus.desktop_changed.emit()
	_drag_from_storage_index = -1


func _highlight_vase_drop(mouse_pos: Vector2) -> void:
	var style := StyleBoxFlat.new()
	if vase_area.get_global_rect().has_point(mouse_pos):
		style.bg_color = Color(0.3, 0.8, 0.3, 0.3)
		style.set_corner_radius_all(12)
		style.set_border_width_all(2)
		style.border_color = Color(0.3, 1.0, 0.3, 0.8)
	else:
		style.bg_color = Color(1, 1, 1, 0.10)
		style.set_corner_radius_all(12)
	vase_area.add_theme_stylebox_override("panel", style)


## ============================================================
## 花瓶鲜花显示
## ============================================================

func _refresh_vase() -> void:
	# 清除旧的
	for w in _flower_widgets:
		if w.widget != null and is_instance_valid(w.widget):
			w.widget.queue_free()
		if w.animator != null and is_instance_valid(w.animator):
			if w.animator.is_processing():
				w.animator.stop()
	_flower_widgets.clear()

	var plants: Array = GameState.get_vase_plants()
	var positions: Dictionary = GameState.get_vase_flower_positions()

	if plants.is_empty():
		empty_hint.visible = true
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.06)
		style.set_corner_radius_all(12)
		vase_area.add_theme_stylebox_override("panel", style)
	else:
		empty_hint.visible = false
		for plant in plants:
			var fid: String = plant.id
			var pos: Vector2
			if positions.has(fid):
				pos = Vector2(positions[fid].x, positions[fid].y)
			else:
				pos = Vector2(50, 50)
			_create_flower_widget(plant, fid, pos)

		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.10)
		style.set_corner_radius_all(12)
		style.set_border_width_all(1)
		style.border_color = Color(1, 1, 1, 0.15)
		vase_area.add_theme_stylebox_override("panel", style)


func _create_flower_widget(plant: Plant, flower_id: String, pos: Vector2) -> void:
	var widget := Control.new()
	widget.name = "Flower_%s" % flower_id
	widget.set_meta("flower_id", flower_id)
	widget.custom_minimum_size = Vector2(60, 80)
	widget.layout_mode = 0
	widget.anchors_preset = 0
	widget.offset_left = pos.x
	widget.offset_top = pos.y
	widget.offset_right = pos.x + 60
	widget.offset_bottom = pos.y + 80
	vase_content.add_child(widget)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	widget.add_child(vbox)

	var icon := Label.new()
	icon.text = "🌸"
	icon.modulate = plant.get_display_color()
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 36)
	vbox.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = plant.display_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.custom_minimum_size = Vector2(56, 0)
	vbox.add_child(name_lbl)

	# idle 动画器
	var animator := Node.new()
	animator.set_script(IDLE_SCRIPT)
	animator.set_process(false)
	widget.add_child(animator)
	animator.setup(widget, plant.plant_type)
	animator.set_process(true)

	_flower_widgets.append({ "id": flower_id, "widget": widget, "animator": animator })
	widget.gui_input.connect(_on_flower_input.bind(flower_id))


func _on_flower_input(event: InputEvent, flower_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging_vase = true
			_drag_flower_id = flower_id
			_drag_offset = vase_content.get_global_mouse_position() - _get_widget(flower_id).global_position
		else:
			if _is_dragging_vase:
				_is_dragging_vase = false
				var widget: Control = _get_widget(_drag_flower_id)
				if widget != null:
					var local_pos: Vector2 = Vector2(widget.offset_left, widget.offset_top)
					GameState.set_vase_flower_position(_drag_flower_id, local_pos)

	elif event is InputEventMouseMotion and _is_dragging_vase:
		var widget: Control = _get_widget(_drag_flower_id)
		if widget != null:
			var new_pos: Vector2 = vase_content.get_global_mouse_position() - _drag_offset
			var content_size: Vector2 = vase_content.size
			var widget_size: Vector2 = widget.size
			new_pos.x = clamp(new_pos.x, 0, content_size.x - widget_size.x)
			new_pos.y = clamp(new_pos.y, 0, content_size.y - widget_size.y)
			widget.offset_left = new_pos.x
			widget.offset_top = new_pos.y
			widget.offset_right = new_pos.x + widget_size.x
			widget.offset_bottom = new_pos.y + widget_size.y

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		GameState.remove_vase_flower(flower_id)
		_refresh_vase()
		_build_warehouse_list()


func _get_widget(flower_id: String) -> Control:
	for w in _flower_widgets:
		if w.id == flower_id and is_instance_valid(w.widget):
			return w.widget
	return null


## ============================================================
## 信号回调
## ============================================================

func _on_storage_changed(_plot_index: int) -> void:
	_build_warehouse_list()
	_update_warehouse_visibility()


func _on_desktop_changed() -> void:
	_refresh_vase()
	if warehouse_panel.visible:
		_build_warehouse_list()


func _on_game_loaded() -> void:
	_refresh_vase()
	_build_warehouse_list()


## ============================================================
## 场景切换
## ============================================================

func _on_garden_btn_pressed() -> void:
	SFXPlayer.play_click()
	get_tree().change_scene_to_file("res://scenes/garden.tscn")


func _on_breeding_room_btn_pressed() -> void:
	SFXPlayer.play_click()
	get_tree().change_scene_to_file("res://scenes/breeding_room.tscn")


func _on_clear_vase_pressed() -> void:
	SFXPlayer.play_click()
	GameState.clear_vase()
	_refresh_vase()
	_build_warehouse_list()
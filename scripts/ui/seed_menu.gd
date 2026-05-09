extends Control
## 种子选择弹窗

signal seed_selected(plant_type: String)
signal cancelled()

@onready var seed_list: VBoxContainer = $Panel/Margin/VBox/Scroll/List
@onready var close_btn: Button = $Panel/Margin/VBox/Header/CloseButton


func _ready() -> void:
    close_btn.pressed.connect(_on_close_pressed)


func popup_seed_menu() -> void:
    _refresh_list()
    show()


func _on_close_pressed() -> void:
    cancelled.emit()
    hide()


func _on_seed_pressed(plant_type: String) -> void:
    seed_selected.emit(plant_type)
    hide()


func _input(event: InputEvent) -> void:
    if not visible:
        return
    # ESC 关闭
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        cancelled.emit()
        hide()
        get_viewport().set_input_as_handled()
        return
    # 点击外部关闭
    if event is InputEventMouseButton and event.pressed:
        var panel_rect: Rect2 = $Panel.get_global_rect()
        if not panel_rect.has_point(event.global_position):
            cancelled.emit()
            hide()
            get_viewport().set_input_as_handled()


func _refresh_list() -> void:
    for child in seed_list.get_children():
        child.queue_free()

    if GameState.seed_inventory.is_empty():
        var label := Label.new()
        label.text = "没有种子了，去培育室培育新品种吧"
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        seed_list.add_child(label)
        return

    for plant_type in GameState.seed_inventory:
        var data := PlantData.get_data(plant_type)
        if data.is_empty():
            continue
        var btn := Button.new()
        btn.text = "%s (%s)" % [data.get("name", "???"), PlantData.GROUP_NAMES.get(data.get("group", 0), "")]
        btn.custom_minimum_size = Vector2(200, 36)
        btn.pressed.connect(_on_seed_pressed.bind(plant_type))
        seed_list.add_child(btn)

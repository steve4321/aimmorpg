extends Control
## 种子包解锁弹窗：里程碑达成时展示新区域及其品种

signal closed()

@onready var icon_label: Label = $Panel/Margin/VBox/TitleBar/IconLabel
@onready var title_label: Label = $Panel/Margin/VBox/TitleBar/TitleLabel
@onready var desc_label: Label = $Panel/Margin/VBox/DescLabel
@onready var separator_top: HSeparator = $Panel/Margin/VBox/SeparatorTop
@onready var species_list: VBoxContainer = $Panel/Margin/VBox/SpeciesScroll/SpeciesList
@onready var separator_bottom: HSeparator = $Panel/Margin/VBox/SeparatorBottom
@onready var count_label: Label = $Panel/Margin/VBox/CountLabel
@onready var close_btn: Button = $Panel/Margin/VBox/CloseButton


func _ready() -> void:
    close_btn.pressed.connect(_on_close_pressed)
    hide()


func popup(pack_id: String) -> void:
    var pack: Dictionary = PlantData.SEED_PACKS.get(pack_id, {})
    if pack.is_empty():
        push_warning("SeedPackPopup: unknown pack_id '%s'" % pack_id)
        return

    # 标题区域
    var pack_icon: String = pack.get("icon", "📦")
    var pack_name: String = pack.get("name", "???")
    icon_label.text = pack_icon
    title_label.text = "发现新区域！%s %s" % [pack_icon, pack_name]

    # 描述
    desc_label.text = pack.get("description", "")

    # 品种列表
    for child in species_list.get_children():
        child.queue_free()

    var species: Array = pack.get("species", [])
    for species_type in species:
        var species_name: String = PlantData.get_name(species_type)
        var label := Label.new()
        label.text = "🌸 %s" % species_name
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        species_list.add_child(label)

    # 底部计数
    count_label.text = "%d 个新品种已加入种子库！" % species.size()

    show()


func _on_close_pressed() -> void:
    closed.emit()
    hide()

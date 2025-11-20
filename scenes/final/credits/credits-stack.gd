@tool
class_name CreditsStack extends VBoxContainer

signal done

@export_tool_button("Play Animation", "Play") var play = display
@export_tool_button("Reset", "Stop") var hide_lines = _hide
@export var text_time: float = 1.0
@export var gap: float = 0.2
@export var label: Label
@export var items: Array[NameList]

func _ready() -> void:
	_hide()
	

func display() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(label, "visible_ratio", 1, text_time)
	await tween.finished
	await get_tree().create_timer(gap).timeout
	for item in items:
		item.display()
	done.emit()
		
func _hide() -> void:
	label.visible_ratio = 0
	for item in items:
		item._hide()
	modulate = Color.WHITE

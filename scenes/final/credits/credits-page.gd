@tool
class_name CreditsPage extends VBoxContainer

signal done

@export_tool_button("Play Animation", "Play") var play = display
@export_tool_button("Fade Out", "FadeOut") var fadeout = fade_out
@export_tool_button("Reset", "Stop") var hide_lines = _hide
@export var text_time: float = 1.0
@export var gap: float = 0.2
@export var fadeout_time: float = 2.0
@export var label: Label
@export var items: Array[CreditsStack]
@export_category("Sequencing")
@export var hold_duration: float = 5.0
@export var wait_after_duration: float = 1.0

func _ready() -> void:
	_hide()
	

func display() -> void:
	if label != null:
		var tween = get_tree().create_tween()
		tween.tween_property(label, "visible_ratio", 1, text_time)
		await tween.finished
		await get_tree().create_timer(gap).timeout
	for item in items:
		item.display()
		await item.done
	done.emit()
		
func fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fadeout_time)
		
func _hide() -> void:
	if label != null:
		label.visible_ratio = 0
	for item in items:
		item._hide()
	modulate = Color.WHITE

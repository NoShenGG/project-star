@tool
class_name NameList extends VBoxContainer

signal done

@export_tool_button("Display Lines", "Play") var play = display
@export_tool_button("Reset", "Stop") var hide_lines = _hide
@export_tool_button("Generate", "BoxMesh") var generate = _generate
@export_multiline var text: String
@export var fade_time: float = 0.2
@export var gap: float = 0.2

var labels: Array[Label] = []

func _ready() -> void:
	labels.clear()
	for child in get_children():
		if child is Label:
			labels.append(child as Label)
	

func display() -> void:
	for label in labels:
		var tween = get_tree().create_tween()
		tween.tween_property(label, "modulate", Color.WHITE, fade_time)
		await tween.finished
		await get_tree().create_timer(gap).timeout
	done.emit()
		
func _hide() -> void:
	for label in labels:
		label.modulate = Color.TRANSPARENT
	
func _generate() -> void:
	for child in get_children():
		child.free()
	labels.clear()
	var lines = text.split("\n")
	for line in lines:
		var label = Label.new()
		label.label_settings = load("res://scenes/final/credits/names.tres")
		label.text = line
		label.name = line
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(label)
		label.owner = get_tree().edited_scene_root
		labels.append(label)
		print(label)

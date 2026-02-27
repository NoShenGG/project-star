@tool
extends EditorInspectorPlugin

class_name NinePatchMarginVisualizerInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is NinePatchRect


func _parse_begin(object: Object) -> void:
	var preview := NinePatchMarginVisualizerPreview.new()

	preview.target = object
	add_custom_control(preview)

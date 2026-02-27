@tool
extends EditorPlugin

var inspector_plugin: NinePatchMarginVisualizerInspectorPlugin


func _enter_tree() -> void:
	inspector_plugin = NinePatchMarginVisualizerInspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)

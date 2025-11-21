@tool
extends Control

@export_tool_button("Play Animation", "Play") var play = display
@export_tool_button("Reset", "Stop") var hide_lines = _hide
@export var pages: Array[CreditsPage]


func _ready() -> void:
	_hide()

func display() -> void:
	for page in pages:
		page.display()
		await page.done
		await get_tree().create_timer(page.hold_duration).timeout
		page.fade_out()
		await get_tree().create_timer(page.wait_after_duration).timeout
		
		
func _hide() -> void:
	for page in pages:
		page._hide()

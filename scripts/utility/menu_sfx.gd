extends Node

@export var open_sfx : FmodEventEmitter3D
@export var close_sfx : FmodEventEmitter3D

func _ready() -> void:
	var menu = get_parent() as Menu
	
	menu.menu_shown.connect(open)
	menu.menu_closed.connect(close)

func open():
	if (open_sfx): open_sfx.play(true)
	if (close_sfx): close_sfx.stop()

func close():
	if (close_sfx): close_sfx.play(true)
	if (open_sfx): open_sfx.stop()

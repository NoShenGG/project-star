extends Node

@export var open_sfx : FmodEventEmitter3D
@export var close_sfx : FmodEventEmitter3D

func _ready() -> void:
	var menu = get_parent() as Menu
	
	menu.menu_shown.connect(open)
	menu.menu_closed.connect(close)

func open():
	open_sfx.play(true)
	close_sfx.stop()

func close():
	close_sfx.play(true)
	open_sfx.stop()

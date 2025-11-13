extends Control
class_name Menu

# Parent script of MenuElements
# entrance and exit is based on its pivot (?)

@export var open_on_start : bool
@export var focused_control : Control
var is_open := false

func _enter_tree() -> void:
	MenuManager.menus[self.name] = self
	for n: MenuElements in get_children():
		n.hide() #this prevents every closing animation playing at once
	
func _ready() -> void:
	if open_on_start: open()
	else: close()

func open() -> void:
	MenuManager.force_close()
	is_open = true
	print_rich("[color=spring_green]Opening menu: ", self)
	for n: MenuElements in get_children():
		n.opened()
	if focused_control == null:
		focused_control = get_child(0)
		print_rich("[color=spring_green]* No focus specified, defaulting to ", focused_control)
	focused_control.grab_focus()

func close() -> void:
	is_open = false
	print_rich("[color=dark_sea_green]Closing menu: ", self)
	for n: MenuElements in get_children():
		n.closed()

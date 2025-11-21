@icon("uid://clqa4dxu7dbwl")
extends CanvasItem
class_name MenuElements

# When parent menu closes or opens, play animations and allow itself to be focused/selected
@export var tween_transition : Tween.TransitionType

@export_category("Open Animation")
## delay before starting the open animation
@export var open_animation_delay : float
## amount of time taken for open animation
@export var open_time : float = 0.4
@export_subgroup("Animation Flags")
@export_flags("Alpha", "Scale X", "Scale Y", "Rotate 180") var open_animation_flags : int

@export_category("Close Animation")
## amount of time taken for close animation
@export var close_time : float = 0.2
## delay before starting the close animation
@export var close_animation_delay : float
@export_subgroup("Animation Flags")
@export_flags("Alpha", "Scale X", "Scale Y", "Rotate 180") var close_animation_flags : int

var menu : Menu

func _ready() -> void:
	menu = find_menu()
	
	assert(menu != null, name + " is a MenuElement without a menu! please ensure its a part of the heirarchy of a Menu and not a child")
	
	menu.menu_shown.connect(opened)
	menu.menu_closed.connect(closed)
	menu.menu_hidden.connect(func(): hide())
	
	var transform = control_self if control_self else node2d_self
	assert(transform != null, name +" must inherit from Node2D or Control node")
	
	if (node2d_self): 
		scale_magnitude = transform.scale.length()
	default_rotation = transform.rotation

func find_menu(node : Node = self) -> Menu:
	if (node.get_parent() == null): return null
	
	if (node.get_parent() is Menu):
		return node.get_parent() as Menu
	else:
		return find_menu(node.get_parent())

@onready var control_self : Control = (self as CanvasItem) as Control
@onready var node2d_self : Node2D = (self as CanvasItem) as Node2D
var scale_magnitude : float = 1
var default_rotation : float = 0

func opened() -> void:
	if (control_self):
		control_self.focus_mode = Control.FOCUS_ALL #makes focusable/selectable
		control_self.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if (open_animation_flags & 1 == 1):
		modulate = Color.TRANSPARENT
	
	if (open_animation_delay > 0): 
		await get_tree().create_timer(open_animation_delay).timeout
	show()
	await animate(open_animation_flags, open_time, false)
	#await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, open_animation_delay).finished # ANIMATION IN FUTURE

func closed() -> void:
	if (control_self):
		control_self.focus_mode = Control.FOCUS_NONE #makes unfocusable/unselectable
		control_self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, close_animation_delay).finished # ANIMATION IN FUTURE
	
	if (close_animation_delay > 0): 
		await get_tree().create_timer(close_animation_delay).timeout
	await animate(close_animation_flags, close_time, true)
	print("im done waiting homie")
	hide()


#    1        2             4             8
## "Alpha", "Scale X", "Scale Y", "Rotate 90"
func animate(flags : int, time : float, closing : bool = false):
	print(" the flags is  " + str(flags) + " and the closing value is  " + str(closing))
	if (flags & 1 == 1):
		print("animate alpha")
		modulate = modulate if closing else Color.TRANSPARENT
		var color : Color = Color.TRANSPARENT if closing else Color.WHITE
		create_tween().tween_property(self, "modulate", color, time).set_trans(tween_transition)
	
	var transform = control_self if control_self else node2d_self
	
	if (flags & 2 == 2 or flags & 4 == 4):
		print("animate scale")
		
		var scale_x : bool = flags & 2 == 2 
		var scale_y : bool = flags & 4 == 4
		print(" scaling x?  " + str(scale_x) + "   Scaling y? " + str(scale_y))
		var open_size : Vector2 = Vector2.ONE * scale_magnitude
		var close_size : Vector2 = Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		transform.scale = transform.scale if closing else Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		
		print ("sacle is   " + str(close_size if closing else open_size))
		create_tween().tween_property(self, "scale", close_size if closing else open_size, time).set_trans(tween_transition)
	
	if (flags & 8 == 8):
		var current_rotation : float = transform.rotation
		var final_rotation : float = 2*PI if closing else default_rotation
		transform.rotation = transform.rotation if closing else 2*PI
		create_tween().tween_property(self, "rotation", final_rotation, time).set_trans(tween_transition)
	
	await get_tree().create_timer(time).timeout

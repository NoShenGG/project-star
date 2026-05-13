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

var tween : Tween
var transitioning : bool

func _ready() -> void:
	menu = find_menu()
	
	assert(menu != null, name + " is a MenuElement without a menu! please ensure its a part of the heirarchy of a Menu and not a child")
	
	menu.menu_shown.connect(opened)
	menu.menu_closed.connect(closed)
	menu.menu_hidden.connect(func(): hide())
	
	var transform = control_self if control_self else node2d_self
	if control_self:
		control_self.offset_transform_enabled = true
	assert(transform != null, name +" must inherit from Node2D or Control node")
	
	if (control_self):
		var magnitude = control_self.scale.x if control_self.scale.x > control_self.scale.y else control_self.scale.y
		scale_magnitude = 1 #magnitude
	if (node2d_self): 
		var magnitude = transform.scale.x if transform.scale.x > transform.scale.y else transform.scale.y
		scale_magnitude = magnitude
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

var _active_event_count : int = 0

func opened() -> void:
	_active_event_count += 1
	var events_index : int = _active_event_count
	if (control_self):
		control_self.focus_mode = Control.FOCUS_ALL #makes focusable/selectable
		control_self.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if (open_animation_flags & 1 == 1):
		modulate = Color.TRANSPARENT
	
	if (open_animation_delay > 0): 
		await get_tree().create_timer(open_animation_delay).timeout
	if (_active_event_count != events_index): return
	show()
	await animate(open_animation_flags, open_time, false)
	#await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, open_animation_delay).finished # ANIMATION IN FUTURE

func closed() -> void:
	_active_event_count += 1
	var events_index : int = _active_event_count
	if (control_self):
		control_self.focus_mode = Control.FOCUS_NONE #makes unfocusable/unselectable
		control_self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, close_animation_delay).finished # ANIMATION IN FUTURE
	
	if (close_animation_delay > 0): 
		await get_tree().create_timer(close_animation_delay).timeout
	await animate(close_animation_flags, close_time, true)
	if (_active_event_count != events_index): return
	if (events_index == _active_event_count):
		hide()


#    1        2             4             8
## "Alpha", "Scale X", "Scale Y", "Rotate 90"
func animate(flags : int, time : float, closing : bool = false):
	if (tween): tween.kill()
	
	transitioning = true
	tween = create_tween()
	if (closing):
		tween.set_ease(Tween.EASE_OUT)
	else:
		tween.set_ease(Tween.EASE_IN)
	
	print(" the flags is  " + str(flags) + " and the closing value is  " + str(closing))
	if (flags & 1 == 1):
		print("animate alpha")
		modulate = modulate if closing else Color.TRANSPARENT
		var color : Color = Color.TRANSPARENT if closing else Color.WHITE
		tween.tween_property(self, "modulate", color, time).set_trans(tween_transition)
	
	var transform = control_self if control_self else node2d_self
	
	if (flags & 2 == 2 or flags & 4 == 4):
		print("animate scale")
		
		var scale_x : bool = flags & 2 == 2 
		var scale_y : bool = flags & 4 == 4
		print(" scaling x?  " + str(scale_x) + "   Scaling y? " + str(scale_y))
		var open_size : Vector2 = Vector2.ONE * scale_magnitude
		var close_size : Vector2 = Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		if control_self:
			transform.offset_transform_scale = transform.offset_transform_scale if closing else Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		else:
			transform.scale = transform.scale if closing else Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		
		print ("sacle is   " + str(close_size if closing else open_size))
		if (tween.has_tweeners()): tween.parallel()
		tween.tween_property(self, "offset_transform_scale" if control_self else "scale", close_size if closing else open_size, time).set_trans(tween_transition)
	
	if (flags & 8 == 8):
		var current_rotation : float = transform.offset_transform_rotation if control_self else transform.rotation
		var final_rotation : float = 2*PI if closing else default_rotation
		if control_self:
			transform.offset_transform_rotation = transform.offset_transform_rotation if closing else 2*PI
		else:
			transform.rotation = transform.rotation if closing else 2*PI
		if (tween.has_tweeners()): tween.parallel()
		tween.tween_property(self, "offset_transform_rotation" if control_self else "rotation", final_rotation, time).set_trans(tween_transition)
	transitioning = false
	
	if (tween.has_tweeners()):
		await tween.finished
	else:
		tween.kill()
		await get_tree().create_timer(time).timeout

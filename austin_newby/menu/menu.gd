@icon("uid://bxuu7q8b82trt")
extends Control
class_name Menu

@export var affects_other_menus : bool = true

@export var open_on_start : bool
@export var focused_control : Control

var is_open := false

@export var tween_transition : Tween.TransitionType
## when using scale, were usually locked to the top left as a pivot. turning this on counterbalances this behaviour with position
@export var size_pivot_centered : bool

@export_category("Open Animation")
## delay before starting the open animation
@export var open_animation_delay : float
## amount of time taken for open animation
@export var open_time : float = 0.4
## if enabled, all child items will have its alpha affected
@export var open_alpha_effects_all : bool
@export_subgroup("Animation Flags")
@export_flags("Alpha", "Scale X", "Scale Y", "Size X", "Size Y", "Rotate 180") var open_animation_flags : int

@export_category("Close Animation")
## amount of time taken for close animation
@export var close_time : float = 0.2
## if enabled, all child items will have its alpha affected
@export var close_alpha_effects_all : bool
## delay before starting the close animation
@export var close_animation_delay : float
@export_subgroup("Animation Flags")
@export_flags("Alpha", "Scale X", "Scale Y", "Size X", "Size Y", "Rotate 180") var close_animation_flags : int

@onready var scale_magnitude : float = scale.length()
@onready var default_pos : Vector2 = position
@onready var default_rotation : float = rotation
@onready var default_size : Vector2 = size

var transitioning : bool

signal menu_hidden
signal menu_closed
signal menu_shown
signal menu_transition_finished

func _enter_tree() -> void:
	if (affects_other_menus ): MenuManager.menus[self.name] = self

func _exit_tree() -> void:
	if (affects_other_menus ): MenuManager.menus.erase(self.name)

func _ready() -> void:
	print(size)
	if open_on_start: open()
	else: 
		close()
		hide()
	
	var magnitude = scale.x if scale.x > scale.y else scale.y
	scale_magnitude = magnitude
	#menu_hidden.emit()

func open() -> void:
	MenuManager.force_close()
	is_open = true
	print_rich("[color=spring_green]Opening menu: ", self)
	## some menus dont want focus, this may be causing focus issues
	#if focused_control == null:
		#focused_control = get_child(0)
		#print_rich("[color=spring_green]* No focus specified, defaulting to ", focused_control)
	control_grab_focus()
	
	menu_shown.emit()
	
	await _visuals_open()

func control_grab_focus():
	if (focused_control and !focused_control.has_focus()):
		
		## it really hates when its
		if (!focused_control.is_visible_in_tree()): 
			while (!focused_control.is_visible_in_tree()):
				await focused_control.visibility_changed
		print("focusing")
		focused_control.grab_focus.call_deferred()

func _visuals_open():
	focus_mode = Control.FOCUS_ALL #makes focusable/selectable
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	if (open_animation_flags & 1 == 1):
		self_modulate = Color.TRANSPARENT
	
	if (open_animation_flags & 4 == 4 or open_animation_flags & 2 == 2):
		scale = Vector2.ONE * scale_magnitude
	if (open_animation_flags & 8 != 8 and open_animation_flags & 16 != 16):
		size = default_size
	if (size_pivot_centered):
		position = default_pos
	
	if (open_animation_delay > 0): 
		await get_tree().create_timer(open_animation_delay).timeout
		if (!get_tree()): return
	animate(open_animation_flags, open_time, false)
	#modulate = Color.TRANSPARENT
	#await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, open_time).finished # ANIMATION IN FUTURE

func close() -> void:
	is_open = false
	print_rich("[color=dark_sea_green]Closing menu: ", self)
	
	menu_closed.emit()
	
	_visuals_close()
	

func _visuals_close():
	focus_mode = Control.FOCUS_NONE #makes unfocusable/unselectable
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if (close_animation_delay > 0): 
		await get_tree().create_timer(close_animation_delay).timeout
		if (!get_tree()): return
	await animate(close_animation_flags, close_time, true)
	
	#await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, close_time).finished # ANIMATION IN FUTURE
	hide()

var tween : Tween

#    1        2             4         8      16         32
## "Alpha", "Scale X", "Scale Y", "Size X", "Size Y", "Rotate 180"
func animate(flags : int, time : float, closing : bool = false):
	if (tween): 
		tween.stop()
		tween = null
	
	
	transitioning = true
	tween = create_tween()
	print(" the flags is  " + str(flags) + " and the closing value is  " + str(closing))
	if (flags & 1 == 1):
		print("animate alpha")
		var alpha_all : bool = close_alpha_effects_all if closing else open_alpha_effects_all 
		
		if (alpha_all):
			modulate = modulate if closing else Color.TRANSPARENT
			var color : Color = Color.TRANSPARENT if closing else Color.WHITE
			tween.tween_property(self, "modulate", color, time).set_trans(tween_transition)
		else:
			self_modulate = self_modulate if closing else Color.TRANSPARENT
			var color : Color = Color.TRANSPARENT if closing else Color.WHITE
			tween.tween_property(self, "self_modulate", color, time).set_trans(tween_transition)
	
	if (flags & 2 == 2 or flags & 4 == 4):
		print("animate scale")
		
		var scale_x : bool = flags & 2 == 2 
		var scale_y : bool = flags & 4 == 4
		print(" scaling x?  " + str(scale_x) + "   Scaling y? " + str(scale_y))
		var open_scale : Vector2 = Vector2.ONE * scale_magnitude
		var close_scale : Vector2 = Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		scale = scale if closing else Vector2(0 if scale_x else 1, 0 if scale_y else 1) * scale_magnitude
		
		tween.tween_property(self, "scale", close_scale if closing else open_scale, time).set_trans(tween_transition)
	
	if (flags & 8 == 8 or flags & 16 == 16):
		print("animate size")
		
		var size_x : bool = flags & 8 == 8 
		var size_y : bool = flags & 16 == 16
		var open_size : Vector2 = default_size
		var close_size : Vector2 = Vector2(0 if size_x else default_size.x, 0 if size_y else default_size.y)
		size = size if closing else Vector2(0 if size_x else default_size.x, 0 if size_y else default_size.y)
		
		tween.tween_property(self, "size", close_size if closing else open_size, time).set_trans(tween_transition)
	
	if (flags & 32 == 32):
		var current_rotation : float = rotation
		var final_rotation : float = 2*PI if closing else default_rotation
		rotation = rotation if closing else 2*PI
		tween.tween_property(self, "rotation", final_rotation, time).set_trans(tween_transition)
	
	await tween.finished
	menu_transition_finished.emit()
	transitioning = false

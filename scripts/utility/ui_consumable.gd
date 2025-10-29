@tool
class_name UIConsumable extends Control

@export_tool_button("Appear", "Add") var a = appear
@export_tool_button("Disappear", "Remove") var d = disappear

@export var fade_in: Curve:
	get():
		if fade_in == null:
			fade_in = Curve.new()
			fade_in.max_value = 1.5
			fade_in.add_point(Vector2(0,0))
			fade_in.add_point(Vector2(1,1))
			fade_in.add_point(Vector2(0.3,1.3))
		return fade_in
@export var fade_out: Curve:
	get():
		if fade_out == null:
			fade_out = Curve.new()
			fade_out.max_value = 1.5
			fade_out.add_point(Vector2(0,1))
			fade_out.add_point(Vector2(1,0))
			fade_out.add_point(Vector2(0.3,1.3))
		return fade_out
## how long the bounce animation will last
@export var lifetime : float = 0.3

@onready var og_scale : Vector2 = scale

var state: bool = false

func _ready() -> void:
	visible = false
	pivot_offset = size/2

func appear():
	var time = 0
	state = true
	visible = true
	while(time < lifetime and state):
		scale = og_scale * fade_in.sample(time / lifetime)
		await get_tree().process_frame
		time += get_process_delta_time()
	
func disappear():
	var time = 0
	state = false
	while(time < lifetime and not state):
		scale = og_scale * fade_out.sample(time / lifetime)
		await get_tree().process_frame
		time += get_process_delta_time()
	visible = false

# MIT License. 
# Made by Dylearn

# Node for ease of editing shader globals

@tool
extends Node

@export var cloud_contrast : float:
	set(value):
		cloud_contrast = value
		RenderingServer.global_shader_parameter_set("cloud_contrast", value)

@export var cloud_direction : Vector2:
	set(value):
		cloud_direction = value
		RenderingServer.global_shader_parameter_set("cloud_direction", value)

@export var cloud_diverge_angle : float:
	set(value):
		cloud_diverge_angle = value
		RenderingServer.global_shader_parameter_set("cloud_diverge_angle", value)

@export var cloud_scale : float:
	set(value):
		cloud_scale = value
		RenderingServer.global_shader_parameter_set("cloud_scale", value)

@export var cloud_speed : float:
	set(value):
		cloud_speed = value
		RenderingServer.global_shader_parameter_set("cloud_speed", value)

@export var cloud_threshold : float:
	set(value):
		cloud_threshold = value
		RenderingServer.global_shader_parameter_set("cloud_threshold", value)

@export var cloud_shadow_min : float:
	set(value):
		cloud_shadow_min = value
		RenderingServer.global_shader_parameter_set("cloud_shadow_min", value)

@export var cloud_world_y : float:
	set(value):
		cloud_world_y = value
		RenderingServer.global_shader_parameter_set("cloud_world_y", value)


func _ready():
	if Engine.is_editor_hint():
		cloud_contrast = RenderingServer.global_shader_parameter_get("cloud_contrast")
		cloud_direction = RenderingServer.global_shader_parameter_get("cloud_direction")
		cloud_diverge_angle = RenderingServer.global_shader_parameter_get("cloud_diverge_angle")
		cloud_scale = RenderingServer.global_shader_parameter_get("cloud_scale")
		cloud_speed = RenderingServer.global_shader_parameter_get("cloud_speed")
		cloud_threshold = RenderingServer.global_shader_parameter_get("cloud_threshold")
		cloud_shadow_min = RenderingServer.global_shader_parameter_get("cloud_shadow_min")
		cloud_world_y = RenderingServer.global_shader_parameter_get("cloud_world_y")

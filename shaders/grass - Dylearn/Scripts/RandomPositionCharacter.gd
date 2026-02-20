# MIT License. 
# Made by Dylearn

# Script for random NPC movement to demonstrate 
# grass displacement on characters of different sizes

@tool
extends CharacterBody3D

@export var camera: Camera3D
@export var speed: float = 6.0
@export var acceleration: float = 20.0
@export var wait_time: float = 0.1
@export var grass_displacement_size: float = 0.5

var target_position: Vector3
var waiting: bool = false
var wait_timer: float = 0.0

func _ready():
	set_physics_process(true)
	pick_new_target()

func _physics_process(delta):
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			waiting = false
			pick_new_target()
		return
	
	move_towards_target(delta)

func move_towards_target(delta):
	var to_target = target_position - global_position
	to_target.y = 0.0
	
	var distance = to_target.length()
	if distance < 0.1:
		velocity = Vector3.ZERO
		waiting = true
		wait_timer = wait_time
		return
	
	var move_dir = to_target.normalized()
	
	# Slow on arrival
	var slow_radius = 2.0
	var speed_scale = clamp(distance / slow_radius, 0.0, 1.0)
	
	var target_velocity = move_dir * speed * speed_scale
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()


func pick_new_target():
	target_position = get_random_visible_ground_point()

# Get a random point in the bottom half of the camera's view
func get_random_visible_ground_point() -> Vector3:
	var viewport = get_viewport()
	var screen_size = viewport.get_visible_rect().size
	
	for i in range(10): # Try a few times in case of bad rays
		var screen_pos = Vector2(
			randf() * screen_size.x,
			lerp(screen_size.y * 0.5, screen_size.y, randf()) # Bottom half of screen
		)
		
		var ray_origin = camera.project_ray_origin(screen_pos)
		var ray_dir = camera.project_ray_normal(screen_pos)
		
		# Ray-plane intersection (y = 0)
		if abs(ray_dir.y) > 0.001:
			var t = -ray_origin.y / ray_dir.y
			if t > 0.0:
				var point = ray_origin + ray_dir * t
				point.y = 0.0
				return point
	
	return global_position

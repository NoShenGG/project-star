class_name CorruptionAOE extends Node3D

@export_category("damage")
@export var damage : float = 2

@onready var end_timer: Timer = $EndTimer
@onready var grow_timer: Timer = $GrowTimer
@onready var hitbox: Hitbox = $Hitbox

var anchor_scale: Vector3
var scale_up: bool = true

func _ready():
	if grow_timer.timeout.is_connected(_on_grow_end):
		grow_timer.timeout.disconnect(_on_grow_end)
	if not end_timer.timeout.is_connected(_on_end_timer_timeout):
		end_timer.timeout.connect(_on_end_timer_timeout)
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	anchor_scale = global_transform.basis.get_scale()
	global_transform.basis = Basis.IDENTITY.scaled(Vector3(0, 0, 0))
	grow_timer.start()
	end_timer.start()

func _process(delta: float):
	var lerp_val := 1.0 - (grow_timer.time_left / grow_timer.wait_time)
	lerp_val = clamp(lerp_val, 0, 1)
	
	if scale_up:
		global_transform.basis = Basis.IDENTITY.scaled(Vector3(lerp(0.0, anchor_scale.x, lerp_val), \
															   lerp(0.0, anchor_scale.y, lerp_val), \
															   lerp(0.0, anchor_scale.z, lerp_val)))
	else:
		global_transform.basis = Basis.IDENTITY.scaled(Vector3(lerp(anchor_scale.x, 0.0, lerp_val), \
															   lerp(anchor_scale.y, 0.0, lerp_val), \
															   lerp(anchor_scale.z, 0.0, lerp_val)))

func _on_end_timer_timeout() -> void:
	if end_timer.timeout.is_connected(_on_end_timer_timeout):
		end_timer.timeout.disconnect(_on_end_timer_timeout)
	
	grow_timer.start()
	scale_up = false
	
	if not grow_timer.timeout.is_connected(_on_grow_end):
		grow_timer.timeout.connect(_on_grow_end)

func _on_grow_end() -> void:
	queue_free()
	
	var parent := get_parent()
	if parent != null and parent is SpitProjectileController:
		parent.queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if (body is Player):
		(body as Player).try_damage(damage)
	

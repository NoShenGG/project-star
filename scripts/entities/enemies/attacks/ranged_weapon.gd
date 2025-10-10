class_name RangedWeapon extends Node3D

@export var speed:= 10
var direction := Vector3.ZERO

@onready var timer: Timer = $Timer
@onready var hitbox: Hitbox = $Hitbox

func _ready():
	#set_as_top_level(true)
	look_at(direction)

	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if (is_same(body, GameManager.curr_player)):
		#do damage here
		queue_free()

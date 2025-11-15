class_name RangedWeapon extends Node3D

@export_category("speed")
@export var speed:= 10
@export_category("damage")
@export var damage : float = 2
var direction := Vector3.ZERO

@onready var timer: Timer = $Timer
@onready var hitbox: Hitbox = $Hitbox

func _ready():
	#set_as_top_level(true)
	#look_at(direction)
	self.look_at(direction)

	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	#look_at(direction)
	
	

func _on_timer_timeout() -> void:
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if (is_same(body, GameManager.curr_player)):
		#do damage here
		# GameManager.curr_player.try_damage(2)
		queue_free()

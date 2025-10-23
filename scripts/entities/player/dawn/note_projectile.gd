@abstract
class_name NoteProjectile extends Node3D

signal spawn
signal hit_enemy(enemy: Enemy)
signal destroyed

@export var hitbox: Area3D
@export var max_duration: float
@export var speed: float
@export var damage: float

var dawn: Dawn
var direction: Vector3

func setup(_dawn: Dawn, _params := {}) -> void:
	dawn = _dawn
	global_transform = dawn.global_transform
	direction = Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y)
	hitbox.body_entered.connect(hitbox_entered)

@abstract
func start() -> void

func _process(delta: float) -> void:
	global_position += direction * speed * delta

@abstract
func hitbox_entered(body: Node3D) -> void

@abstract
func destroy() -> void

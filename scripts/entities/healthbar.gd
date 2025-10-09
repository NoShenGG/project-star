extends Sprite3D

@onready var healthbar = $SubViewport/Health

@export var ANIM_TIME: float = 0.5
@export var BAR_ANIMATION_EASE_CURVE: Curve # Should be a 0 to 1 easing curve.

var hp: float
var old_hp: float
var anim_step: float

func _ready() -> void:
	hp = 100
	old_hp = 100
	anim_step = 1


func update_health(percent: float):
	old_hp = hp
	hp = percent * 100
	anim_step = 0

	
func _process(delta: float) -> void:
	if anim_step < 1:
		anim_step += delta/ANIM_TIME
	healthbar.value = old_hp + BAR_ANIMATION_EASE_CURVE.sample(clamp(anim_step, 0, 1)) * (hp - old_hp)

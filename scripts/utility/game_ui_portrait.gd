class_name GameUiPortrait
extends Control

@onready var healthbar = $Health
@export var special : Array[TextureProgressBar]

@export var ANIM_TIME: float = 0.5
@export var BAR_ANIMATION_EASE_CURVE: Curve # Should be a 0 to 1 easing curve.
@export var COLOR_GRADIENT: GradientTexture1D

var hp: float
var old_hp: float
var hp_step: float

func _ready() -> void:
	hp = 100
	old_hp = 100
	hp_step = 1
	#special.value = 100
	#special.tint_under = Color("ffff00")


func update_health(percent: float):
	old_hp = hp
	hp = percent * 100
	hp_step = 0
	
func update_special(percent: float):
	for cur_special in special:
		cur_special.value = percent * 100
		if cur_special.value == 100:
			cur_special.tint_under = Color("ffff00")
		elif cur_special.value == 0:
			cur_special.tint_under = Color("444444")
		else:
			cur_special.tint_under = Color("ffffff")

func on_death():
	modulate = Color("003359")

func _process(delta: float) -> void:
	if hp_step < 1:
		hp_step += delta/ANIM_TIME
	healthbar.value = old_hp + \
			BAR_ANIMATION_EASE_CURVE.sample(clamp(hp_step, 0, 1)) * (hp - old_hp)
	healthbar.tint_progress = COLOR_GRADIENT.gradient.sample(healthbar.value / 100)

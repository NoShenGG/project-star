extends Sprite3D

@onready var healthbar = $SubViewport/HealthCont/Health
@onready var breakbar = $SubViewport/BreakCont/Break

@export var ANIM_TIME: float = 0.5
@export var BAR_ANIMATION_EASE_CURVE: Curve # Should be a 0 to 1 easing curve.

var hp: float
var old_hp: float
var hp_step: float
var bk: float
var old_bk: float
var bk_step: float

func _ready() -> void:
	hp = 100
	old_hp = 100
	hp_step = 1
	await owner.owner
	var e = owner as Entity
	if not e.health_update.is_connected(update_health):
		e.health_update.connect(update_health)
	if not e.break_update.is_connected(update_break):
		e.break_update.connect(update_break)
	if not e.killed.is_connected(death):
		e.killed.connect(death)

func update_health(percent: float):
	old_hp = hp
	hp = percent * 100
	hp_step = 0
	

func update_break(percent: float):
	old_bk = bk
	bk = percent * 100
	bk_step = 0

func death():
	self.hide()
	
func _process(delta: float) -> void:
	if hp_step < 1:
		hp_step += delta/ANIM_TIME
	healthbar.value = old_hp + \
			BAR_ANIMATION_EASE_CURVE.sample(clamp(hp_step, 0, 1)) * (hp - old_hp)
	if bk_step < 1:
		bk_step += delta/ANIM_TIME
	breakbar.value = old_bk + \
			BAR_ANIMATION_EASE_CURVE.sample(clamp(bk_step, 0, 1)) * (bk - old_bk)
	breakbar.get_parent().visible = breakbar.value != 0

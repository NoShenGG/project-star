class_name Invincible extends EntityEffect

var fortifier: Fortifier
var active: bool

func _init(_fortifier: Fortifier) -> void:
	id = EffectID.INVINCIBLE;
	fortifier = _fortifier
	fortifier.killed.connect(func(): active = false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> bool:
	if abs(get_parent().global_position.distance_to(fortifier.global_position)) > fortifier.attack_radius:
		fortifier.reset_shield()
		return false
	return active

func stop() -> void:
	pass

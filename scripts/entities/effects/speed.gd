class_name Speed extends EntityEffect

var active: bool = true
var strength: float

func _init(_strength := 1.5) -> void:
	strength = _strength
	id = EffectID.SPEED;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active = true
	_entity._movement_speed *= strength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> bool:
	return active
	
func end_effect() -> void:
	active = false

func stop() -> void:
	_entity._movement_speed /= strength

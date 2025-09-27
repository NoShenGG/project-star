class_name Invincible extends EntityEffect

var fortifier: Fortifier
var active: bool

func _init(_fortifier: Fortifier) -> void:
	id = EffectID.INVINCIBLE;
	fortifier = _fortifier
	fortifier.resetting.connect(func () -> void: active = false)
	fortifier.killed.connect(func () -> void: active = false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> bool:
	return active

func stop() -> void:
	pass

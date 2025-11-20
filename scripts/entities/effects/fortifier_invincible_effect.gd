class_name FortifierInvincible extends EntityEffect


const vfx = preload("res://vfx/fortifier_shield_VFX.tscn")

var fortifier: Fortifier
var active: bool

func _init(_fortifier: Fortifier) -> void:
	id = EffectID.INVINCIBLE;
	fortifier = _fortifier
	fortifier.killed.connect(func(): active = false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active = true
	
func try_apply(entity: Entity) -> bool:
	if super(entity):
		entity.invincible = true
		var vfx_instance = vfx.instantiate() as Node3D
		vfx_instance.position = Vector3.UP * 1.3
		add_child((vfx_instance))
		return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> bool:
	if not active or fortifier == null:
		return false
	if _entity.global_position.distance_to(fortifier.global_position) > fortifier.attack_radius:
		return false
	return true

func stop() -> void:
	if fortifier != null:
		if not fortifier.death:
			fortifier.reset_shield()
	_entity.invincible = false

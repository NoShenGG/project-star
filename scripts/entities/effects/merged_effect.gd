class_name Merged extends EntityEffect

signal enemy_killed(effect: Merged)

var active: bool
var target: Vector3

func _init(merger: MindMerger) -> void:
	id = EffectID.MERGED
	active = true
	merger.killed.connect(func () -> void: active = false)

func try_apply(entity: Entity) -> bool:
	if super(entity):
		_entity.killed.connect(enemy_killed.emit.bind(self))
		return true;
	return false
	
func set_target(_target: Vector3):
	target = _target
	
func process(_delta: float) -> bool:
	(_entity as Enemy).set_ai_override(true, target)
	return active;

func stop() -> void:
	(_entity as Enemy).set_ai_override(false);

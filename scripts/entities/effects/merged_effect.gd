class_name Merged extends EntityEffect

var merger: MindMerger
var index: int
var active: bool
var target: Vector3

func _init(_merger: MindMerger, _index: int) -> void:
	id = EffectID.MERGED
	merger = _merger
	index = _index
	active = true
	merger.update.connect(func (pos) -> void: target = pos[index] if index < pos.size() else Vector3.ZERO)
	merger.killed.connect(func () -> void: active = false)
	merger.reindex.connect(func (new) -> void: index = new[index])

func try_apply(entity: Entity) -> bool:
	if super(entity):
		_entity.killed.connect(func () -> void: merger.remove_minion(index))
		return true;
	return false
	
func process(_delta: float) -> bool:
	(_entity as Enemy).set_movement_target(target)
	# Something Else Maybe
	return active;

func stop() -> void:
	return;

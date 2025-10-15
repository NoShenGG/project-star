@tool
class_name SlashVFX
extends GPUTrail3D

@export var survival_time : float = 0.2
var sword : Node3D
var start_pos : Vector3
var slashing : bool

signal slash_start
signal slash_stop

func _ready():
	super()
	if (Engine.is_editor_hint()): return
	sword = get_parent()
	start_pos = position
	reparent(owner)
	hide()

func start():
	slashing = true
	restart()
	emitting = true
	show()
	sword_update()
	slash_start.emit()

func sword_update():
	while (slashing):
		
		global_position = sword.global_transform * start_pos
		await get_tree().process_frame

func stop():
	emitting = false
	slashing = false
	#reparent(owner)
	if (survival_time > 0):
		await get_tree().create_timer(survival_time).timeout
	
	position = sword.global_transform * start_pos
	hide()
	slash_stop.emit()

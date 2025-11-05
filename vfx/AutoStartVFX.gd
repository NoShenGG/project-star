@tool
extends Pooled3D

class_name AutoStartVFX

@export_category("Debugging")
@export var play : bool : 
	set(state):
		debug_play(state)

@export var stop : bool : 
	set(state):
		debug_stop(state)


@export_category("Playing")
@export var play_on_start : bool = true
@export_enum("Pool on Stop", "Destroy on Stop") var on_stop : int = 0
## less than 0 is looping until stop
@export var lifetime : float = 0

@export var light : Light3D
@export var flare : Node3D
@export var particles : Array[GPUParticles3D]
@export var audio : AudioStreamPlayer3D

signal start
signal finished

func _process(delta):
	if (Engine.is_editor_hint() and play):
		play = false
		restart_particles()

func debug_play(state : bool):
	restart_particles()

func debug_stop(state : bool):
	stop_particles()

func start_timer():
	if (lifetime <= 0):
		return
	
	await get_tree().create_timer(lifetime).timeout
	if (!get_tree()): 
		return
	stop_particles()

func _enter_tree() -> void:
	if (Engine.is_editor_hint()):
		get_particles()
		child_entered_tree.connect(add_particle)
		child_exiting_tree.connect(remove_particle)
		for particle in particles:
			particle.child_entered_tree.connect(add_particle)
			particle.child_exiting_tree.connect(remove_particle)

func _exit_tree() -> void:
	if (Engine.is_editor_hint()):
		child_entered_tree.disconnect(add_particle)
		child_exiting_tree.disconnect(remove_particle)
		for particle in particles:
			particle.child_entered_tree.disconnect(add_particle)
			particle.child_exiting_tree.disconnect(remove_particle)

# Called when the node enters the scene tree for the first time.
func _ready():
	if (Engine.is_editor_hint()): return
	
	## if we arent pooled, we call
	if (play_on_start and on_stop != 0): 
		restart_particles()
		print("uh oh!")

func spawn():
	if (play_on_start and on_stop != 1):
		restart_particles()
		if (audio):
			audio.play()
	super()

func get_particles():
	particles.clear()
	if ((self as Node) as GPUParticles3D):
		particles.append((self as Node) as GPUParticles3D)
	
	particles.append_array(get_all_children(self).filter(func(x): return x is GPUParticles3D))

func add_particle(node : Node):
	if (node as GPUParticles3D):
		particles.append(node as GPUParticles3D)
		node.child_entered_tree.connect(add_particle)

func remove_particle(node : Node):
	if (particles.has(node)):
		particles.remove_at(particles.find(node))

func restart_particles():
	for particle in particles:
		particle.restart()
	## redundant code cause yall dont have quality vary much (yet?)
	#if (light && !GameSettings.mobile_vr): light.visible = true
	if (flare): flare.visible = true
	start.emit()
	start_timer()

func stop_particles():
	if (light): light.visible = false
	if (flare): flare.visible = false
	var max_emitting_time : float = 0
	for particle in particles:
		particle.emitting = false
		if (particle.lifetime > max_emitting_time): max_emitting_time = particle.lifetime
	await get_tree().create_timer(max_emitting_time).timeout
	finished.emit()
	if (!Engine.is_editor_hint()):
		if (on_stop == 0):
			#print("pooled")
			pool()
		else:
			#print("freed")
			queue_free()

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

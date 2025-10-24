@icon("uid://megolcw1kt24")
class_name ToneEmitter extends Node

@export var melody: PackedScene
@export var slow_wave: PackedScene
@export var fish: PackedScene
@export var wave: PackedScene
@export var stun_wave: PackedScene
@export var vortex_note: PackedScene
@export var ice_zone: PackedScene

var dawn: Dawn

func _ready() -> void:
	await owner.ready
	dawn = owner as Dawn
	assert(dawn != null)
	assert(melody != null)
	assert(slow_wave != null)
	#assert(fish != null)
	assert(wave != null)
	#assert(stun_wave != null)
	#assert(vortex_note != null)
	#assert(ice_zone != null)

func spawn_melody() -> void:
	var temp: Tone = melody.instantiate()
	add_child(temp)
	temp.setup(dawn)
	temp.start()

func spawn_slow_wave() -> void:
	var temp: Tone = slow_wave.instantiate()
	add_child(temp)
	temp.setup(dawn)
	temp.start()

func spawn_fish() -> void:
	var temp = fish.new()
	add_child(temp)

func spawn_wave() -> void:
	var temp: Tone = wave.instantiate()
	add_child(temp)
	temp.setup(dawn)
	temp.start()

func spawn_stun_wave() -> void:
	var temp = stun_wave.new()
	add_child(temp)

func spawn_vortex_note() -> void:
	var temp = vortex_note.new()
	add_child(temp)

func spawn_ice_zone() -> void:
	var temp = ice_zone.new()
	add_child(temp)

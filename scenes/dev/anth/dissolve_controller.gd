extends Node3D

@export_category("Shader Controls")
@export var dissolve : float
@export var dissolveColor : Color
@export var pixelate : float = 4.0
## Controls speed and direction of the dissolve motion, positive for up, negative for down
@export var speed : float = -1
## Controls the cell size of the dissolve, smaller values = bigger cells
@export var cellSize : float = 20.0
@export var noiseScale : float = 5.0
@export var dissolveBegin : float = 0.8
@export var dissolveDuration : float = 2

@export_category("Animation")
@export var animCurve : Curve

@export_category("References")
@export var material : Material
@export var meshes : Array[MeshInstance3D]

var mat : Material
var mats : Array[Material] = []

func _ready():
	set_default_params()

func setup_materials():
	mats.clear()

	for m in meshes:
		if m == null:
			continue
		
		var surface_count : int = m.mesh.get_surface_count()
		
		for i in range(surface_count):
			var inst := material.duplicate()
			m.set_surface_override_material(i, inst)
			mats.append(inst)

func set_default_params():
	for m in mats:
		m.set_shader_parameter("Pixelate", pixelate)
		m.set_shader_parameter("Speed", speed)
		m.set_shader_parameter("UVScale", cellSize)
		m.set_shader_parameter("NoiseScale", noiseScale)
		m.set_shader_parameter("DissolveBegin", dissolveBegin)

#func _input(event):
	#if event is InputEventKey and event.pressed and event.keycode == KEY_Z:
		#beginDissolve(2.0)

# Main function
func beginDissolve() -> void:
	setup_materials()
	play_curve(dissolveDuration)

func play_curve(duration: float) -> void:
	if animCurve == null:
		return
	
	var time = 0
	var point_count := animCurve.get_point_count()
	if point_count == 0:
		return

	var maxValue := animCurve.get_point_position(point_count - 1).x
	
	while time < duration:
		var t = time / duration
		var curve_t = t * maxValue
		var value = animCurve.sample(curve_t)
		
		dissolve = value
		#mat.set_shader_parameter("Dissolve", dissolve)
		#mat.set_shader_parameter("DissolveColor", dissolveColor)
		set_param_all("Dissolve", dissolve)
		
		await get_tree().process_frame
		time += get_process_delta_time()
		
	#clamp end value
	#mat.set_shader_parameter("Dissolve", animCurve.sample(maxValue))
	set_param_all("Dissolve", animCurve.sample(maxValue))
	
func set_param_all(name: StringName, value):
	for m in mats:
		m.set_shader_parameter(name, value)

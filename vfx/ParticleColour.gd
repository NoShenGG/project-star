@tool
extends Node

@export var color : Color

@export var materials : Array[Material]
@export var light : Light3D

func _process(delta):
	if (Engine.is_editor_hint()):
		for material in materials:
			recolor(material)
		if (light):
			light.light_color = color

func recolor(material : Material):
	if (material is StandardMaterial3D):
		material.emission = color
	if (material is ShaderMaterial):
		var shader_material : ShaderMaterial = material as ShaderMaterial
		if (shader_material.shader.resource_name == "thruster"):
			shader_material.set_shader_parameter("basse_color", color)
			var emission_color = color
			emission_color.h += 0.05
			#emission_color.s -= 0.05
			shader_material.set_shader_parameter("emission_color", emission_color)

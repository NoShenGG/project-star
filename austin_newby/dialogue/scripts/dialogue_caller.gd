extends Node

@export var dialogue : Array[DialogueResource]

func activate_dialogue() -> void:
	DialogueContainer.read(dialogue)

func _on_body_entered(body: Node3D) -> void:
	activate_dialogue()

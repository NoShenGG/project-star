extends Area3D

@onready var dialogue_container: DialogueContainer = $"../../DialogueContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_container.read("res://austin_newby/dialogue/resources/DialogueTest.json", "initial_scene")

func _on_body_entered(body: CharacterBody3D) -> void:
	if (is_same(body, GameManager.curr_player)): #in case switching player
		dialogue_container.read("res://austin_newby/dialogue/resources/DialogueTest.json", "scene2")

@abstract
class_name State extends Node

signal finished(next_state: String, data: Dictionary)

@abstract
func update(_delta: float) -> void

@abstract
func physics_update(_delta: float) -> void

# Called on state enter
@abstract
func enter(prev_state: String, data := {}) -> void

# Call for another script to end this state
@abstract
func end() -> void
	
# Called on state exit
@abstract
func exit() -> void

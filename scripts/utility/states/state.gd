@abstract
class_name State extends Node

signal entered(state: String, prev_state: String, data: Dictionary)
signal finished(state: String, next_state: String, data: Dictionary)

## Called on state machine process
@abstract
func update(_delta: float) -> void

## Called on state machine physics process
@abstract
func physics_update(_delta: float) -> void

## Called on state enter. Make sure to emit entered.
@abstract
func enter(_prev_state: String, _data := {}) -> void

## Call for another script to end this state. Should pick the next state and emit finished.
@abstract
func end() -> void
	
## Called on state exit
@abstract
func exit() -> void

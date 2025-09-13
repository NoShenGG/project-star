'''REVERSE CONTROL - Reverses user control. contributed by Zifeng Xue.
Add this node to the main node tree to make it work.
Reverses movement controls, does not change anything else.
Provides a boolean variable that may be used as the switch for this.
Also provides an integrated timer that works as the time limit for reversing input,
which should come in handy when you want to set this as a debuff for a certain time period.

See the descriptions of the methods for specific information.
'''

extends Node

#how long you wish to keep the input reversed if you use the reverseOnWithTimer() method.
#default is zero, so make sure to reassign it with a value before you use it for anything new.
@export var reverseTime:float = 0.0;

#status of reversing input mapping.
var reverseInputOn:bool = false

#get all InputEvents for movements and store them for further uses.
#yes i know this is dumb, but this would be compatible for non-QWERTY keyboards.
#i can also make adjustments for joypad too if required btw
var normalLeftEvent:InputEvent = InputMap.action_get_events("move_left").get(0)
var normalRightEvent:InputEvent = InputMap.action_get_events("move_right").get(0)
var normalUpEvent:InputEvent = InputMap.action_get_events("move_up").get(0)
var normalDownEvent:InputEvent = InputMap.action_get_events("move_down").get(0)


func _ready() -> void:
	pass

#make input go reverse when called.
func reverseOn() -> void:
	reverseInputOn = true
	#release the input actions first to avoid glitches. see description for _releaseInputActions() for more.
	_releaseInputActions()
	#clear Input Mapping for WASD
	_clearInputMapping()
	#reverse the input
	_reverseInputMapping()
	
#restore input mapping when called.
#when player quits the game or the current level, call again to avoid troubles,
#cuz we probably don't want players to return to the level finding that the input is still reversed after a S/L. or do we......?
func reverseOff() -> void:
	reverseInputOn = false
	#release the input actions first to avoid glitches. see description for _releaseInputActions() for more.
	_releaseInputActions()
	#clear Input Mapping for WASD
	_clearInputMapping()
	#restore the input back to normal.
	_restoreInputMapping()
	
#for enemies that will only cast this as a debuff for a certain amount of time, call this function.
#the input will immediately be reversed, but will restore itself after a certain amount of time.
#the time can be controlled by the exported double-type variable: reverseTime.
func reverseOnWithTimer() -> void:
	reverseOn()
	$AutoRestoreTimer.start(reverseTime)

#removes the current inputEvents for the movement actions.
#only locally called. do not call this.
func _clearInputMapping() -> void:
	InputMap.action_erase_events("move_left")
	InputMap.action_erase_events("move_right")
	InputMap.action_erase_events("move_up")
	InputMap.action_erase_events("move_down")

#release the WASD input actions to allow the changes to set in.
#this avoids the glitch that occurs when input mapping is changed while user is still pressing WASD.
#only locally called. do not call this.
func _releaseInputActions() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")

#reverses input mapping.
#only locally called. do not call this.
func _reverseInputMapping() -> void:
	InputMap.action_add_event("move_left", normalRightEvent)
	InputMap.action_add_event("move_right", normalLeftEvent)
	InputMap.action_add_event("move_up", normalDownEvent)
	InputMap.action_add_event("move_down", normalUpEvent)
	
#restores input mapping.
#only locally called. do not call this.
func _restoreInputMapping() -> void:
	InputMap.action_add_event("move_left", normalLeftEvent)
	InputMap.action_add_event("move_right", normalRightEvent)
	InputMap.action_add_event("move_up", normalUpEvent)
	InputMap.action_add_event("move_down", normalDownEvent)

#When the timer goes timeout, signal is sent to turn off the reverse controls.
#only locally called. do not call this.
func _on_auto_restore_timer_timeout() -> void:
	reverseOff()

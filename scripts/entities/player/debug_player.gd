## Debug Player Implementation
class_name DebugPlayer extends Player

func _physics_process(delta):
	super(delta)
	
## These are called when a valid input is recieved. It is up to the specific impl to handle attack sequences.
func _basic_attack() -> void:
	print("Attack")
	await get_tree().create_timer(0.4).timeout
	current_state = PlayerState.IDLE

func _charged_attack() -> void:
	print("Charged for "+str(charge_counter))
	current_state = PlayerState.IDLE
	
func _special_attack() -> void:
	print("Special!!!")
	current_state = PlayerState.IDLE

func _charged_special_attack() -> void:
	print("Special!!! Charged for "+str(charge_counter))
	current_state = PlayerState.IDLE


## For these make sure to call super first to set player state	
func synergy_burst() -> void:
	super()
	print("BURST!!!!!")
	
func swap_out() -> void:
	super()
	print("Bye!")
	
func swap_in() -> void:
	super()
	print("Hi!")

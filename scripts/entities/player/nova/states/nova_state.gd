@abstract
class_name NovaState extends PlayerState

var nova: Nova

func _ready() -> void:
	super()
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

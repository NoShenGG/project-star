@abstract
class_name NovaComboState extends ComboState

var nova: Nova


## Saves instance of Nova as variable
func _ready() -> void:
	super()
	nova = owner as Nova
	assert(nova != null, "Must only be used with Nova")

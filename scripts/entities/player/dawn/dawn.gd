class_name Dawn extends Player


@export var note_manager: DawnNotes
@export var note_emitter: NoteEmitter

func _process(_delta: float) -> void:
	super(_delta)
	if Input.is_key_pressed(KEY_T):
		note_emitter.spawn_melody()

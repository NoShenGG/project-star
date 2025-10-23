@icon("uid://cs4evvn2khwf0")
class_name DawnNotes extends Node3D

@export var ui_note1: TextureRect
@export var ui_note2: TextureRect
@export var ui_note3: TextureRect
var ui_notes: Array[TextureRect]

signal white
signal blue
signal red
signal new_note(note: Note)
signal valid_pattern(id: Patterns)
signal notes_used

enum Note {WHITE=1, BLUE=2, RED=4}
enum Patterns {INVALID=0, BASS=3, FORTE=5, HIGH_TIDE=9, SIREN_SONG=7, CHILLING_TUNE=10, ACCELERANDO=8}

const WHITE = Note.WHITE
const BLUE = Note.BLUE
const RED = Note.RED


var notes: Array[Note] = []

func _ready() -> void:
	ui_notes = [ui_note1, ui_note2, ui_note3]
	print(ui_notes)


func add_note(note: Note) -> bool:
	print("HERE")
	if notes.size() >= 3:
		return false
	notes.push_back(note)
	new_note.emit(note)
	match note:
		Note.WHITE:
			ui_notes[notes.size() - 1].modulate = Color("ffffff")
			ui_notes[notes.size() - 1].appear()
			white.emit()
		Note.BLUE:
			ui_notes[notes.size() - 1].modulate = Color("0000ff")
			ui_notes[notes.size() - 1].appear()
			blue.emit()
		Note.RED:
			ui_notes[notes.size() - 1].modulate = Color("ff0000")
			ui_notes[notes.size() - 1].appear()
			red.emit()
	if notes.size() >= 3:
		valid_pattern.emit(notes.reduce(func(accum, x): return accum + x, 0))
	return true

func add_white() -> bool:
	return add_note(Note.WHITE)

func add_blue() -> bool:
	return add_note(Note.BLUE)

func add_red() -> bool:
	return add_note(Note.RED)

# Every valid pattern has a unique id (see spreadsheet) so if there are 3 notes, return their sum
func use_notes() -> Patterns:
	if notes.size() < 3:
		return Patterns.INVALID
	var id: int = notes.reduce(func(accum, x): return accum + x, 0)
	notes.clear()
	notes_used.emit()
	return id as Patterns

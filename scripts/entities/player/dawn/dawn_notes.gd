class_name DawnNotes extends Node3D


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


func add_note(note: Note) -> bool:
	if notes.size() >= 3:
		return false
	notes.push_back(note)
	new_note.emit(note)
	match note:
		Note.WHITE:
			white.emit()
		Note.BLUE:
			blue.emit()
		Note.RED:
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

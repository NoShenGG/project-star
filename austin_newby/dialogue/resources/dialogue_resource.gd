@icon("uid://3ua7x58w6l7k")
extends Resource
class_name DialogueResource

@export var name := ""
@export var img : Texture2D = null
@export_multiline var text := ""
@export var small_img : Texture2D = null
@export_multiline var small_text := "" 
@export_file_path() var audio : String

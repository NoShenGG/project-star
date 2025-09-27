'''
Voila here is the simplified GameSequencer. This has the potential to grow into a global GameManager...... 
'''

extends Node

signal loadingNext

#Constant paths.
#THESE PATHS ARE SUBJECT TO CHANGE.
var GSPATH:String = "res://Game/GameSequencer.gssave"
var LEVELPATH:String = "res://ExampleScenes/"
var LEVELPREVIEWPATH:String = ""#if we want level preview images, put the directory here.

#Requires loading.
@export var currentLevel:int = 0
@export var dict_Levels = {}
'''
{"LevelName" : boolean}
level name : status (beaten or not)
'''

#Runtime and object to frequent change.
var levelToLoad:PackedScene

'''
FUNCTIONS - Normal
'''

func _ready() -> void:
	loadGS()
	
'''
FUNCTIONS - Specific
'''

#Loading GameSequencer
func loadGS() -> void:
	if !FileAccess.file_exists(GSPATH):
		print("error: GameSequencer.gssave not found")
	else:
		var readAccess = FileAccess.open(GSPATH, FileAccess.READ)
		'''
		we are only saving the levels in one line, which means we may not need this specific .gssave file.
		this can be integrated into/as a GameManager.
		But for the sake of demonstration we will have a .gssave file dedicated to GameSequencer.
		'''
		var jsonHelper = JSON.new()
		var jsonString = readAccess.get_line()
		var parseResult = jsonHelper.parse(jsonString)
		if !parseResult == OK:
			print("error: failed to parse from GameSequencer.gssave")
		else:
			dict_Levels = jsonHelper.data

#Instantiate and load a map scene as Node3D. This can be changed.
func loadMap(arg:Variant) -> Node3D:
	loadingNext.emit()#CONNECT THIS SIGNAL TO GAMEMANAGER AND SUCH TO FREE THE PREVIOUS MAP AND STUFF
	#get the target path
	var targetPath:String
	if typeof(arg) == 2:#arg is an Integer
		targetPath = LEVELPATH + dict_Levels.keys()[arg] + ".tscn"
	elif !typeof(arg) == 4:#and if arg is not a String, we cannot know what the caller want with us.
		print("error: calling loadMap() with bad arg")
		return null
	else:#String arg
		targetPath = LEVELPATH + arg + ".tscn"
	
	
	#instantiate the scene.
	levelToLoad = load(targetPath)
	if levelToLoad == null:
		print("error: failed to load as PackedScene")
		return null
	else:
		#add to GameSequencer node as a child node
		var mapNode = levelToLoad.instantiate()
		if mapNode == null:#failed to instantiate
			print("error: failed to instantiate map node")
			return null
		#change current level
		if typeof(arg) == 2:
			currentLevel = arg
		else:
			currentLevel = dict_Levels.find(arg)
		return mapNode

#the simple function for loading next level.
#DO NOT USE THIS WHEN THERE IS NO CURRENT LEVEL IT WILL TAKE YOU TO LEVEL 1 INSTEAD OF LEVEL 0
func loadNextMap() -> Node3D:
	return loadMap(currentLevel+1)

#developer's tools. don't call these when this whole thing is implemented.
func saveGSToFile():
	var saveAccess = FileAccess.open(GSPATH, FileAccess.WRITE)
	var jsonString = JSON.stringify(dict_Levels)
	saveAccess.store_line(jsonString)

func _on_devtool_make_gs_data() -> void:
	dict_Levels["LEVEL 1"] = false
	dict_Levels["LEVEL 2"] = true
	dict_Levels["LEVEL 3"] = false

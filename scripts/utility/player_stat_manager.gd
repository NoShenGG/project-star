extends Node
class_name statTracker

#Can all be accessed directly by name or the
#corresponding getter/setter method.

#Tracked Stats
var timeInLevel: float = 0
var highestDmgAttack: float = 0
var totalDmgDealt: float = 0

#Local/Logic Variables
var paused: bool = false

func _process(delta: float) -> void:
	if not paused:
		timeInLevel += delta

#### Stat resets ####

#Returns the previous timeInLevel then resets and pauses the timer
func resetLevelTime() -> float:
	var oldTime = timeInLevel
	timeInLevel = 0
	paused = true #TBD if this is necassary
	return oldTime

func resetHighestDmg() -> float:
	var oldHigh = highestDmgAttack
	highestDmgAttack = 0
	return oldHigh

func resetTotalDmg() -> float:
	var oldTot = totalDmgDealt
	totalDmgDealt = 0
	return oldTot

#Returns all variables in the order of there variables
func resetAll() -> Array:
	var toReturn: Array = [timeInLevel, highestDmgAttack, totalDmgDealt]
	
	timeInLevel = 0
	highestDmgAttack = 0
	totalDmgDealt = 0
	
	return toReturn

#### TIMER CONTROLS ####

func startLevelTime():
	paused = false

func pauseLevelTime():
	paused = true

func toggleLevelTime():
	paused = !paused

##### SETTER/ADDER METHODS #####

#Adds to max level time
func addLevelTime(newTime: float):
	timeInLevel += newTime

#Compares incoming damage to the current highest damage attack. Then adds to total damage.
func addDmg(incomingDmg: float):
	if incomingDmg > highestDmgAttack:
		highestDmgAttack = incomingDmg
	totalDmgDealt += incomingDmg

##### GETTER METHODS #####

func getLevelTime() -> float:
	return timeInLevel

func getHighestDmg() -> float:
	return highestDmgAttack

func getTotalDmg() -> float:
	return totalDmgDealt

func getAllStats() -> Array:
	return [timeInLevel, highestDmgAttack, totalDmgDealt]

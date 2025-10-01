#THIS IS CREATED BY Zifeng Xue.

extends Node3D


@export var MAX_HP:float = 50;
@export var MAX_BM:float = 300;
@export var COUNTDOWN:float = 4.0;
@export var SD_BM_CONVERTRATIO:float = (MAX_BM*(2/3))/3;
@export var SPEED:float = 1;
@export var SPEED_SELFDESTRUCTION:float = 3;
@export var DAMAGE:float = 300;#IDK ABOUT THE VALUES PLEASE SOMEBODY TELL ME THE METERS FOR DAMAGE AND HP

@export var DETECT_DISTANCE:float = 10;
@export var TRIGGER_DISTANCE:float = 5;

@export var BM_DMGSlOPE:float = 0.75/MAX_BM;
@export var BM_DMGREDUCTION_MIN = 0.2;
@export var BM_DMGREDUCTION_MAX = 0.95;

var playerPosition:Vector3;


var detectedPlayer:bool;
var speed:float;
var healthPoint:float;
var breakMeter:float;
var damageReductionRatio:float;
var selfDestructionProcessOn:bool:
	set(val):
		if val:
			speed = SPEED_SELFDESTRUCTION;

var isBroken:bool:
	set(val):
		if val:
			pass#to implement: breaking down process
		else:
			pass;
		
var isDead:bool;





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#game setup
	detectedPlayer = false;
	speed = SPEED;
	healthPoint = MAX_HP;
	breakMeter = MAX_BM;
	isBroken = false;
	isDead = false;
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
# MAIN ENEMY AI
func _physics_process(delta: float) -> void:
	
	damageReductionCalculation_BM()
	
	if !isDead:#NOT DEAD YET
		#If hasn't found player yet:
		if detectedPlayer == false:
			if CalculateRelativeDistanceToPlayer(playerPosition) < DETECT_DISTANCE:
				#detected
				print("detected")
				detectedPlayer = true;
		else:
			#Move closer to player.
			ApproachDesignatedLocation(playerPosition);
		
		
		
		#Monitors relative position and distance. if too close then launches the self destruction process.
		if CalculateRelativeDistanceToPlayer(playerPosition) < TRIGGER_DISTANCE:
			if !selfDestructionProcessOn:
				selfDestructionProcessOn = true
				$SelfDestructionTimer.start()
		
		if selfDestructionProcessOn:
			breakMeterCountdownReduction();#Recalculate break meter.
			
			
		


func PlayerPositionUpd(pos:Vector3) -> void:
	playerPosition = pos;

func CalculateRelativeDistanceToPlayer(desigLocation:Vector3) -> float:
	var relativeDistance = (desigLocation - global_transform.origin).length();
	return relativeDistance

func ApproachDesignatedLocation(desigLocation:Vector3) -> void:
	var directionToLocation = (desigLocation - $CharacterBody3D.global_transform.origin).normalized();
	$CharacterBody3D.velocity = directionToLocation * speed;
	$CharacterBody3D.move_and_slide();

func breakMeterCountdownReduction() -> void:#ONLY USE THIS WHEN COUNTDOWN IS ACTIVE.
	breakMeter = MAX_BM - (COUNTDOWN - $SelfDestructionTimer.time_left)*SD_BM_CONVERTRATIO;

func damageReductionCalculation_BM() -> void:#ALWAYS CALL THIS TO SHOW DAMAGE REDUCTION CALCULATION.
	damageReductionRatio = BM_DMGREDUCTION_MIN + SD_BM_CONVERTRATIO*breakMeter;

func breakDown() -> void:
	pass;#I do not yet know what will happen when an enemy breaks down, so I'll leave this blank for now. to be implemented.

func die() -> void:
	pass;

func _on_self_destruction_timer_timeout() -> void:
	$ExplosionResponse.show();
	isDead = true;
	$DeathTimer.start();
	


func _on_death_timer_timeout() -> void:
	$ExplosionResponse.hide()
	queue_free();

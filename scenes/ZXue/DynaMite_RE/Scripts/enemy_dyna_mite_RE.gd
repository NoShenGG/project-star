@abstract
class_name DynaMiteRE extends Enemy

@export var MAX_HP:float = 50;
@export var MAX_BM:float = 300;
@export var COUNTDOWN:float = 4.0;
@export var SD_BM_CONVERTRATIO:float = (MAX_BM*(2/3))/3;
@export var SPEED:float = 1;
@export var SPEED_SELFDESTRUCTION:float = 10;
@export var DAMAGE:float = 300;#IDK ABOUT THE VALUES PLEASE SOMEBODY TELL ME THE METERS FOR DAMAGE AND HP

@export var DETECT_DISTANCE:float = 10;
@export var TRIGGER_DISTANCE:float = 7;

@export var BM_DMGSlOPE:float = 0.75/MAX_BM;
@export var BM_DMGREDUCTION_MIN = 0.2;
@export var BM_DMGREDUCTION_MAX = 0.95;

# Base class for the other cell types, likely
extends Node2D

enum type {
	DIRT,
	LICHEN,
	ANNUAL,
	PERRENIAL,
	FAST_TREE,
	SLOW_TREE
}

var current_type = 0

# nutrients
var water : int = 0
var nitrates : int = 0
var phosphates : int = 0
var potassium : int = 0
var sunlight : int = 4

var sprite : AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = %Sprite
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func check_conditions():
	var healthy = true
	
	# what do the different plants need to survive?
	match current_type:
		type.DIRT:
			healthy = false
		type.LICHEN:
			if sunlight < 3:
				healthy = false
			if water < 1:
				healthy = false
		type.ANNUAL:
			pass
		type.PERRENIAL:
			pass
		type.FAST_TREE:
			pass
		type.SLOW_TREE:
			pass
	# if abstracting, use the line below
	#assert(false, 'please override')
	
	return healthy


# add and subtract nutrients
func adjust_conditions():
	match current_type:
		type.DIRT:
			pass
		type.LICHEN:
			pass
		type.ANNUAL:
			pass
		type.PERRENIAL:
			pass
		type.FAST_TREE:
			pass
		type.SLOW_TREE:
			pass

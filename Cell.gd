# Base class for the other cell types, likely
extends Node2D

enum type {
	DIRT,
	LICHEN,
	ANNUAL,
	PERENNIAL,
	FAST_TREE,
	SLOW_TREE
}

var current_type = 0

# nutrients
var water : int = 3
var nitrates : float = 0
var phosphates : float = 0
var potassium : float = 0
var sunlight : float = 9

var retained_n : int = 0
var retained_p : int = 0
var retained_k : int = 0

var sunlight_used : float = 0

var sprite : AnimatedSprite2D

var healthy = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = %Sprite
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func check_conditions():
	healthy = true
	
	# what do the different plants need to survive?
	match current_type:
		type.DIRT:
			healthy = false
		type.LICHEN:
			if sunlight > 6:
				healthy = false
			if sunlight < 5:
				healthy = false
			if water < 1: # pretty much just need water from the air
				healthy = false
		type.ANNUAL:
			if nitrates < 3:
				healthy = false
			if water < 3: # needs water, but not too much
				healthy = false
			if water > 5:
				healthy = false
			if sunlight > 5.5:
				healthy = false
			if sunlight < 4.25:
				healthy = false
		type.PERENNIAL:
			if nitrates < 4:
				healthy = false
			if phosphates < 2:
				healthy = false
			if water < 4:
				healthy = false
			if sunlight > 4.5: 
				healthy = false
			if sunlight < 3.5:
				healthy = false
		type.FAST_TREE:
			if nitrates < 5:
				healthy = false
			if phosphates < 4:
				healthy = false
			if potassium < 4:
				healthy = false
			if water < 10:
				healthy = false
			if sunlight > 7: 
				healthy = false
			if sunlight < 5:
				healthy = false
		type.SLOW_TREE:
			if nitrates < 5:
				healthy = false
			if phosphates < 4:
				healthy = false
			if potassium < 4:
				healthy = false
			if water < 15:
				healthy = false
			if sunlight > 7: 
				healthy = false
			if sunlight < 3:
				healthy = false
	# if abstracting, use the line below
	#assert(false, 'please override')
	
	return healthy


# add and subtract nutrients
func adjust_conditions():
	match current_type:
		type.DIRT:
			pass
		type.LICHEN: # negligible nutrient usage, fixes nitrogen
			water += 0
			nitrates += 1
		type.ANNUAL: # mines potassium, fixes phosphorus, deep roots fix water
			water += 2
			nitrates += 0
			phosphates += 1
			potassium += 1
		type.PERENNIAL: # better at fixing phosphorus, retains potassium
			water -= 1
			phosphates += 2
			potassium += 0
		type.FAST_TREE: # retains resources, uses some water
			water -= 2
			nitrates -= 1
			phosphates -= 1
			potassium -= 1
			retained_n += 1
			retained_p += 1
			retained_k += 1
			
		type.SLOW_TREE: # retains resources, uses double the resources of fast trees 
			water -= 4
			nitrates -= 2
			phosphates -= 2
			potassium -= 2
			retained_n += 3
			retained_p += 3
			retained_k += 3
			


func adjust_sunlight(amount):
	if sunlight + amount > 9:
		sunlight = 9
	else:
		sunlight += amount


# Put death logic here. For now, we'll just set the current type to dirt
func die():
	match current_type:
		type.FAST_TREE:
			nitrates += retained_n
			phosphates += retained_p
			potassium += retained_k
		type.SLOW_TREE:
			nitrates += retained_n
			phosphates += retained_p
			potassium += retained_k
			
	
	current_type = type.DIRT
	retained_n = 0
	retained_p = 0
	retained_k = 0


# try to grow something until we get something healthy, then report back
func grow_new():
	for current_type in range(5,1,-1):
		if check_conditions():
			sunlight_used = 1 + ((current_type-1)/0.25)
			return current_type
			
	current_type = type.DIRT
	return current_type
	
func grow(new_type):
	current_type = new_type
	sunlight_used = 1 + ((current_type-1)/0.25)


# Process:
#	Determine the amount to erode, round to nearest 0.01
#	Give 1/8 that amount to each neighbor's nutrient count
#	Remove that amount from the cell's nutrient count
func erode():
	var erosion_n = nitrates * water / (current_type * 10)
	round(erosion_n)
	nitrates -= erosion_n
	
	var erosion_p = phosphates * water / (current_type * 9)
	round(erosion_p)
	phosphates -= erosion_p
	
	var erosion_k = potassium * water / (current_type * 8)
	round(erosion_k)
	potassium -= erosion_k
	
	var erosion_w = water / (current_type * 7)
	round(erosion_w)
	water -= erosion_w
	
	return [
		round(erosion_n/8),
		round(erosion_p/8),
		round(erosion_k/8),
		round(erosion_w/8)
	]


func round(number):
	number = number * 10
	number.round()
	number = number/10
	return number
	
func get_sunlight_used():
	return sunlight_used

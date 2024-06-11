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

# 0 = die
# 1 = live
# 2 = populate
var operation : int = 0;

# track what this tile was at the start of the tick
var old_type = type.DIRT;

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = %Sprite
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func check_conditions():
	operation = 0
	
	# what do the different plants need to survive?
	match current_type:
		type.DIRT:
			grow_new()
		type.LICHEN:
			if sunlight == 5 && water > 0:
				operation = 1
			elif sunlight == 6 && water > 0:
				operation = 2
		type.ANNUAL:
			if nitrates < 3:
				operation = false
			if water < 3: # needs water, but not too much
				operation = false
			if water > 5:
				operation = false
			if sunlight > 5.5:
				operation = false
			if sunlight < 4.25:
				operation = false
			if nitrates >= 3 && water >= 3 && water <= 5 && sunlight >= 4.25:
				operation = 1 
			elif nitrates >= 3 && water >= 3 && water <= 5 && sunlight <= 5.5:
				operation = 2 
		type.PERENNIAL:
			if nitrates < 4:
				operation = false
			if phosphates < 2:
				operation = false
			if water < 4:
				operation = false
			if sunlight > 4.5: 
				operation = false
			if sunlight < 3.5:
				operation = false
		type.FAST_TREE:
			if nitrates < 5:
				operation = false
			if phosphates < 4:
				operation = false
			if potassium < 4:
				operation = false
			if water < 10:
				operation = false
			if sunlight > 7: 
				operation = false
			if sunlight < 5:
				operation = false
		type.SLOW_TREE:
			if nitrates < 5:
				operation = false
			if phosphates < 4:
				operation = false
			if potassium < 4:
				operation = false
			if water < 15:
				operation = false
			if sunlight > 7: 
				operation = false
			if sunlight < 3:
				operation = false
		_:
			assert(false, 'error, tile type out of bounds!')
	# if abstracting, use the line below
	#assert(false, 'please override')
	
	return operation


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
	# don't grow new stuff over non-dirt tiles
	if current_type != type.DIRT:
		return current_type
	
	for iterator in range(5,0,-1):
		current_type = iterator
		if check_conditions() == 2:
			grow(current_type)
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
	var erosion_n : float = nitrates * water / (1+current_type * 10.0)
	round(erosion_n)
	nitrates -= erosion_n
	
	var erosion_p : float = phosphates * water / (1+current_type * 9.0)
	round(erosion_p)
	phosphates -= erosion_p
	
	var erosion_k : float = potassium * water / (1+current_type * 8.0)
	round(erosion_k)
	potassium -= erosion_k
	
	var erosion_w : float = water / (1+current_type * 7.0)
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

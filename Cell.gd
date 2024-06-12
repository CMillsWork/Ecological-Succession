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
var water : float = 3
var nitrates : float = 0
var phosphates : float = 0
var potassium : float = 0
var sunlight : float = 9

var retained_n : int = 0
var retained_p : int = 0
var retained_k : int = 0

var lifespan : int = 0 # more complex plants live longer in bad conditions

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
			if sunlight > 4.5 && sunlight <= 5.5:
				operation = 1
			elif sunlight < 7 && sunlight > 5.5:
				operation = 2
		type.ANNUAL:
			if nitrates >= 2 && sunlight < 7 && sunlight > 5.5:
				operation = 2 
			elif nitrates >= 2 && sunlight >= 4 && sunlight <= 7.5:
				operation = 1 
		type.PERENNIAL:
			if nitrates >= 4 && phosphates >= 2 && water >= 4 && sunlight <= 6 && sunlight >=4:
				operation = 2
			elif nitrates >= 4 && phosphates >= 2 && water >= 4 && sunlight <= 6 && sunlight >=3:
				operation = 1 
			elif lifespan > 0:
				lifespan -= 1
				operation = 1
		type.FAST_TREE:
			if nitrates > 10 && phosphates > 10 && potassium > 10 && water > 5 && sunlight <= 5.5 && sunlight > -4:
				operation = 2
			elif nitrates > 8 && phosphates > 8 && potassium > 8 && water > 5 && sunlight <= 7 && sunlight >= 0:
				operation = 1 
			elif lifespan > 0:
				lifespan -= 1
				operation = 1
		type.SLOW_TREE:
			if nitrates > 5 && phosphates > 4 && potassium > 4 && water > 8 && sunlight <= 7 && sunlight >= -7:
				operation = 2
			elif nitrates > 5 && phosphates > 4 && potassium > 4 && water > 8 && sunlight >= -10:
				operation = 1 
			elif lifespan > 0:
				lifespan -= 1
				operation = 1
		_:
			assert(false, 'error, tile type out of bounds!')
	# if abstracting, use the line below
	#assert(false, 'please override')
	
	return operation


# add and subtract nutrients
# returns [n, p, k, water]
func produce_nutrients():
	match current_type:
		type.DIRT:
			if water < 3:
				water -= 0.5
				round(water)
				water += 1
			return [0,0,0,0]
		type.LICHEN: # negligible nutrient usage, fixes nitrogen
			return [0.5,0,0,0]
		type.ANNUAL: # mines potassium, fixes phosphorus, deep roots fix water
			return [0.1,0.25,0.25,1]
		type.PERENNIAL: # better at fixing phosphorus, retains potassium
			return [0.1,.5,0,0.1]
		type.FAST_TREE: # retains resources, uses some water
			retained_n += 1
			retained_p += 1
			retained_k += 1
			return [-1,-1,-1,-2]
			
		type.SLOW_TREE: # retains resources, uses double the resources of fast trees
			retained_n += 3
			retained_p += 3
			retained_k += 3
			return [-2,-2,-2,-4]


# param array_nutrients : [nitrates, phosphates, potassium, water]
func adjust_nutrients(array_nutrients):
	nitrates += array_nutrients[0]
	if nitrates < 0:
		nitrates = 0
	if nitrates > 20:
		nitrates = 20
		
	phosphates += array_nutrients[1]
	if phosphates < 0:
		phosphates = 0
	if phosphates > 20:
		phosphates = 20
		
	potassium += array_nutrients[2]
	if potassium < 0:
		potassium = 0
	if potassium > 20:
		potassium = 20
		
	water += array_nutrients[3]
	if water < 0:
		water = 0
	if water > 20:
		water = 20


func adjust_sunlight(amount):
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
			
			match current_type:
				type.LICHEN:
					lifespan = 1
				type.ANNUAL:
					lifespan = 1
				type.PERENNIAL:
					lifespan = 2
				type.FAST_TREE:
					lifespan = 3
				type.SLOW_TREE:
					lifespan = 5
			
			return current_type
			
	current_type = type.DIRT
	return current_type
	
func grow(new_type):
	current_type = new_type


func get_sunlight_used():	
	match current_type:
		type.LICHEN:
			return 1
		type.ANNUAL:
			return 1
		type.PERENNIAL:
			return 1.25
		type.FAST_TREE:
			return 2
		type.SLOW_TREE:
			return 3


func get_nutrients():
	return [
		nitrates,
		phosphates,
		potassium,
		water,
		sunlight
	]

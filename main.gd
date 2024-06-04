extends Node2D


var cells : Array = []
const gridSize : int = 20

@onready var clock : Timer = $Clock
@onready var tileMap : TileMap = %TileMap

@onready var CellFactory = preload("res://cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in gridSize:
		cells.append([])
		for y in gridSize:
			var newCell = CellFactory.instantiate()
			add_child(newCell)
			cells[x].append(newCell)
			newCell.position = Vector2(x*64,y*64)
			newCell.sprite.animation = 'dirt'
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var tile_data = tileMap.local_to_map(mouse_pos)
	
	if tile_data is TileData:
		#render hover sprite
		pass
	
	pass


func _on_clock_timeout():
	# for each cell in grid
	# check survival conditions
	# process nutrients
	# add water, erosion
	pass # Replace with function body.



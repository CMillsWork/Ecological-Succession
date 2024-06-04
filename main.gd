extends Node2D

# Cell[]
var cells : Array = []
const gridSize : int = 20
var dic = {}

# 0 = die
# 1 = stay
# 2 = populate
var operations = []

@onready var clock : Timer = $Clock
@onready var tileMap : TileMap = %TileMap

@onready var CellFactory = preload("res://cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in gridSize:
		cells.append([])
		operations.append([])
		for y in gridSize:
			dic[str(Vector2(x,y))] = {
				"Type" : "Grass"
			}
			var newCell = CellFactory.instantiate()
			add_child(newCell)
			cells[x].append(newCell)
			newCell.position = Vector2(x*64,y*64)
			newCell.sprite.animation = 'dirt'
			
			operations[x].append(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var tile_data = tileMap.local_to_map(mouse_pos)
	
	# check cells' conditions
	for x in gridSize:
		for y in gridSize:
			tileMap.erase_cell(1,Vector2(x,y))
	
	if dic.has(str(tile_data)):
		tileMap.set_cell(1, tile_data, 1, Vector2i(0,0), 0)
		#print_debug('x=',tile.x, ' y=', tile.y, ' data=', cells[tile.x][tile.y])


func _on_clock_timeout():
	for x in gridSize:
		for y in gridSize:
			check_neighbors(x,y)
	
	for x in gridSize:
		for y in gridSize:
			if operations[x][y] == 0:
				cells[x][y] = 0
				tileMap.erase_cell(2, Vector2(x,y))
			elif operations[x][y] == 1:
				pass
			elif operations[x][y] == 2:
				cells[x][y] = 1
				tileMap.set_cell(2, Vector2(x,y), 0, Vector2i(0,1), 0)
				
			operations[x][y] = 0 


func _unhandled_input(event):
	if Input.is_action_pressed('mouse_left'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		tileMap.set_cell(2, mouse_position, 0, Vector2i(0,1), 0)
		cells[mouse_position.x][mouse_position.y] = 1
	if Input.is_action_pressed('mouse_right'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		tileMap.erase_cell(2, mouse_position)
		cells[mouse_position.x][mouse_position.y] = 0


func check_neighbors(x,y):
	var total_neighbors = 0
	# left
	if x > 0 && cells[x-1][y] == 1:
		#print_debug('neighbor found left: ',x-1,',', y,': ', cells[x-1][y])
		total_neighbors += 1
	# right
	if x < gridSize-1 && cells[x+1][y] == 1:
		#print_debug('neighbor found right')
		total_neighbors += 1
	# up
	if y > 0 && cells[x][y-1] == 1:
		#print_debug('neighbor found up')
		total_neighbors += 1
	# down
	if y < gridSize-1 && cells[x][y+1] == 1:
		#print_debug('neighbor found down')
		total_neighbors += 1
	# left and up
	if x > 0 && y > 0 && cells[x-1][y-1] == 1:
		#print_debug('neighbor found left and up')
		total_neighbors += 1
	# left and down
	if x > 0 && y < gridSize-1 && cells[x-1][y+1] == 1:
		#print_debug('neighbor found left and down')
		total_neighbors += 1
	# right and up
	if x < gridSize-1 && y > 0 && cells[x+1][y-1] == 1:
		#print_debug('neighbor found right and up')
		total_neighbors += 1
	# right and down
	if x < gridSize-1 && y < gridSize-1 && cells[x+1][y+1] == 1:
		#print_debug('neighbor found right and down for ', x,',',y)
		total_neighbors += 1
	
	if total_neighbors < 2: # incorrect population
		operations[x][y] = 0
	elif total_neighbors == 2: # no change
		operations[x][y] = 1
	elif total_neighbors == 3: # happy middle
		operations[x][y] = 2
	elif total_neighbors > 3: # incorrect population
		operations[x][y] = 0


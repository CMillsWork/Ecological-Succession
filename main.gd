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
				"Type" : "Dirt"
			}
			var newCell = CellFactory.instantiate()
			add_child(newCell)
			cells[x].append(newCell)
			#newCell.position = Vector2(x*64,y*64)
			#newCell.sprite.animation = 'dirt'
			tileMap.set_cell(0, Vector2(x,y), 0, Vector2i(0,0), 0)
			
			operations[x].append(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var tile_data = tileMap.local_to_map(mouse_pos)
	
	# check cells' conditions
	for x in gridSize:
		for y in gridSize:
			tileMap.erase_cell(2,Vector2(x,y))
	
	if dic.has(str(tile_data)):
		tileMap.set_cell(2, tile_data, 1, Vector2i(0,0), 0)
		print_debug('x=',tile_data.x, ' y=', tile_data.y, ' data=', cells[tile_data.x][tile_data.y].sunlight)


func _on_clock_timeout():
	for x in gridSize:
		for y in gridSize:
			#print_debug('checking condition on cell ', x, ',', y)
			cells[x][y].check_conditions()
	
	for x in gridSize:
		for y in gridSize:
			if cells[x][y].healthy == false: # if unhealthy, die
				cells[x][y].die()
				adjust_shade(x,y,1)
				tileMap.erase_cell(1, Vector2(x,y))
			elif cells[x][y].healthy == true: # if healthy, produce
				cells[x][y].adjust_conditions()
			elif cells[x][y].current_type == 0: # if dirt, try to grow something
				var new_cell = cells[x][y].grow_new()
				if new_cell != 0:
					adjust_shade(x,y,-1)
					tileMap.setCell(1, Vector2(x,y), 0, Vector2i(0,new_cell), 0)
					
			#clear operations after processing
			operations[x][y] = 0
			
	for x in gridSize:
		for y in gridSize:
			pass # handle erosion


# operand: 1 to add sunlight, -1 to remove sunlight
func adjust_shade(x : int, y : int, operand : int):
	var shade_radius : float = cells[x][y].current_type/2.0
	shade_radius = round(shade_radius)
	for shade_x in range (x-shade_radius, x+shade_radius+1, 1):
		for shade_y in range (y-shade_radius, y+shade_radius+1, 1):
			cells[shade_x][shade_y].adjust_sunlight(operand * cells[x][y].get_sunlight_used())

func _unhandled_input(_event):
	if Input.is_action_pressed('mouse_left'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		tileMap.set_cell(1, mouse_position, 0, Vector2i(0,1), 0)
		cells[mouse_position.x][mouse_position.y].grow(1)
		adjust_shade(mouse_position.x,mouse_position.y,-1)
		#print_debug('cell ',mouse_position.x,',',mouse_position.y,' set to ',cells[mouse_position.x][mouse_position.y] )
		
		
	if Input.is_action_pressed('mouse_right'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		tileMap.erase_cell(1, mouse_position)
		cells[mouse_position.x][mouse_position.y].current_type = 0
		adjust_shade(mouse_position.x,mouse_position.y,1)


func _on_step_button_pressed():
	clock.start(0.01)


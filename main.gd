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
		#print_debug('x=',tile_data.x, ' y=', tile_data.y, ' data=', cells[tile_data.x][tile_data.y].get_nutrients())


func _on_clock_timeout():
	for x in gridSize:
		for y in gridSize:
			var current_cell = cells[x][y]
			# start tick by setting the old type to the current type.
			current_cell.old_type = current_cell.current_type
			#print_debug('checking condition on cell ', x, ',', y)
			current_cell.check_conditions()
	
	for x in gridSize:
		for y in gridSize:
			var current_cell = cells[x][y]
				
			if current_cell.old_type == 0 && current_cell.operation == 2: # if dirt and populating, adjust sunlight
				adjust_shade(x,y,-1)
				tileMap.set_cell(1, Vector2(x,y), 0, Vector2i(0,current_cell.current_type), 0)
			elif current_cell.operation == 0 && current_cell.old_type != 0: # if unhealthy, die; dirt cannot die
				adjust_shade(x,y,1)
				current_cell.die()
				tileMap.erase_cell(1, Vector2(x,y))
				if empty_dirt_sunlight_test(x,y):
					print_debug('found a problem with sunlight at ', x, ',', y)
			
			if current_cell.operation != 0: # if healthy, produce
				var production = current_cell.produce_nutrients()
				var root_radius : float = cells[x][y].current_type/2.0
				root_radius = round(root_radius)
				for roots_x in range (x-root_radius, x+root_radius+1, 1):
					for roots_y in range (y-root_radius, y+root_radius+1, 1):
						if roots_x >= 0 && roots_x < gridSize && roots_y >= 0 && roots_y < gridSize:
							cells[roots_x][roots_y].adjust_nutrients(production)
				
			
			#clear operations after processing
			operations[x][y] = 0
	
	# sanity check, remove later
	for x in gridSize:
		for y in gridSize:
			if empty_dirt_sunlight_test(x,y):
				print_debug('found a problem with sunlight at ', x, ',', y)


# operand: 1 to add sunlight, -1 to remove sunlight
func adjust_shade(x : int, y : int, operand : int):
	var shade_radius : float = cells[x][y].current_type/2.0
	shade_radius = round(shade_radius)
	var sun_used = cells[x][y].get_sunlight_used()
	for shade_x in range (x-shade_radius, x+shade_radius+1, 1):
		for shade_y in range (y-shade_radius, y+shade_radius+1, 1):
			if shade_x >= 0 && shade_x < gridSize && shade_y >= 0 && shade_y < gridSize:
				cells[shade_x][shade_y].adjust_sunlight(operand * sun_used)

func _unhandled_input(_event):
	if Input.is_action_pressed('mouse_left'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		if mouse_position.x >= 0 && mouse_position.x < gridSize && mouse_position.y >= 0 && mouse_position.y < gridSize && cells[mouse_position.x][mouse_position.y].current_type == 0:
			tileMap.set_cell(1, mouse_position, 0, Vector2i(0,1), 0)
			cells[mouse_position.x][mouse_position.y].grow(1)
			adjust_shade(mouse_position.x,mouse_position.y,-1)
			#print_debug('cell ',mouse_position.x,',',mouse_position.y,' set to ',cells[mouse_position.x][mouse_position.y] )
		
		
	if Input.is_action_pressed('mouse_right'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		if mouse_position.x >= 0 && mouse_position.x < gridSize && mouse_position.y >= 0 && mouse_position.y < gridSize && cells[mouse_position.x][mouse_position.y].current_type != 0:
			tileMap.erase_cell(1, mouse_position)
			adjust_shade(mouse_position.x,mouse_position.y,1)
			cells[mouse_position.x][mouse_position.y].die()
			
	if Input.is_action_pressed('mouse_middle'):
		var mouse_position = tileMap.local_to_map(get_global_mouse_position())
		if mouse_position.x >= 0 && mouse_position.x < gridSize && mouse_position.y >= 0 && mouse_position.y < gridSize && cells[mouse_position.x][mouse_position.y].current_type == 0:
			print_debug('x=',mouse_position.x, ' y=', mouse_position.y, ' data=', cells[mouse_position.x][mouse_position.y].get_nutrients())

func _on_step_button_pressed():
	clock.start(0.01)

func empty_dirt_sunlight_test(x,y):
	var problem = true
	
	if cells[x][y].sunlight < 9:
		for check_x in range (x-1, x+2, 1):
			for check_y in range (y-1, y+2, 1):
				if check_x >= 0 && check_x < gridSize && check_y >= 0 && check_y < gridSize && cells[check_x][check_y].current_type != 0:
					problem = false
	
	return problem

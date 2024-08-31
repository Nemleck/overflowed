extends Node2D
class_name Polygon

const INSCRIBED_RADIUS: int = 42
const CIRCUMSCRIBED_RADIUS: int = INSCRIBED_RADIUS * 1.21

func scenes():
	return {
	"triangle": preload("res://textures/polygons/piped_polygon/piped_triangle_texture_rect.tscn"),
	"square": preload("res://textures/polygons/piped_polygon/piped_square_texture_rect.tscn"),
	"hexagon": preload("res://textures/polygons/piped_polygon/piped_hexagon_texture_rect.tscn")
}

var neighbors = {}
var order = 4;

var x
var y

func add_neighbor(node: Polygon, n: int):
	self.neighbors[n] = node
	node.neighbors[(n+3)%node.order] = self
	
	# TODO : get_n_from_angle(node) -> take opposite

func _set_order(order: int):
	self.order = order
	
	var name = "undefined"
	
	if order == 3:
		name = "triangle"
	elif order == 4:
		name = "square"
	elif order == 6:
		name = "hexagon"
	
	var textureRect = scenes()[name].instantiate()
	self.add_child(textureRect)
	self.move_child(textureRect, 0)

func opposite_side(n):
	return (n+3) % 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.rotatable():
		self._process_rotation(delta)
	
	if self.flowable():
		self._process_flowing(delta)
	
	if Input.is_action_just_pressed("ctrl") and draggable:
		_init_pipes()
		self.pipes.redraw()

# ---------------------------- FLOWING  ----------------------------

const FLOW_SPEED = 80
func flow(n):
	if self.flowable():
		self.pipes.flow(n)

var pipe_configs = [
	[[1, 3], [3, 5], [5, 1]], 
	[[0, 5]], 
	[[0, 2]], 
	[[0,1], [2,3], [4,5]],
	[[0,2], [3,5]],
	[[0,3], [1,4]],
	[[0,3]],
	[[0,3], [1,2], [4,5]],
	[[0,2], [0,3], [0,4]],
	[[0,1], [0,5], [3,2], [3,4]]
]

# Dynamic Variables
var pipes = null
func _ready() -> void:
	if self.flowable():
		self.pipes = self.get_node("pipes")
		self._init_pipes()

func _init_pipes():
	var choice = randi_range(0, len(pipe_configs)-1)
	
	self.pipes.pipes = []
	for pipe_entries in pipe_configs[choice]:
		self.pipes.pipes.append({"entries": pipe_entries.duplicate(), "flow": {"flowing": false, "percentage": 0, "from": 0, "to": 1}})

# Properties
func flowable():
	return false

func _process_flowing(delta: float) -> void:
	for pipe in pipes.pipes:
		if pipe["flow"]["flowing"]:
			var diff: float = 0
			
			var space_multiplicator = 1
			if Input.is_action_pressed("space"):
				space_multiplicator = 3
			
			if 100-pipe["flow"]["percentage"] > delta * FLOW_SPEED * space_multiplicator:
				diff = delta * FLOW_SPEED * space_multiplicator # Add delta * Speed
			else:
				diff = pipe["flow"]["percentage"] # Add only what remains
			
			pipe["flow"]["percentage"] += diff # Add here
			
			if pipe["flow"]["percentage"] >= 100: # End flowing
				pipe["flow"]["flowing"] = false
				
				if pipe["flow"]["to"] in self.neighbors.keys():
					self.neighbors[pipe["flow"]["to"]].flow(opposite_side(pipe["flow"]["to"]))
			
			pipes.redraw()

# ---------------------------- ROTATION ----------------------------

# Dynamic ariables
var draggable: bool = false
var to_rotate = 0
var rotation_queue = 0

# Consts
const ROTATE_SPEED = 4

# Properties
func rotatable():
	return false
func gearable():
	return false

# Mouse interaction
func _on_area_2d_mouse_entered():
	self.draggable = true
	self.scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	self.draggable = false
	self.scale = Vector2(1, 1)

# Rotation behavior
func schedule_rotate(angle, i=0):
	"""
	Launchs rotation process
	"""
	
	self.to_rotate = angle
	
	# i protects from moving too many polygons at a time
	if self.gearable() and i < 4:
		for key in self.neighbors.keys():
			if self.neighbors[key].to_rotate == 0 and self.neighbors[key].gearable():
				self.neighbors[key].schedule_rotate(-angle, i+1)

func _process_rotation(delta):
	"""
	Processes rotation every tick
	"""
	
	# Schedule several rotations at a time
	if self.draggable:
		if self.rotation_queue < 5 and Input.is_action_just_pressed("click"):
			self.rotation_queue += 1
		elif self.rotation_queue > -5 and Input.is_action_just_pressed("right_click"):
			self.rotation_queue -= 1
	
	# Rotate the polygon
	if self.to_rotate != 0:
		var angle: float = 0
		
		if abs(self.to_rotate) > delta * ROTATE_SPEED:
			angle = delta * ROTATE_SPEED * sign(self.to_rotate)
		else:
			angle = self.to_rotate
		
		self.to_rotate -= angle
		self.rotate(angle)
		
		if self.to_rotate == 0:
			for pipe in self.pipes.pipes:
				for i in range(len(pipe["entries"])):
					# Trick to avoid negative result with gd script's modulo
					pipe["entries"][i] = ( (pipe["entries"][i] + int(sign(angle))) % self.order + self.order ) % self.order
			
			print_debug(self.pipes.pipes[0]["entries"])
			
			self.rotation = 0
			self.pipes.redraw()
	
	# Start rotation when queue isn't empty
	if self.to_rotate == 0:
		if self.rotation_queue > 0:
			self.rotation_queue -= 1
			self.schedule_rotate(2*PI/self.order)
		elif self.rotation_queue < 0:
			self.rotation_queue += 1
			self.schedule_rotate(-2*PI/self.order)

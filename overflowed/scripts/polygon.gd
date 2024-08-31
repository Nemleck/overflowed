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

const FLOW_SPEED = 80
func flow(n):
	if self.flowable():
		self.pipes.flow(n)

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

# ---------------------------- FLOWING  ----------------------------

# Dynamic Variables
var pipes = null
func _ready() -> void:
	if self.flowable():
		self.pipes = self.get_node("pipes")

# Properties
func flowable():
	return false

func _process_flowing(delta: float) -> void:
	for pipe in pipes.pipes:
		if pipe["flow"]["flowing"]:
			var diff: float = 0
			
			if 100-pipe["flow"]["percentage"] > delta * FLOW_SPEED:
				diff = delta * FLOW_SPEED # Add delta * Speed
			else:
				diff = pipe["flow"]["percentage"] # Add only what remains
			
			pipe["flow"]["percentage"] += diff # Add here
			
			if pipe["flow"]["percentage"] >= 100: # End flowing
				pipe["flow"]["flowing"] = false
				
				if pipe["flow"]["to"] in self.neighbors.keys():
					self.neighbors[pipe["flow"]["to"]].flow(opposite_side(pipe["flow"]["to"]))
			
			pipes.redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.rotatable():
		self._process_rotation(delta)
	
	if self.flowable():
		self._process_flowing(delta)

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
	draggable = true
	self.scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	draggable = false
	self.scale = Vector2(1, 1)

# Rotation behavior
func schedule_rotate(angle, i=0):
	"""
	Launchs rotation process
	"""
	
	self.to_rotate = angle
	
	# i protects from moving too many polygons at a time
	if i < 4:
		for key in self.neighbors.keys():
			if self.neighbors[key].gearable():
				self.neighbors[key].schedule_rotate(-angle, i+1)

func _process_rotation(delta):
	"""
	Processes rotation every tick
	"""
	
	# Schedule several rotations at a time
	if draggable and Input.is_action_just_pressed("click") and self.rotation_queue < 5:
		self.rotation_queue += 1
	
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
					pipe["entries"][i] = (pipe["entries"][i] + int(sign(angle))) % self.order
			
			self.rotation = 0
			self.pipes.redraw()
	
	if self.to_rotate == 0 and rotation_queue > 0:
		self.rotation_queue -= 1
		
		self.schedule_rotate(2*PI/self.order)

extends Polygon
class_name Piped_Polygon

var turning_state = 0 # 0 to 1 while turning
var draggable: bool = false

var to_rotate = 0
var queue = 0

const ROTATE_SPEED = 2
const FLOW_SPEED = 40

@onready
var pipes = self.get_node("pipes")

func flow(n):
	self.pipes.flow(n)

func schedule_rotate(angle):
	self.to_rotate = angle

func rotatable():
	return true

func _on_area_2d_mouse_entered():
	draggable = true
	self.scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	draggable = false
	self.scale = Vector2(1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._process_rotation(delta)
	
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
	
	if draggable and Input.is_action_just_pressed("click") and queue < 5:
		self.queue += 1

func _process_rotation(delta):
	if self.to_rotate != 0:
		var angle: float = 0
		
		if abs(self.to_rotate) > delta * ROTATE_SPEED:
			angle = delta * ROTATE_SPEED * sign(self.to_rotate)
		else:
			angle = self.to_rotate
		
		self.to_rotate -= angle
		self.rotate(angle)
	
	if self.to_rotate == 0 and queue > 0:
		self.queue -= 1
		
		self.schedule_rotate(2*PI/self.order)
		#for key in self.neighbors.keys():
			#if self.neighbors[key].rotatable():
				#self.neighbors[key].to_rotate = -2*PI/self.order

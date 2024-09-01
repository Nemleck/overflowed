extends Polygon
class_name Source_Polygon

var colors = [Color.CYAN, Color.AQUAMARINE, Color.CRIMSON, Color.BLUE_VIOLET, Color.BURLYWOOD, Color.CHOCOLATE, Color.DARK_GREEN]
var color = colors[randi_range(0, len(colors)-1)]

func scenes():
	return {
		"triangle": null,#preload("res://textures/polygons/piped_polygon/piped_triangle_texture_rect.tscn"),
		"square": null,# preload("res://textures/polygons/piped_polygon/piped_square_texture_rect.tscn"),
		"hexagon": preload("res://textures/polygons/source_polygon/source_hexagon_texture_rect.tscn")
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.draggable and Input.is_action_pressed("click"):
		for key in neighbors.keys():
			if neighbors[key] != null:
				neighbors[key].flow(Utils.opposite_side(key), self.color)


func _on_mouse_entered() -> void:
	self._on_area_2d_mouse_entered()

func _on_mouse_exited() -> void:
	self._on_area_2d_mouse_exited()

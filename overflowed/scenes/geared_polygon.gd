extends Piped_Polygon
class_name Geared_Polygon

func scenes():
	return {
	"triangle": null,
	"square": null,
	"hexagon": preload("res://textures/polygons/geared_polygon/geared_hexagon_texture_rect.tscn")
}

func gearable():
	return true

func schedule_rotate(angle, i=0):
	self.to_rotate = angle
	
	if i < 4:
		for key in self.neighbors.keys():
			if self.neighbors[key].gearable():
				self.neighbors[key].schedule_rotate(-angle, i+1)

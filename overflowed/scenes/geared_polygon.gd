extends Polygon
class_name Geared_Polygon

func scenes():
	return {
		"triangle": null,
		"square": null,
		"hexagon": preload("res://textures/polygons/geared_polygon/geared_hexagon_texture_rect.tscn")
	}

func flowable():
	return true

func gearable():
	return true

extends Node2D

var scenes = {
	"piped": preload("res://scenes/piped_polygon.tscn"),
	"source": preload("res://scenes/source_polygon.tscn"),
	"geared": preload("res://scenes/geared_polygon.tscn")
}

var pipe = preload("res://scenes/pipe.tscn")

var pipe_configs = [
	[[1, 3], [3, 5], [5, 1]], 
	[[0, 5]], 
	[[0, 2]], 
	[[0,1], [2,3], [4,5]],
	[[0,2], [3,5]],
	[[0,3], [1,4]],
	[[0,3]],
	[[0,3], [1,2], [4,5]]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map = []
	for y in range(7):
		map.append([])
		for x in range(15):
			var type = ["piped", "piped", "geared"][randi_range(0, 2)]
			if x == 0 and y == 0:
				type = "source"
			
			#elif randi() % 4 == 0:
				#map[-1].append(null)
				#continue
			
			var scene = scenes[type]
			
			var order = 6
			var polygon = scene.instantiate()
			
			if type in ["piped", "geared"]:
				var pipe = polygon.get_node("pipes")
			
			polygon.x = x
			polygon.y = y
			
			if order == 3:
				polygon.position.x = (x+0.5) * polygon.INSCRIBED_RADIUS
				polygon.position.y = (y+0.5) * 2 * polygon.INSCRIBED_RADIUS
				
				if y % 2 == x % 2:
					polygon.rotate(PI)
				
			elif order == 4:
				# Position
				polygon.position.x = (x+0.5) * 2 * polygon.INSCRIBED_RADIUS
				polygon.position.y = (y+0.5) * 2 * polygon.INSCRIBED_RADIUS
				
				# Neighbors
				if y > 0 and map[y-1][x] != null:
					polygon.add_neighbor(map[y-1][x], 2)
				if x > 0 and map[y][x-1] != null:
					polygon.add_neighbor(map[y][x-1], 3)
				
			elif order == 6:
				# Position
				polygon.position.x = (x * 1.5 + 1) * polygon.CIRCUMSCRIBED_RADIUS
				polygon.position.y = (y + 0.5 * (x % 2 + 1)) * 2 * polygon.INSCRIBED_RADIUS
				
				# Neighbors
				if x > 0 and map[y][x-1] != null:
					if x % 2 == 1:
						polygon.add_neighbor(map[y][x-1], 3)
					else:
						polygon.add_neighbor(map[y][x-1], 2)
				
				if y > 0 and map[y-1][x] != null:
					polygon.add_neighbor(map[y-1][x], 4)
				
				if x > 0 and y > 0 and map[y-1][x-1] != null:
					if x % 2 == 0:
						polygon.add_neighbor(map[y-1][x-1], 3)
				
				if x < 14 and y > 0 and map[y-1][x+1] != null:
					if x % 2 == 0:
						polygon.add_neighbor(map[y-1][x+1], 5)
			
			if type in ["piped", "geared"]:
				var choice = randi_range(0, len(pipe_configs)-1)
				
				for pipe_entries in pipe_configs[choice]:
					polygon.get_node("pipes").pipes.append({"entries": pipe_entries.duplicate(), "flow": {"flowing": false, "percentage": 0, "from": 0, "to": 1}})
			
			polygon._set_order(order)
			
			self.add_child(polygon)
			
			map[-1].append(polygon)
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

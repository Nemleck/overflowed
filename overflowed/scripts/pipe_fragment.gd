extends Node2D
class_name Pipe_Fragment

var content = null
var direction = 1 # direction is 1 or -1
var filled_time = 0

var scheduled = {}

func _init(color, direction):
	self.content = {"color": color}
	self.direction = direction

func fill(color, direction):
	self.content = {"color": color}
	self.direction = direction

## Schedules and do not apply the flowing changes to avoid faster propagation to the right (due to the for)
#func _schedule_flowing(previous_list, next_list) -> void:
	## previous_list and next_list can be empty
	#
	#if self.content == null:
		#if len(previous_list) > 0:
			#var previous = previous_list[randi_range(0, len(previous_list)-1)]
			#
			#if previous != null and previous.direction == 1:
				#scheduled = {"color": previous.content["color"], "direction": previous.direction}
				#previous = null
		#
		#if len(next_list) > 0:
			#var next = next_list[randi_range(0, len(next_list)-1)]
			#
			#if next != null and next.direction == -1:
				#scheduled = {"color": next.content["color"], "direction": next.direction}
				#next = null

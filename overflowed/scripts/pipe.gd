extends Node2D
class_name Pipe

const FRAGMENTS_AMOUNT = 10
const FLOW_SPEED = 8 # Fragments per second

var tick = 0
var fragments = []
var entries = []

func _init(entries):
	self.entries = entries
	
	for i in range(FRAGMENTS_AMOUNT):
		fragments.append(null)

func fragment_from_entry(n):
	if n == entries[0]:
		return self.fragments[0]
	else:
		return self.fragments[-1]

# Starts flowing
func flow(entry, color):
	if entry == self.entries[0]:
		self.fragments[0] = Pipe_Fragment.new(color, 1)
	else:
		self.fragments[-1] = Pipe_Fragment.new(color, -1)

# Tick flow
func _process_flowing(delta: float, pipe_neighbors):
	self.tick += delta
	
	if self.tick > 1/FLOW_SPEED:
		var turns = int(self.tick * FLOW_SPEED)
		self.tick -= turns/FLOW_SPEED
		
		# TODO : Avoid to do this every frame
		var neighbor_fragments = []
		
		# Add fragments to neighbor_fragments for both entries
		for i in [0, 1]:
			var pipe_fragments = []
			var neighbor = pipe_neighbors[i]
			
			if neighbor != null and neighbor.pipes != null:
				var neighbor_pipes = neighbor.pipes.get_pipes_from_entry(Utils.opposite_side(self.entries[i]))
				
				for n_pipe in neighbor_pipes:
					pipe_fragments.append(n_pipe.fragment_from_entry(Utils.opposite_side(self.entries[i])))
					
			neighbor_fragments.append(pipe_fragments)
		
		#for j in range(turns):
		var new_fragments = []
		for i in range(len(self.fragments)):
			new_fragments.append(null)
		
		for i in range(len(self.fragments)):
			var fragment = self.fragments[i]
			if fragment == null:
				if len(new_fragments) < i+1:
					new_fragments.append(null)
			else:
				var previous_fragments = []
				if i > 0:
					previous_fragments = [new_fragments[i-1]]
				else:
					previous_fragments = neighbor_fragments[0]
				
				var next_fragments = []
				if i < len(self.fragments)-1:
					next_fragments = [self.fragments[i+1]]
				else:
					next_fragments = neighbor_fragments[1]
				
				# Pick random fragments
				
				var previous
				if len(previous_fragments) > 0:
					previous = previous_fragments[randi_range(0, len(previous_fragments)-1)]
				else:
					previous = null
				
				var next
				if len(next_fragments) > 0:
					next = next_fragments[randi_range(0, len(next_fragments)-1)]
				else:
					next = null
				
				# Move fragments
				
				if previous == null and fragment.direction == -1:
					new_fragments[i] = null
					
					if i == 0:
						# Give to neighbor
						if pipe_neighbors[0] != null:
							pipe_neighbors[0].flow(Utils.opposite_side(self.entries[0]), fragment.content["color"])
						else:
							new_fragments[i] = fragment
					else:
						new_fragments[i-1] = fragment
				elif next == null and fragment.direction == 1:
					new_fragments[i] = null
					
					if i+1 == len(self.fragments):
						# Give to neighbor
						if pipe_neighbors[1] != null:
							pipe_neighbors[1].flow(Utils.opposite_side(self.entries[1]), fragment.content["color"])
						else:
							new_fragments[i] = fragment
					else:
						new_fragments[i+1] = fragment
				else:
					new_fragments[i] = fragment
		
		self.fragments = new_fragments
			
			#if :
				#var temp = previous_fragments
				#previous_fragments = next_fragments
				#next_fragments = temp
			
			#fragment._schedule_flowing(previous_fragments, next_fragments)

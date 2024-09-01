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
		fragments.append(Pipe_Fragment.new())

func fragment_from_entry(n):
	if n == entries[0]:
		return self.fragments[0]
	else:
		return self.fragments[-1]

# Starts flowing
func flow(entry, color):
	if entry == self.entries[0]:
		self.fragments[0].fill(color, 1)
	else:
		self.fragments[-1].fill(color, -1)

# Tick flow
func _schedule_flowing(delta: float, neighbor_fragments):
	self.tick += delta
	
	if self.tick > 1/FLOW_SPEED:
		var turns = int(self.tick * FLOW_SPEED)
		self.tick -= turns/FLOW_SPEED
		
		#for j in range(turns):
		for i in range(len(self.fragments)):
			var previous_fragments = []
			if i > 0:
				previous_fragments = [self.fragments[i-1]]
			else:
				previous_fragments = neighbor_fragments[0]
			
			var fragment = self.fragments[i]
			
			var next_fragments = []
			if i < len(self.fragments)-1:
				next_fragments = [self.fragments[i+1]]
			else:
				next_fragments = neighbor_fragments[1]
			
			#if fragment.direction == -1:
				#var temp = previous_fragments
				#previous_fragments = next_fragments
				#next_fragments = temp
			
			fragment._schedule_flowing(previous_fragments, next_fragments)

func _process_flowing():
	for fragment in self.fragments:
		fragment._process_flowing()

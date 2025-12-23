extends Node2D

func _ready():
	var starmap = Starmap.new()
	
	var display = StarmapDisplay.new()
	display.starmap = starmap
	display.scale_factor = 5.0  # Adjust this to fit the map on screen
	add_child(display)
	
	print("Generated ", starmap.stars.size(), " stars with ", starmap.links.size(), " links")

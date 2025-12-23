extends RefCounted

const Faction = preload("res://src/Faction.gd")

var _factions = {}

func register(faction):
	if not _factions.has(faction.name):
		faction.id = _factions.size()
		_factions[faction.name] = faction
	else:
		push_error("Faction already registered!")

func get_faction(name):
	return _factions.get(name, null)

func get_faction_by_id(id):
	for faction in _factions.values():
		if faction.id == id:
			return faction
	return null

func _init():
	# Register default factions
	register(Faction.new({"name": "Civilians", "color": "grey"}))
	register(Faction.new({"name": "Pirates", "color": "red"}))
	register(Faction.new({"name": "Police", "color": "blue"}))
	register(Faction.new({"name": "Player", "color": "white"}))
	register(Faction.new({"name": "AnnoyingFan", "color": "yellow"}))
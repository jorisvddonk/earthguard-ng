class_name Phonetics

var _unique_generate_cache = []

var chargroups = {}

func _init():
	chargroups = {
		"ordinary_vowels": {"key": "o", "values": ["a", "e", "i", "o", "u"]},
		"vowels": {"key": "v", "values": ["a", "e", "i", "o", "u", "y"]},
		"consonants": {"key": "c", "values": ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "x", "z", "w"]},
		"stops": {"key": "s", "values": ["p", "t", "k", "b", "d", "c", "ck"]},
		"affricates": {"key": "a", "values": ["j", "g", "ch", "dz", "ds", "ts", "tch", "tu", "dg"]},
		"fricatives": {"key": "f", "values": ["f", "gh", "v", "f", "th", "s", "sh", "ch", "g", "h"]},
		"nasals": {"key": "n", "values": ["m", "n", "kn", "gn", "ng"]},
		"liquids": {"key": "l", "values": ["l", "le", "r", "er", "ur"]},
		"glides": {"key": "g", "values": ["w", "wh"]}
	}
	
	# Calculate remainingconsonants
	var all_consonants = chargroups["consonants"]["values"].duplicate()
	var to_remove = []
	to_remove.append_array(chargroups["affricates"]["values"])
	to_remove.append_array(chargroups["fricatives"]["values"])
	to_remove.append_array(chargroups["stops"]["values"])
	to_remove.append_array(chargroups["nasals"]["values"])
	to_remove.append_array(chargroups["liquids"]["values"])
	to_remove.append_array(chargroups["glides"]["values"])
	
	var remaining = []
	for c in all_consonants:
		if not c in to_remove:
			remaining.append(c)
	
	chargroups["remainingconsonants"] = {"key": "r", "values": remaining}

func generate(pattern):
	var retString = ""
	var next_is_literal = false
	for po in pattern:
		var pl = po.to_lower()
		
		var genChar = null
		if next_is_literal:
			genChar = po
			next_is_literal = false
		elif pl == "p":
			if retString.length() > 0:
				genChar = retString.substr(retString.length() - 1, 1)
		elif po == "u":
			genChar = str(randi() % 10)
		elif po == "U":
			genChar = str((randi() % 9) + 1)
		elif po == "\\":
			next_is_literal = true
			continue
		else:
			for pkey in chargroups:
				if pl == chargroups[pkey]["key"]:
					var values = chargroups[pkey]["values"]
					genChar = values[randi() % values.size()]
		
		if genChar != null:
			if pl != po:
				# Uppercase
				genChar = genChar.to_upper()
			retString += genChar
	
	return retString

func UGenerate(pattern):
	var generated = null
	var icount = 0
	while generated == null:
		if icount >= 1024:
			push_error("Either you're really unlucky, or this pattern can't generate any more names!")
			return ""
		generated = generate(pattern)
		if generated in _unique_generate_cache:
			generated = null
		else:
			_unique_generate_cache.append(generated)
		icount += 1
	return generated

func clearNameCache():
	_unique_generate_cache = []

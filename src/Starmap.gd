class_name Starmap

var phonetics
var stars = []
var links = []

func _init():
	phonetics = Phonetics.new()
	generateStarmap()
	if stars.size() > 0:
		stars[0].faction = 0

func generateStarmap():
	stars = []
	links = []
	
	var SIMPROPS = {
		"NSTARS": 100,
		"MIN_DISTANCE_BETWEEN_STARS": 40,
		"MAX_NUMBER_OF_STAR_REJECTS": 10000,
		"MIN_LINKS_BETWEEN_STARS": 3
	}
	
	var reject_count = 0
	while stars.size() < SIMPROPS["NSTARS"] and reject_count < SIMPROPS["MAX_NUMBER_OF_STAR_REJECTS"]:
		var newStar = Star.new({"name": phonetics.UGenerate("Cosof")})
		var dists = getClosestStars(newStar)
		if dists.size() > 0 and dists[0]["dist"] < SIMPROPS["MIN_DISTANCE_BETWEEN_STARS"]:
			reject_count += 1
			continue
		stars.append(newStar)
	
	# Generate links
	for i in range(stars.size()):
		var cstar = stars[i]
		var dists = getClosestStars(cstar)
		for ii in range(min(SIMPROPS["MIN_LINKS_BETWEEN_STARS"], dists.size())):
			links.append({"star1": cstar, "star2": dists[ii]["star"]})
	
	# Remove duplicates
	var unique_links = []
	var seen = {}
	for link in links:
		var key
		if link["star1"].objid <= link["star2"].objid:
			key = str(link["star1"].objid) + "|" + str(link["star2"].objid)
		else:
			key = str(link["star2"].objid) + "|" + str(link["star1"].objid)
		if not seen.has(key):
			seen[key] = true
			unique_links.append(link)
	links = unique_links
	
	# Generate jumpgates
	for star in stars:
		star._gen_jumpgates(getLinkedStars(star))
	
	# Verify connectivity
	var allstars = []
	checkStarmap(stars[0], allstars, 0)
	if allstars.size() == stars.size():
		print("Proper map!")
	else:
		print("Map contains unreachable stars! Regenerating...")
		generateStarmap()

func checkStarmap(star, allstars, numi):
	allstars.append(star)
	var linkeds = getLinkedStars(star)
	for cstar in linkeds:
		if not cstar in allstars:
			checkStarmap(cstar, allstars, numi + 1)

func getClosestStars(cstar):
	var dists = []
	for star in stars:
		if star != cstar:
			var dist = pow(cstar.mapx - star.mapx, 2) + pow(cstar.mapy - star.mapy, 2)
			dists.append({"star": star, "dist": dist})
	dists.sort_custom(func(a, b): return a["dist"] < b["dist"])
	return dists

func getLinks(cstar):
	var ret = []
	for link in links:
		if link["star1"].objid == cstar.objid or link["star2"].objid == cstar.objid:
			ret.append(link)
	return ret

func getLinkedStars(cstar):
	var ret = []
	for link in getLinks(cstar):
		if link["star1"].objid == cstar.objid:
			ret.append(link["star2"])
		elif link["star2"].objid == cstar.objid:
			ret.append(link["star1"])
	return ret

func getStarById(objid):
	for star in stars:
		if star.objid == objid:
			return star
	return null

func getShortestpath(srcstar, deststar):
	# A* implementation
	var closedset = []
	var came_from = {}
	var openset = [srcstar]
	var g_score = {}
	var f_score = {}
	
	g_score[srcstar.objid] = 0
	f_score[srcstar.objid] = heuristic_cost_estimate(srcstar, deststar)
	
	while openset.size() > 0:
		var current = getLowest(openset, f_score)
		
		if current.objid == deststar.objid:
			return reconstruct_path(came_from, deststar)
		
		openset.erase(current)
		closedset.append(current)
		
		var neighbors = getLinkedStars(current)
		for neighbor in neighbors:
			var tentative_g_score = dist_between(current, neighbor) + g_score.get(current.objid, 0)
			
			var skip = false
			if neighbor in closedset:
				if tentative_g_score >= g_score.get(neighbor.objid, INF):
					skip = true
			
			if not skip:
				if not neighbor in openset or tentative_g_score < g_score.get(neighbor.objid, INF):
					came_from[neighbor.objid] = current
					g_score[neighbor.objid] = tentative_g_score
					f_score[neighbor.objid] = g_score[neighbor.objid] + heuristic_cost_estimate(neighbor, deststar)
					if not neighbor in openset:
						openset.append(neighbor)
	
	return null

func getLowest(stars_list, inset):
	var minscore = INF
	var mintile = null
	for star in stars_list:
		var score = inset.get(star.objid, INF)
		if score < minscore:
			minscore = score
			mintile = star
	return mintile

func reconstruct_path(came_from, current_star):
	var retarr = []
	var cstar = current_star
	var i = 99999
	while i > 0 and cstar != null:
		retarr.append(cstar)
		cstar = came_from.get(cstar.objid, null)
		i -= 1
	retarr.reverse()
	return retarr

func dist_between(star1, star2):
	return 1

func heuristic_cost_estimate(star, goal):
	return dist_between(star, goal)

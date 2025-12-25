class_name Inventory

const CATEGORIES = ["Foodstuffs", "Medical Supplies", "Alcohol", "Minerals", "Luxury", "Technics", "Weapons", "Narcotics", "Credits"]

var items: Dictionary = {}  # category -> {amount: int, total_cost: float}

func add_item(category: String, amount: int, cost_per_unit: float = 0.0) -> bool:
	if not CATEGORIES.has(category):
		return false
	if not items.has(category):
		items[category] = {"amount": 0, "total_cost": 0.0}
	var current = items[category]
	var new_amount = current["amount"] + amount
	var new_total_cost = current["total_cost"] + amount * cost_per_unit
	items[category] = {"amount": new_amount, "total_cost": new_total_cost}
	return true

func remove_item(category: String, amount: int) -> bool:
	if not items.has(category):
		return false
	var current = items[category]
	if current["amount"] < amount:
		return false
	var ratio = float(amount) / current["amount"]
	current["amount"] -= amount
	current["total_cost"] -= current["total_cost"] * ratio
	if current["amount"] == 0:
		items.erase(category)
	else:
		items[category] = current
	return true

func get_total_items() -> int:
	var total = 0
	for cat in items.keys():
		if cat != "Credits":
			total += items[cat]["amount"]
	return total

func can_add(category: String, amount: int, cargo_capacity: int) -> bool:
	var new_total = get_total_items() + amount
	return new_total <= cargo_capacity

func get_amount(category: String) -> int:
	return items.get(category, {"amount": 0})["amount"]

func get_average_cost(category: String) -> float:
	var data = items.get(category, {"amount": 0, "total_cost": 0.0})
	if data["amount"] == 0:
		return 0.0
	return data["total_cost"] / data["amount"]

func get_items() -> Dictionary:
	return items.duplicate()

func get_total_capacity_used() -> int:
	return get_total_items()
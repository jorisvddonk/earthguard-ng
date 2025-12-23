class_name Inventory

const CATEGORIES = ["Foodstuffs", "Medical Supplies", "Alcohol", "Minerals", "Luxury", "Technics", "Weapons", "Narcotics"]

var items: Dictionary = {}  # category -> amount

func add_item(category: String, amount: int) -> bool:
	if not CATEGORIES.has(category):
		return false
	if not items.has(category):
		items[category] = 0
	items[category] += amount
	return true

func remove_item(category: String, amount: int) -> bool:
	if not items.has(category) or items[category] < amount:
		return false
	items[category] -= amount
	if items[category] == 0:
		items.erase(category)
	return true

func get_total_items() -> int:
	var total = 0
	for amount in items.values():
		total += amount
	return total

func can_add(category: String, amount: int, cargo_capacity: int) -> bool:
	var new_total = get_total_items() + amount
	return new_total <= cargo_capacity

func get_amount(category: String) -> int:
	return items.get(category, 0)

func get_items() -> Dictionary:
	return items.duplicate()

func get_total_capacity_used() -> int:
	return get_total_items()
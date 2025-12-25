extends "res://src/ShipSubsystem.gd"

class_name AISubsystem

signal target_lost

var Task = load("res://src/Task.gd")
var Target = load("res://src/Target.gd")
var MemoryReader = load("res://src/MemoryReader.gd")
var MemorySubsystem = load("res://src/MemorySubsystem.gd")

var task
var other_ships_hitting_me: Dictionary
var memory_reader
var trade_item: String = ""
var trade_decided: bool = false
var trade_sell_planet = null

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	self.subsystem_type = "ai"
	self.task = create_task(Task.TaskType.IDLE, Task.Goal.IDLE)
	self.other_ships_hitting_me = {}
	
	var callbacks = {
		MemorySubsystem.MessageType.TAKEN_DAMAGE: Callable(self, "_on_taken_damage")
	}
	self.memory_reader = MemoryReader.new(ship_node, callbacks)

func tick(delta):
	super.tick(delta)
	
	if self.task and self.task.target:
		if (self.task.target.type == Target.TargetType.LOST or 
			(self.task.target.type == Target.TargetType.GAMEOBJECT and not self.task.target.get_game_object())):
			# Target lost
			emit_signal("target_lost")  # Emit signal or something
	
	# Trade logic
	if self.task and self.task.goal == Task.Goal.TRADE:
		var current_planet = null
		if self.task.target and self.task.target.type == Target.TargetType.GAMEOBJECT:
			current_planet = self.task.target.get_game_object()
		if current_planet and current_planet is Planet and ship.position.distance_to(current_planet.position) < 100:
			set_task(create_task(Task.TaskType.HALT, Task.Goal.TRADE))  # Stop using task system
			if trade_item == "" and not trade_decided:
				GlobalSignals.debuglog.emit("AI looking for trade opportunity")
				var market_data = ship.request_market_data_from_planet()
				var trade_result = find_best_trade(market_data)
				var best_cat = trade_result.best_cat
				var best_profit = trade_result.best_profit
				var best_buy_planet = trade_result.best_buy_planet
				var best_sell_planet = trade_result.best_sell_planet
				if best_cat != "":
					GlobalSignals.debuglog.emit("AI decided to trade " + best_cat + " from " + str(best_buy_planet) + " to " + str(best_sell_planet) + " profit: " + str(best_profit))
					if current_planet == best_buy_planet:
						if ship.inventory.get_amount("Credits") >= market_data[current_planet]["prices"][best_cat]["buy_price"] and market_data[current_planet]["supplies"][best_cat] > 0 and ship.inventory.can_add(best_cat, 1, ship.cargo_capacity):
							ship.buy_from_planet(current_planet, best_cat, 1)
							trade_item = best_cat
							trade_decided = true
							if best_sell_planet != current_planet:
								var target = Target.new(Target.TargetType.GAMEOBJECT, best_sell_planet)
								set_task(Task.new(Task.TaskType.MOVE, Task.Goal.TRADE, target))
							else:
								trade_item = ""
								set_task(create_task(Task.TaskType.IDLE, Task.Goal.TRADE))
						else:
							GlobalSignals.debuglog.emit("Cannot buy: credits=" + str(ship.inventory.get_amount("Credits")) + ", buy_price=" + str(market_data[current_planet]["prices"][best_cat]["buy_price"]) + ", supplies=" + str(market_data[current_planet]["supplies"][best_cat]) + ", can_add=" + str(ship.inventory.can_add(best_cat, 1, ship.cargo_capacity)))
							trade_decided = true
							set_task(create_task(Task.TaskType.IDLE, Task.Goal.TRADE))
					else:
						var target = Target.new(Target.TargetType.GAMEOBJECT, best_buy_planet)
						set_task(Task.new(Task.TaskType.MOVE, Task.Goal.TRADE, target))
				else:
					GlobalSignals.debuglog.emit("No profitable trade found")
					trade_decided = true
					set_task(create_task(Task.TaskType.HALT, Task.Goal.TRADE))
			elif trade_item != "":
				GlobalSignals.debuglog.emit("AI selling " + trade_item + " at " + str(current_planet))
				# Sell the item
				if ship.inventory.get_amount(trade_item) > 0:
					ship.sell_to_planet(current_planet, trade_item, 1)
					trade_item = ""
					trade_decided = false
					set_task(create_task(Task.TaskType.IDLE, Task.Goal.TRADE))
		elif self.task.type == Task.TaskType.IDLE and self.task.goal == Task.Goal.TRADE:
			# Evaluate trade
			GlobalSignals.debuglog.emit("AI evaluating trade opportunity")
			var market_data = ship.request_market_data_from_planet()
			var trade_result = find_best_trade(market_data)
			var best_cat = trade_result.best_cat
			var best_profit = trade_result.best_profit
			var best_buy_planet = trade_result.best_buy_planet
			var best_sell_planet = trade_result.best_sell_planet
			if best_cat != "":
				GlobalSignals.debuglog.emit("AI decided to trade " + best_cat + " from " + str(best_buy_planet) + " to " + str(best_sell_planet) + " profit: " + str(best_profit))
				trade_sell_planet = best_sell_planet
				var target = Target.new(Target.TargetType.GAMEOBJECT, best_buy_planet)
				set_task(Task.new(Task.TaskType.MOVE, Task.Goal.TRADE, target))
			else:
				GlobalSignals.debuglog.emit("No profitable trade found")
				trade_decided = true
				set_task(create_task(Task.TaskType.IDLE, Task.Goal.IDLE))
	
	# Other logic

func _on_taken_damage(data: Dictionary):
	var perpetrator_objid = data.perpetrator_objid
	var damage = data.damage
	var old_d = self.other_ships_hitting_me.get(perpetrator_objid, 0.0)
	var new_d = old_d + damage
	self.other_ships_hitting_me[perpetrator_objid] = new_d
	if old_d < 300 and new_d >= 300:
		# Assume objectRegistry
		var perpetrator = null  # get from registry
		if perpetrator:
			self.set_task(create_task(Task.TaskType.ATTACK, Task.Goal.DESTROY, perpetrator))
			# Notification

func get_target():
	return self.task.target

func get_task():
	return self.task

func set_task(new_task):
	if not new_task:
		push_error("Task is null!")
		return
	self.task = new_task
	# Emit signal

func clear_task():
	self.task = create_task(Task.TaskType.IDLE, Task.Goal.IDLE)

func create_task(task_type, goal, target = null):
	return Task.new(task_type, goal, target)

func find_best_trade(market_data):
	var planets = market_data.keys()
	var best_cat = ""
	var best_profit = 0
	var best_buy_planet = null
	var best_sell_planet = null
	for cat in Inventory.CATEGORIES:
		if cat == "Credits":
			continue
		var min_buy_price = INF
		var max_sell_price = 0
		var buy_planet = null
		var sell_planet = null
		for p in planets:
			var prices = market_data[p]["prices"][cat]
			var buy_price = prices["buy_price"]
			var sell_price = prices["sell_price"]
			if buy_price < min_buy_price:
				min_buy_price = buy_price
				buy_planet = p
			if sell_price > max_sell_price:
				max_sell_price = sell_price
				sell_planet = p
		var profit = max_sell_price - min_buy_price
		GlobalSignals.debuglog.emit("Cat: " + cat + ", min_buy: " + str(min_buy_price) + ", max_sell: " + str(max_sell_price) + ", profit: " + str(profit) + ", buy_planet: " + str(buy_planet) + ", sell_planet: " + str(sell_planet))
		if profit > best_profit and buy_planet != sell_planet:
			best_profit = profit
			best_cat = cat
			best_buy_planet = buy_planet
			best_sell_planet = sell_planet
	return {"best_cat": best_cat, "best_profit": best_profit, "best_buy_planet": best_buy_planet, "best_sell_planet": best_sell_planet}

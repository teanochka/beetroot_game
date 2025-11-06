extends Node2D

signal money_changed(new_money)
signal building_selected(building_key, building_texture)

var player_money: int = 1000
var tutorial

func _ready():
	tutorial = get_tree().get_first_node_in_group("Tutorial")
	add_to_group("GameManager")
	money_changed.emit(player_money)

func select_building(building_key: String, building_texture: Texture2D):
	print("GameManager: select_building для ", building_key)
	building_selected.emit(building_key, building_texture)

func can_afford(price: int) -> bool:
	return player_money >= price

func purchase(price: int) -> bool:
	print("GameManager: Попытка покупки за ", price, ". Денег: ", player_money)
	if can_afford(price):
		player_money -= price
		print("GameManager: Покупка успешна! Осталось денег: ", player_money)
		money_changed.emit(player_money)
		return true
	print("GameManager: Недостаточно денег!")
	return false
	
func add_money(amount: int):
	player_money += amount
	money_changed.emit(player_money)
	tutorial.complete_task_by_type("sell_items")

extends CanvasLayer

@onready var talk = $talk
@onready var conversation = $talk/conversation

@onready var terminal = $terminal
@onready var textArea = $terminal/text
@onready var messageTimer = $terminal/messageTimer

@onready var time = $Clock/time

@onready var ShopMenu = $ShopMenu

@onready var InventoryMenu = $Inventory
@onready var inventoryText = $Inventory/inventoryText

@onready var Money = $Wallet/Money

signal populateShop(inventory:Array)
signal sendMoneyToPlayer(money:int)

func _process(delta: float) -> void:
	if textArea.text == "" or conversation.text != "":
		terminal.visible = false
	else:
		terminal.visible = true
		
	if conversation.text == "":
		talk.visible = false
	else:
		talk.visible = true
		
	if global.in_shop:
		ShopMenu.visible = true
	else:
		ShopMenu.visible = false
		
		
func _on_player_update_hud(type: String, payload: String) -> void:

	match type:
		"Text":
			textArea.text = payload	
			messageTimer.start()
		"alex":
			if global.talking == false:
				conversation.text = "Hello, do you know the rizzler?"
				global.talking = true
			else:
				global.talking = false
				conversation.text = ""
		"FishShopKeeper":
			if global.talking == false:
				conversation.text = "Welcome to the fish shop!"
				global.talking = true
				global.in_shop = false
				
			elif global.talking and not global.in_shop :
				populateShop.emit(global.inventory)
				conversation.text = ""
				global.in_shop = true
	
			elif global.in_shop :
				global.talking = false
				global.in_shop = false
				conversation.text = ""
			
			
			
	
	


func _on_message_timer_timeout() -> void:
	textArea.text = ""


func _on_time_send_time(timeString: String) -> void:
	time.text = timeString 





func _on_player_inventory_handle(inventory: Array) -> void:
	if InventoryMenu.visible == false:
		InventoryMenu.visible = true
		var text = ""
		for item in inventory:
			text += item.name
			text += "\n"
			
		inventoryText.text = text
	else:
		InventoryMenu.visible = false


func _on_shop_menu_send_money(money: int) -> void:
	sendMoneyToPlayer.emit(money)


func _on_player_update_wallet(wallet: int) -> void:
	Money.text= "Money: " + str(wallet)
	

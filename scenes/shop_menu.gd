extends Panel


@onready var fish_list = $FishList
var player_inventory: Array = []

signal sendMoney(money:int)

func _on_hud_populate_shop(inventory: Array) -> void:
	open_menu(inventory)
	
func open_menu(inventory: Array):
	player_inventory = inventory
	visible = true
	update_fish_list()
	
func update_fish_list():
	# Clear existing buttons
	for child in fish_list.get_children():
		child.queue_free()
	
	# Add one button per fish
	for fish in player_inventory:
		print(fish.name)
		if fish is Fish:
			var btn = Button.new()
			btn.text = "%s (%d coins)" % [fish.name, fish.value]
			
			# Store the fish in the button metadata
			btn.set_meta("fish", fish)

			# Connect the pressed signal
			btn.pressed.connect(_on_fish_button_pressed.bind(btn))
			
			fish_list.add_child(btn)
			
func _on_fish_button_pressed(button: Button):
	var fish = button.get_meta("fish")
	if fish and fish in player_inventory:
		#increase money
		sendMoney.emit(fish.value)
		player_inventory.erase(fish)
		update_fish_list()

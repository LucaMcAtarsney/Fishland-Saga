extends CharacterBody2D

signal updateHUD(type:String,payload:String)
var player_alive = true
var moving = false
var charging = false
var fish_in_prog = false
var fishing = false
var near_water = false
var bob_cast = false
var bob = null
var exclamation_node
var facing
@onready var raycast = $InteractionRay
@onready var charge_bar = $ChargeBar
var charge_direction = 1
const speed = 100
var current_dir = "none"
var bobScene = preload("res://scenes/bob.tscn")  # Adjust the path to your actual bob scene

signal startedToFish
signal inventoryHandle(inventory:Array)

var wallet = 0

func _physics_process(delta):
	canMove()
	player_movement(delta)
	inputs()
	fish()
	chargeBar(delta)
	raycast_check()
	
	if not global.player_current_fish:
		charge_bar.visible= false
	
		
		
func inputs():
	if Input.is_action_just_pressed("interact"):
		interact()
	elif Input.is_action_just_pressed("inventory"):
		handleInventory()

func handleInventory():
	inventoryHandle.emit(global.inventory)
	
func interact():
	match facing:
		"alex":
			updateHUD.emit("alex","")
		"FishShopKeeper":
			updateHUD.emit("FishShopKeeper","")
		null:
			pass
	
func canMove():
	if fishing	or global.talking:
		global.can_move = false
	else:
		global.can_move = true
		
func raycast_check():
	near_water = false
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("water"):
			#print("You're near water!")
			near_water = true
		else:
			near_water = false
		
			
		if collider.is_in_group("door"):
			print("at door")
		elif collider.is_in_group("npc"):
			if collider.is_in_group("alex"):
				facing = "alex"
			elif collider.is_in_group("FishShopKeeper"):
				facing = "FishShopKeeper"
		else:
			facing = null
			## Trigger fishing animation, check if fishable, etc.
		#elif collider.is_in_group("npc"):
			#print("You're near an NPC!")
			## Trigger dialogue, etc.
		#elif collider.is_in_group("sign"):
			#print("You're near a sign!")
			## Show sign text	
	
func player_movement(delta):
	if not fishing and global.can_move:
		if Input.is_action_pressed("ui_right"):
			current_dir = "right"
			raycast.target_position = Vector2(15, 0)
			play_anim(1)
			velocity.x = speed
			velocity.y = 0
			moving = true
		elif Input.is_action_pressed("ui_left"):
			current_dir = "left"
			raycast.target_position = Vector2(-15, 0)
			play_anim(1)
			velocity.x = -speed
			velocity.y = 0
			moving = true
		elif Input.is_action_pressed("ui_up"):
			current_dir = "up"
			raycast.target_position = Vector2(0, -15)
			play_anim(1)
			velocity.x = 0
			velocity.y = -speed
			moving = true
		elif Input.is_action_pressed("ui_down"):
			current_dir = "down"
			raycast.target_position = Vector2(0, 15)
			play_anim(1)
			velocity.x = 0
			velocity.y = speed
			moving = true
		else:
			play_anim(0)
			velocity.x = 0
			velocity.y = 0
			moving = false
		
		move_and_slide()
	else:
		play_anim(0)
	
func play_anim(movement):
	
	var dir = current_dir
	var anim = $AnimatedSprite2D
	if not fishing:
		if dir == "right":
			anim.flip_h = false
			if movement == 1:
				anim.play("side_walk")
			elif movement == 0:
				if fish_in_prog == false:
					anim.play("side_idle")
			
		if dir == "left":
			anim.flip_h = true
			if movement == 1:
				anim.play("side_walk")
			elif movement == 0:
				if fish_in_prog == false:
					anim.play("side_idle")
		if dir == "up":
			anim.flip_h = true
			if movement == 1:
				anim.play("back_walk")
			elif movement == 0:
				if fish_in_prog == false:
					anim.play("back_idle")
		if dir == "down":
			anim.flip_h = true
			if movement == 1:
				anim.play("front_walk")
			elif movement == 0:
				if fish_in_prog == false:
					anim.play("front_idle")
	elif fishing:
		#print("here")
		match dir:
			"up":
				anim.play("back_fishing_idle")
			"down":
				anim.play("front_fishing_idle")
			"left":
				anim.flip_h = true
				anim.play("side_fishing_idle")
			"right":
				anim.flip_h = false
				anim.play("side_fishing_idle")
			
			
func player():
	pass
	
func _on_player_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		pass

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("enemy"):
		pass
		
func fish():
	var dir = current_dir

	# Start fishing (hold E)
	if Input.is_action_just_pressed("fish") and not moving and not charging and not fishing and near_water:
		#charge_bar.visible = true
		global.player_current_fish = true
		fish_in_prog = true
		charging = true  # you're holding E now
		match dir:
			"right":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("side_fish")
			"left":
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("side_fish")
			"down":
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("front_fish")
			"up":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("back_fish")

		$AnimatedSprite2D.pause()  # freeze on first frame

	# Release E to cast
	elif Input.is_action_just_released("fish") and charging and not bob_cast and not fishing and near_water:
		#charge_bar.visible = false
		$AnimatedSprite2D.play()  # resumes from where it was paused
		$deal_attack_timer.start()  # or whatever your "cast" or "catch" trigger is
		charging = false
		var cast_power = getPower()
		if near_water:
			cast_bob(cast_power)
		reset_charge_bar()
		startedToFish.emit()
		fishing = true
	elif fishing == true and near_water:
		global.isFishing = true
		if global.fish_on_line != null and bob != null:
			exclamation_node.visible = true
		else:
			exclamation_node.visible = false
		#print("currently fishing")
		
		# if press e and fish, catch fish
		if Input.is_action_just_pressed("fish"):
			var fish = global.fish_on_line
			if fish != null:
				
				print("you just caught a " + fish.name)
				var message = "you just caught a " + fish.name
				global.inventory.append(fish)
				updateHUD.emit("Text",message)
				# play animation
				
				
			
			#if press e and no fish caught, end fishing
			if bob != null:
				fishing = false
				global.isFishing = false
				print("stopped fishing, cleared bob")
				bob.queue_free()
				bob_cast = false
				global.powerAtcast = 0
				
func getPower():
	global.powerAtcast = charge_bar.value
	return charge_bar.value

func cast_bob(cast_power):
	bob_cast = true
	print("bob cast")
	
	bob = bobScene.instantiate()
	get_parent().add_child(bob)  # Add to world scene, not player
	var cast_distance = lerp(10, 50, cast_power / 100.0)  # Min 32 px, Max 128 px
	var bob_direction
	exclamation_node = bob.get_node("exclamation")
	match current_dir:
		"up": bob_direction = Vector2(0, -1)
		"down":bob_direction =  Vector2(0, 1)
		"left":bob_direction =  Vector2(-1, 0)
		"right":bob_direction =  Vector2(1, 0)
		_:bob_direction =  Vector2(0, 1)  # default

	var start_position = global_position + Vector2(0, -8)  # Offset from player head
	var end_position = start_position + bob_direction * cast_distance
	bob.global_position = end_position

	
func chargeBar(delta):
	if not moving:
		if charging:
			charge_bar.visible = true

			# Move the meter back and forth
			charge_bar.value += charge_direction * 100 * delta
			if charge_bar.value >= 100:
				charge_bar.value = 100
				charge_direction = -1
			elif charge_bar.value <= 0:
				charge_bar.value = 0
				charge_direction = 1

		else:
			charge_bar.visible = false
	else:
		charge_bar.visible = false
		global.player_current_fish = false

func reset_charge_bar():
	charge_direction = 1	
	charge_bar.value = 0
	
func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_fish = false
	fish_in_prog = false
	
	

signal updateWallet(wallet:int)

func _on_hud_send_money_to_player(money: int) -> void:
	wallet += money
	updateWallet.emit(wallet)

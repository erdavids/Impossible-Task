extends Node2D

var sequence = []

var player_button_count = 0

var current_displayed = 0
var current_solved = 0

var flash_length = .5
var flash_pause = .1

var flash_texture = preload("res://Sprites/flash.png")
var blank_texture = preload("res://Sprites/transparent-flash.png")

var unlit = preload("res://Sprites/unlit-indicator.png")
var lit = preload("res://Sprites/lit-indicator.png")
var failed = preload("res://Sprites/failed-indicator.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	create_sequence()
	for b in $PlayerButtons.get_children():
		b.disabled = true
		
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		$Grid.visible = !$Grid.visible
	
func create_sequence():
	
	# Basically tracks how many the player has solved
	current_displayed = 0
	
	randomize()
	for i in range(0, 18):
		sequence.append(int(rand_range(0, 49)))
		
	$StartTimer.set_wait_time(2)
	$StartTimer.start()

func flash():
	if (current_displayed <= current_solved):
		get_node("Console").get_children()[sequence[current_displayed]].texture = flash_texture
		$FlashTimer.set_wait_time(flash_length)
		$FlashTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = false

func player_pressed(name):
	var button_pressed = int(name.replace("Button", "")) - 1
	
	if (button_pressed == sequence[player_button_count]):
		$ButtonIndicators.get_children()[player_button_count].texture = lit
		player_button_count += 1
		
		if (current_solved == 17 and player_button_count == 17):
			$Emergency.visible = true
			$Emergency/AnimatedSprite.playing = true
			for b in $PlayerButtons.get_children():
				b.disabled = true
				
			$FailureTimer.set_wait_time(4)
			$FailureTimer.start()
		
		
		if (player_button_count > current_solved):
			for b in $PlayerButtons.get_children():
				b.disabled = true
			current_displayed = 0
			player_button_count = 0
			increase_solved()
			$ClearIndicatorsTimer.set_wait_time(.5)
			$ClearIndicatorsTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = true
		
		for i in $ButtonIndicators.get_children():
			i.texture = failed
		for i in $ConsoleIndicators.get_children():
			i.texture = failed
			
		$FailureTimer.set_wait_time(.5)
		$FailureTimer.start()
		
func clear_player_indicators():
	
	for i in $ButtonIndicators.get_children():
		i.texture = unlit
		
func increase_solved():
	$ConsoleIndicators.get_children()[current_solved].texture = lit
	current_solved += 1
	
	if (current_solved >= 18):
		for b in $PlayerButtons.get_children():
			b.disabled = true
	else:
		flash()
	

func _on_FlashTimer_timeout():
	for c in get_node("Console").get_children(): 
		c.texture = blank_texture
		
	$PauseTimer.set_wait_time(flash_pause)
	$PauseTimer.start()


func _on_PauseTimer_timeout():
	current_displayed += 1
	flash()


func _on_StartTimer_timeout():
	flash()


func _on_ClearIndicatorsTimer_timeout():
	clear_player_indicators()


func _on_FailureTimer_timeout():
	$Emergency.visible = false
	$Emergency/AnimatedSprite.frame = 0
	for i in $ButtonIndicators.get_children():
		i.texture = unlit
		
	for i in $ConsoleIndicators.get_children():
		i.texture = unlit
		
	sequence = []

	player_button_count = 0

	current_displayed = 0
	current_solved = 0

	flash_length = .5
	flash_pause = .1
		
	_ready()

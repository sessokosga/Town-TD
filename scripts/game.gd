extends Control
class_name Game

enum Status {Failure, Playing, Reward, Victory, Pause,WaveInfo}

@onready var tower_buttons = $"%TowerButtons"
@onready var towers_parent = $"%TowerParents"
@onready var rewards_parent : Control = $"%RewardsParent"
@onready var level : Level = $BaseLevel
@onready var lab_status : Label = $"%Status"
@onready var lab_health : Label = $"%Health"
@onready var lab_money : Label = $"%Money"
@onready var lab_wave_info : Label = $"%Info"
@onready var ctl_victory : Control = $"%Victory"
@onready var ctl_failure : Control = $"%Failure"
@onready var ctl_pause : Control = $"%Pause"
@onready var ctl_wave_info : Control = $"%WaveInfo"
@onready var ctl_reward : Control = $"%Reward"
@onready var btn_select_reward : Button = $"%SelectReward"
@onready var tb_single_canon : TowerButton = $"%SingleCanon"
@onready var tb_double_canon : TowerButton = $"%DoubleCanon"
@onready var tb_open_double_missile : TowerButton = $"%OpenDoubleMissile"
@onready var tb_open_single_missile : TowerButton = $"%OpenSingleMissile"
@onready var tb_closed_double_missile : TowerButton = $"%ClosedDoubleMissile"

# Preload tower nodes
var tower_single_canon_node = preload("res://scenes/tower_single_canon.tscn")
var tower_double_canon_node = preload("res://scenes/tower_double_canon.tscn")
var tower_open_single_missile_node = preload("res://scenes/tower_open_single_missile.tscn")
var tower_open_double_missile_node = preload("res://scenes/tower_open_double_missile.tscn")
var tower_closed_double_missile_node = preload("res://scenes/tower_closed_double_missile.tscn")

var tower_cost = 0
var selected_reward : Reward = null
var selected_tower_button : TowerButton = null

var status : Status:
	set(v):
		status = v
		if not is_instance_valid(ctl_failure):
			return
		ctl_failure.hide()
		ctl_victory.hide()
		ctl_reward.hide()
		ctl_pause.hide()
		ctl_wave_info.hide()
		pause_status(true)
		match status:
			Status.Victory:
				ctl_victory.show()
			Status.Failure:
				ctl_failure.show()
			Status.Reward:
				ctl_reward.show()
			Status.Pause:
				ctl_pause.show()
			Status.WaveInfo:
				ctl_wave_info.show()
			Status.Playing:
				pause_status(false)
			
				

var money : int :
	set(v):
		money = v
		if not is_instance_valid(lab_money):
			return
		lab_money.text = str("Money : ",money)
		check_tower_purchase_availabity()

var health : int:
	set(v):
		health = v
		if not is_instance_valid(lab_health):
			return
		if health <= 0:
			health = 0
			status = Status.Failure
			lab_status.text = str("You survived ",level.wave, " waves")
		lab_health.text = str("Health : ",health)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	status = Status.Playing
	money = 800
	health = 20
	for tb:TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_tower_button_toggled)
		
	level.deploy_tower.connect(_on_deploy_tower)
	level.tank_got_a_way.connect(_on_tank_got_a_way)
	level.waves_completed.connect(_on_waves_completed)
	level.raise_reward.connect(_on_raise_reward)
	level.tank_destroyed.connect(_on_tank_destroyed)
	level.prepare_wave.connect(_on_prepare_wave)
	level.wave_started.connect(_on_wave_started)
	
	
	
	for rwd : Reward in rewards_parent.get_children():
		rwd.active.connect(_on_reward_active)
		rwd.hide()
		rwd.disabled = true
		
	
	add_reward()
	

func _on_prepare_wave(wave):
	lab_wave_info.text = str("Wave ", level.wave ," is comming")
	status = Status.WaveInfo
	
func _on_wave_started():
	status = Status.Playing

func add_reward():
	selected_reward = null
	for rwd : Reward in rewards_parent.get_children():
		rwd.disabled = true
		rwd.selected = false
		rwd.hide()
		
	var found = 0
	var trials = 0
	while  found < 3 and trials < 100: 
		var rwd : Reward = rewards_parent.get_children().pick_random()
		if rwd.disabled and not rwd.removed:
			rwd.disabled = false
			rwd.show()
			found += 1
		trials += 1
	#
func _on_tank_destroyed(tank:Tank)->void:
	money += 50
	
func _on_raise_reward()->void:
	add_reward()
	status = Status.Reward
	
func _on_reward_active(rwd:Reward)->void:
	if status != Status.Reward:
		return
	btn_select_reward.disabled = false
	selected_reward = rwd
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
	for rw : Reward in rewards_parent.get_children():
		if rwd != rw:
			rw.selected = false
	
func _on_waves_completed()->void:
	if health > 0:
		status = Status.Victory

func _on_tank_got_a_way()->void:
	health -= 1

func _on_deploy_tower(place:TowerPlace)->void:
	var tower :Tower 
	match selected_tower_button.type:
		Tower.Type.SingleCanon:
			tower = tower_single_canon_node.instantiate()
		Tower.Type.DoubleCanon:
			tower = tower_double_canon_node.instantiate()
		Tower.Type.OpenSingleMissile:
			tower = tower_open_single_missile_node.instantiate()
		Tower.Type.OpenDoubleMissile:
			tower = tower_open_double_missile_node.instantiate()
		Tower.Type.ClosedDoubleMissile:
			tower = tower_closed_double_missile_node.instantiate()
			
	towers_parent.add_child(tower)
	tower.position = place.position
	tower.occupied_place = place
	money -= tower_cost
	reset_tower_buttons()
	level.toggle_tower_places_visibility(false)

func _tower_button_toggled(tb:TowerButton)->void:
	var reset = true
	if tb.button_pressed:
		selected_tower_button = tb
		tower_cost = tb.cost
		for tbt:TowerButton in tower_buttons.get_children():
			level.toggle_tower_places_visibility(true)
			if tb != tbt :
				tbt.button_pressed = false
	else:
		for tbt:TowerButton in tower_buttons.get_children():
			if tbt.button_pressed == true:
				reset = false
				break
		if reset:
			reset_tower_buttons()
			level.toggle_tower_places_visibility(false)
			
func pause_status(sta)->void:
	for tower:Tower in towers_parent.get_children():
		tower.paused = sta
		
	level.paused = sta
	
	for tank:Tank in level.tank_parents.get_children():
		tank.paused = sta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if status == Status.Victory:
		pass
	elif status == Status.Pause:
		pass
	elif status == Status.Failure:
		pass
	elif status == Status.Playing:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var reset = true
			if not tower_buttons.get_global_rect().has_point(get_global_mouse_position()):
				for tp:TowerPlace in level.tower_places.get_children():
					var rect = tp.box.shape.get_rect()
					rect.position += tp.global_position
					if rect.has_point(get_global_mouse_position()):
						reset = false
						break
				if reset:
					reset_tower_buttons()
					level.toggle_tower_places_visibility(false)
					
					
		# Shoot at towers
		for tank:Tank in level.tank_parents.get_children():
			if tank.status == Tank.Status.Dead:
				break
			
			var rect :Rect2 = tank._range.shape.get_rect()
			rect.position += tank.global_position
			var found = false
			for tower:Tower in towers_parent.get_children():
				if tower.status == Tower.Status.Dead:
					break
				var target = tower.hit_area.position+tower.global_position #- Vector2(0,50)
				if rect.has_point(target):
					found = true
					var direction = (target-tank.global_position).normalized()
					var angle_to = tank.barrel.transform.y.angle_to(-direction)
					#tank.barrel.rotate(angle_to)
				
		# Check collision between bullet and tanks
		for bullet:Projectile in get_tree().get_nodes_in_group("bullet"):
			if bullet.sender == Projectile.Sender.Tower:
				for tank:Tank in level.tank_parents.get_children():
					var rect = tank.hit_area.shape.get_rect()
					rect.position += tank.global_position
					if rect.has_point(bullet.hit_area.global_position):
						tank.take_damage(bullet.damage)
						bullet.destroy()
						
			elif bullet.sender == Projectile.Sender.Tank:
				for tower:Tower in towers_parent.get_children():
					var rect = tower.hit_area.shape.get_rect()
					rect.position += tower.global_position
					if rect.has_point(bullet.global_position):
						tower.take_damage(bullet.damage)
						bullet.destroy()

func reset_tower_buttons()->void:
	tower_cost = 0
	for tb:TowerButton in tower_buttons.get_children():
		tb.button_pressed = false
		
func check_tower_purchase_availabity()->void:
	for tb:TowerButton in tower_buttons.get_children():
		var c = tb.cost
		if c <= money:
			tb.disabled = false
		else:
			tb.disabled = true

func _on_tower_button_toggled(toggled_on: bool) -> void:
	$BaseLevel.toggle_tower_places_visibility(toggled_on)

func _apply_reward()->void:
	AudioPlayer.play_ui(AudioPlayer.UI.Confirm)
	selected_reward.hide()
	selected_reward.disabled = true
	match selected_reward.effect:
		Reward.Effect.AddTwoTowerPlace:
			level.add_tower_places(2) 
			if not level.is_empty_spot_available:
				selected_reward.removed = true
		Reward.Effect.AddTwoHealthPoints:
			health += 2
		Reward.Effect.AddThousandCoins:
			money += 1000
		Reward.Effect.DoubleCanon:
			tb_double_canon.disabled = false
			tb_double_canon.show()
			check_tower_purchase_availabity()
			selected_reward.removed = true
		Reward.Effect.OpenSingleMissile:
			tb_open_single_missile.disabled = false
			tb_open_single_missile.show()
			check_tower_purchase_availabity()
			selected_reward.removed = true
		Reward.Effect.OpenDoubleMissile:
			tb_open_double_missile.disabled = false
			tb_open_double_missile.show()
			check_tower_purchase_availabity()
			selected_reward.removed = true
		Reward.Effect.ClosedDoubleMissile:
			tb_closed_double_missile.disabled = false
			tb_closed_double_missile.show()
			check_tower_purchase_availabity()
			selected_reward.removed = true
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		status = Status.Pause
		

func _on_select_reward_pressed() -> void:
	status = Status.Playing
	_apply_reward()


func _on_resume_pressed() -> void:
	status = Status.Playing


func _on_pause_pressed() -> void:
	status = Status.Pause


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/home.tscn")


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

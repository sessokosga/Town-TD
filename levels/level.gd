extends Control
class_name Level

signal deploy_tower(place)
signal tank_destroyed(tank)
signal tank_got_a_way()
signal waves_completed()
signal raise_reward()
signal wave_started()
signal prepare_wave(wave)


@onready var tower_places : Control = $"%TowerPlaces"
@onready var tank_parents : Control = $"%TanksParent"
@onready var path :Control = $"%Path"
@onready var lab_wave :Label = $"%Wave"
@onready var progress :ProgressBar = $"%Progress"

var max_waves = 4
@export var tanks_per_wave = 2
@export var tank_increase = 2
@export var starting_places = 10
@export var debug = false

var tank_node = preload("res://scenes/tank.tscn")
var tank_big_node = preload("res://scenes/tank_big.tscn")
var tank_huge_node = preload("res://scenes/tank_huge.tscn")
var tank_large_node = preload("res://scenes/tank_large.tscn")

const TANK_COLORS = [Tank.Type.Red, Tank.Type.Green, Tank.Type.Dark, Tank.Type.Blue, Tank.Type.Sand]
const BOSS_TYPES = [Tank.Type.BigRed, Tank.Type.Large, Tank.Type.Huge]

var boss_of_type = [0,0,0]
var boss_type = 0
var spawn_time = 3
var time:float = 0
var spawned_tanks = 0
var tanks_on_screen = 0
var boss_count = 0
var enabled_places = 0
var paused = false
var start_wave = false
var is_empty_spot_available = true
var next_reward_target = 2
var tank_color = 0
var wave_count = 0
var wave : int: 
	set(v):
		wave = v
		if not is_instance_valid(lab_wave):
			return
		if wave_count == next_reward_target:
			raise_reward.emit()
			AudioPlayer.play_ui(AudioPlayer.UI.RewardUnlocked)
			next_reward_target = 4
			wave_count = 0
			boss_type = 0
			boss_count += 1
			tank_color +=1
			var size = BOSS_TYPES.size()
			for i in range(boss_count):
				boss_of_type[i%size] += 1
			#if i < BOSS_TYPES.size():
				#boss_of_type
			if tank_color >= TANK_COLORS.size():
				tank_color = 0
			progress.value = progress.max_value
		lab_wave.text = str("Wave ",wave)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	start_wave = true
	wave = 1 
	for tp:TowerPlace in tower_places.get_children():
		tp.add_tower.connect(
			func ():
				deploy_tower.emit(tp)
		)
	# Make random places available
	enabled_places = 0
	add_tower_places(starting_places)
			

func _on_tank_dead(tank:Tank)->void:
	tanks_on_screen -= 1
	tank_destroyed.emit(tank)
	
func _on_tank_reached_target(tank:Tank)->void:
	tank.position = tank.target
	tank.target = _get_next_target(tank.target)
	
func _on_tank_out_of_screen(tank:Tank)->void:
	tanks_on_screen -= 1
	tank_got_a_way.emit()

func spawn_tank(type:Tank.Type = Tank.Type.Blue)->void:
	var tank :Tank
	if type == Tank.Type.BigRed:
		tank = tank_big_node.instantiate()
	elif type == Tank.Type.Huge:
		tank = tank_huge_node.instantiate()
	elif type == Tank.Type.Large:
		tank = tank_large_node.instantiate()
	else:
		tank = tank_node.instantiate()
		tank.health += type
	tank_parents.add_child(tank)
	tank.type = type
	tank.global_position = path.get_child(0).position
	tank.target = path.get_child(1).position
	tank.dead.connect(_on_tank_dead)
	tank.out_of_screen.connect(_on_tank_out_of_screen)
	tank.arrived.connect(_on_tank_reached_target)
	spawned_tanks += 1
	tanks_on_screen += 1
	tank.speed += 5 * (wave-1)

func _get_next_target(tg:Vector2)->Vector2:
	var target = Tank.OUT_OF_BOUNDS
	var count = path.get_child_count()
	for i in range(count):
		if tg == path.get_child(i).position and i < count - 1:
			return path.get_child(i+1).position
			
	return target
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused :
		return
	
	progress.value = wave_count * 100 / next_reward_target
	time -= delta
	var regular_tanks = tanks_per_wave + tank_increase * (wave - 1)
	var tanks_of_the_wave = tanks_per_wave + tank_increase * (wave - 1) + boss_count
	if start_wave:
		if spawned_tanks < tanks_of_the_wave:
			if time <= 0:
				if spawned_tanks < regular_tanks :
					spawn_tank(TANK_COLORS[tank_color])
				elif spawned_tanks < tanks_of_the_wave:
					spawn_tank(BOSS_TYPES[boss_type])
					boss_of_type[boss_type] -= 1
					if boss_of_type[boss_type] <= 0:
						boss_type += 1
					if boss_type >= BOSS_TYPES.size():
						boss_type = 0
				time = spawn_time
		else:
			if tanks_on_screen <= 0:
				if not wave_count +1 == next_reward_target:
					prepare_wave.emit(wave+1)
					get_tree().create_timer(3).timeout.connect(
						func():
							wave_count += 1
							wave += 1
							spawned_tanks = 0
							tanks_on_screen = 0
							start_wave = true
							wave_started.emit()
					)
				else :
					wave_count += 1
					wave += 1
					spawned_tanks = 0
					tanks_on_screen = 0
					start_wave = true
				
			

func toggle_tower_places_visibility(b:bool)->void:
	for tp:TowerPlace in tower_places.get_children():
		if not tp.disabled :
			tp.visible = b
	
func add_tower_places(num)->void:
	if enabled_places < tower_places.get_child_count():
		var target = enabled_places + num
		if target > tower_places.get_child_count():
			target = tower_places.get_child_count()
		while enabled_places < target :
			var tp :TowerPlace = tower_places.get_children().pick_random()
			if tp.disabled:
				tp.disabled = false
				enabled_places += 1
	
		is_empty_spot_available = enabled_places < tower_places.get_child_count()

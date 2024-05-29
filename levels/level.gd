extends Control
class_name Level

signal deploy_tower(place)
signal tank_got_a_way()
signal waves_completed()


@onready var tower_places : Control = $"%TowerPlaces"
@onready var tank_parents : Control = $"%TanksParent"
@onready var path :Control = $"%Path"
@onready var lab_wave :Label = $"%Wave"

@export var max_waves = 4
@export var tanks_per_wave = 2
@export var tank_increase = 2
@export var debug = false

var tank_node = preload("res://scenes/tank.tscn")
var spawn_time = 3
var time:float = 0
var spawned_tanks = 0
var tanks_on_screen = 0
var wave : int: 
	set(v):
		wave = v
		if not is_instance_valid(lab_wave):
			return
		if v <= max_waves:
			lab_wave.text = str("Wave ",wave," / ", max_waves)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave = 1 
	for tp:TowerPlace in tower_places.get_children():
		tp.add_tower.connect(
			func ():
				deploy_tower.emit(tp)
		)

func _on_tank_dead(tank:Tank)->void:
	tanks_on_screen -= 1
	
func _on_tank_reached_target(tank:Tank)->void:
	tank.position = tank.target
	tank.target = _get_next_target(tank.target)
	
func _on_tank_out_of_screen(tank:Tank)->void:
	tanks_on_screen -= 1
	tank_got_a_way.emit()

func spawn_tank()->void:
	var tank = tank_node.instantiate()
	tank_parents.add_child(tank)
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
	if wave <= max_waves:
		time -= delta
		var tanks_of_the_wave = tanks_per_wave + tank_increase * (wave - 1)
		if spawned_tanks < tanks_of_the_wave:
			if time <= 0:
				spawn_tank()
				time = spawn_time
		else:
			if tanks_on_screen <= 0:
				wave += 1
				spawned_tanks = 0
				tanks_on_screen = 0
	else:
		if tanks_on_screen <= 0:
			waves_completed.emit()
func toggle_tower_places_visibility(b:bool)->void:
	for tp:TowerPlace in tower_places.get_children():
		tp.visible = b
	


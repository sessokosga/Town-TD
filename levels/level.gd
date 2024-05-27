extends Control
class_name Level

signal deploy_tower(type,position)


@onready var tower_places : Control = $"%TowerPlaces"
@onready var tank_parents : Control = $"%TanksParent"
@onready var path :Control = $"%Path"
@onready var shape :CollisionShape2D = $"%Shape"

@export var max_waves = 1
@export var debug = false

var tank_node = preload("res://scenes/tank.tscn")

var spawn_time = 1
var time:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tp:TowerPlace in tower_places.get_children():
		tp.add_tower.connect(
			func (type,position):
				deploy_tower.emit(type,position)
		)
		
	for i in range(path.get_child_count()-1):
		var mk = path.get_child(i)
		var mk2 = path.get_child(i+1)
		#if mk2.position
		
func _on_tank_reached_target(tank:Tank)->void:
	tank.position = tank.target
	tank.target = _get_next_target(tank.target)

func spawn_tank()->void:
	var tank = tank_node.instantiate()
	tank_parents.add_child(tank)
	tank.global_position = path.get_child(0).position
	tank.target = path.get_child(1).position
	tank.arrived.connect(_on_tank_reached_target)

func _get_next_target(tg:Vector2)->Vector2:
	var target = Tank.OUT_OF_BOUNDS
	var count = path.get_child_count()
	for i in range(count):
		if tg == path.get_child(i).position and i < count - 1:
			return path.get_child(i+1).position
			
	return target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time <= 0:
		spawn_tank()
		time = spawn_time
		
func toggle_tower_places_visibility(b:bool)->void:
	for tp:TowerPlace in tower_places.get_children():
		tp.visible = b
	


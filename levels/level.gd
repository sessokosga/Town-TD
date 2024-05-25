extends Control
class_name Level

signal deploy_tower(type,position)


@onready var tower_places : Control = $"%TowerPlaces"
@onready var tank_parents : Control = $"%TanksParent"

@export var max_waves = 1
@export var debug = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tp:TowerPlace in tower_places.get_children():
		tp.add_tower.connect(
			func (type,position):
				deploy_tower.emit(type,position)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func toggle_tower_places_visibility(b:bool)->void:
	for tp:TowerPlace in tower_places.get_children():
		tp.visible = b
	


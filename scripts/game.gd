extends Control
class_name Game

@onready var tower_buttons = $"%TowerButtons"
@onready var tower_parents = $"%TowerParents"
@onready var level : Level = $BaseLevel

var tower_node = preload("res://scenes/tower.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tb:TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_tower_button_toggled)
	for tb:TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_tower_button_toggled)
		
	level.deploy_tower.connect(_deploy_tower)

func _deploy_tower(type,position)->void:
	var tower :Tower = tower_node.instantiate()
	tower_parents.add_child(tower)
	tower.type = type
	tower.position = position
	level.toggle_tower_places_visibility(false)

func _tower_button_toggled(tb:TowerButton)->void:
	for tbt:TowerButton in tower_buttons.get_children():
		if tb.button_pressed:
			level.toggle_tower_places_visibility(true)
			if tb != tbt :
				tbt.button_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tower_button_toggled(toggled_on: bool) -> void:
	$BaseLevel.toggle_tower_places_visibility(toggled_on)

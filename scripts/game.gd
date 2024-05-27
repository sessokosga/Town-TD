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
	#Shoot at tanks
	for tower:Tower in tower_parents.get_children():
		var rect :Rect2 = tower.range.shape.get_rect()
		rect.position += tower.global_position
		var found = false
		for  tank:Tank in level.tank_parents.get_children():
			var target = tank.hit_area.position + tank.global_position - Vector2(150,0)
			if rect.has_point(target):
				found = true
				var direction = (target-rect.position).normalized()
				var angle_to = tower.tower.transform.y.angle_to(direction)
				#tank.barrel.rotate(angle_to)
				tower.tower.rotate(signf(angle_to) * -1 * min(delta * tower.rotation_speed, abs(angle_to)) )
		if not found:
			var angle_to = 0
			#tank.barrel.rotate(angle_to)
			tower.tower.rotation_degrees = 0
	
	# Shoot at towers
	for tank:Tank in level.tank_parents.get_children():
		var rect :Rect2 = tank.range.shape.get_rect()
		rect.position += tank.global_position
		var found = false
		for tower:Tower in tower_parents.get_children():
			var target = tower.hit_area.position+tower.global_position - Vector2(0,50)
			if rect.has_point(target):
				found = true
				var direction = (target-rect.position).normalized()
				var angle_to = tank.barrel.transform.y.angle_to(direction)
				#tank.barrel.rotate(angle_to)
				tank.barrel.rotate(signf(angle_to) * 1 * min(delta * tank.barrel_rotation_speed, abs(angle_to)) )
		if not found:
			var angle_to = 0
			#tank.barrel.rotate(angle_to)
			tank.barrel.rotation_degrees = 0
			#tank.barrel.rotate(signf(angle_to) * -1 * min(delta * tank.barrel_roation_speed, abs(angle_to)) )
			


func _on_tower_button_toggled(toggled_on: bool) -> void:
	$BaseLevel.toggle_tower_places_visibility(toggled_on)

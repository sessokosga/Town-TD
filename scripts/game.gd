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
		
	level.deploy_tower.connect(_deploy_tower)

func _deploy_tower(place:TowerPlace)->void:
	var tower :Tower = tower_node.instantiate()
	tower_parents.add_child(tower)
	tower.type = place.type
	tower.position = place.position
	tower.occupied_place = place
	reset_tower_buttons()
	level.toggle_tower_places_visibility(false)

func _tower_button_toggled(tb:TowerButton)->void:
	var reset = true
	if tb.button_pressed:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		for tower:Tower in tower_parents.get_children():
			if tower.status == Tower.Status.Dead:
				break
			var target = tower.hit_area.position+tower.global_position #- Vector2(0,50)
			if rect.has_point(target):
				found = true
				var direction = (target-tank.global_position).normalized()
				var angle_to = tank.barrel.transform.y.angle_to(-direction)
				#tank.barrel.rotate(angle_to)
			
	# Check collision between bullet and tanks
	for bullet:Bullet in get_tree().get_nodes_in_group("bullet"):
		if bullet.sender == Bullet.Sender.Tower:
			for tank:Tank in level.tank_parents.get_children():
				var rect = tank.hit_area.shape.get_rect()
				rect.position += tank.global_position
				if rect.has_point(bullet.hit_area.global_position):
					tank.take_damage(bullet.damage)
					bullet.destroy()
					
		elif bullet.sender == Bullet.Sender.Tank:
			for tower:Tower in tower_parents.get_children():
				var rect = tower.hit_area.shape.get_rect()
				rect.position += tower.global_position
				if rect.has_point(bullet.global_position):
					tower.take_damage(bullet.damage)
					bullet.destroy()

func reset_tower_buttons()->void:
	for tb:TowerButton in tower_buttons.get_children():
		tb.button_pressed = false

func _on_tower_button_toggled(toggled_on: bool) -> void:
	$BaseLevel.toggle_tower_places_visibility(toggled_on)

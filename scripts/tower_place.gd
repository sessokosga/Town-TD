extends Area2D
class_name TowerPlace

signal add_tower()

@onready var normal = $Normal
@onready var hover = $Hover
@onready var box :CollisionShape2D = $"%Box"

var is_occupied = false
var disabled = true
#@export var type : Tower.Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	normal.show()
	hover.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Click 
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_occupied:
		if box.shape.get_rect().has_point(get_local_mouse_position()) and visible:
			is_occupied = true
			add_tower.emit()
	
	# Hover 
	if box.shape.get_rect().has_point(get_local_mouse_position()) and visible:
		if hover.hidden:
			normal.hide()
			hover.show()
	else:
		if normal.hidden:
			normal.show()
			hover.hide()

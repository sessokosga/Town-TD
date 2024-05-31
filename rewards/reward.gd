extends Control
class_name Reward

enum Effect {
	AddTwoTowerPlace, AddTwoHealthPoints, AddThousandCoins, DoubleCanon, OpenSingleMissile,
	OpenDoubleMissile, ClosedDoubleMissile
}

signal active(reward)

@onready var bg_color : ColorRect = $"%BGColor"

@export var effect :Effect

var selected: bool:
	set(v):
		selected = v
		if not is_instance_valid(bg_color):
			return
		if selected:
			bg_color.color = "ffffff80" 
		else:
			bg_color.color =  "ffffff00"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not selected and is_instance_valid(bg_color):
		if get_global_rect().has_point(get_global_mouse_position()):
			bg_color.color = "d1d1d14e"
		else:
			bg_color.color = "ffffff00"
			
		
		
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if get_global_rect().has_point(get_global_mouse_position()):
			selected = !selected
			if selected:
				active.emit(self)

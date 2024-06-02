extends Control
class_name Reward

enum Effect {
	AddTwoTowerPlace, AddTwoHealthPoints, AddThousandCoins, DoubleCanon, OpenSingleMissile,
	OpenDoubleMissile, ClosedDoubleMissile
}

signal active(reward)

@onready var bg_color : ColorRect = $"%BGColor"

@export var effect :Effect

var disabled = false
var removed = false :
	set(v):
		removed = v
		#if removed:
			#queue_free()

var selected: bool:
	set(v):
		selected = v
		if not is_instance_valid(bg_color):
			return
		if selected:
			AudioPlayer.play_ui(AudioPlayer.UI.Select)
			bg_color.color = "ffffff80" 
			if selected:
				active.emit(self)
		else:
			bg_color.color =  "ffffff00"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible or disabled:
		return
		
	if not selected :
		if not is_instance_valid(bg_color):
			return
			
		if get_global_rect().has_point(get_global_mouse_position()):
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				selected = !selected
			else:
				if not selected:
					bg_color.color = "d1d1d14e"
		else:
			bg_color.color = "ffffff00"
	
		

extends Area2D
class_name Tower

enum Type {
	Barrel_One, Barrel_One_Outline,
	Barrel_Two, Barrel_Two_Outline,
	Barrel_Three, Barrel_Three_Outline,
	Barrel_Four, Barrel_Four_Outline,
	Barrel_Five, Barrel_Five_Outline,
	Barrel_Six, Barrel_Six_Outline,
	Barrel_Seven, Barrel_Seven_Outline
}

@onready var _range = $"%Range"
@onready var _shape = $"%Shape"
@onready var anim = $"%Animation"

var type:Type:
	set(v):
		type = v
		if not is_instance_valid(anim):
			return
		init_tower()

var health:int
var max_health:int

func init_tower()->void:
	match type:
		Type.Barrel_One:
			anim.play("barrel_1")
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("barrel_1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

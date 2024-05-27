extends Area2D
class_name Tower

enum Type {
	SingleCanon, DoubleCanon,
	OpenSingleMissile, OpenDoubleMissile,
	ClosedDoubleMissile
}

@onready var range :CollisionShape2D = $"%Range"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var tower = $"%Tower"

var rotation_speed = 3

var type:Type:
	set(v):
		type = v
		if not is_instance_valid(tower):
			return
		init_tower()

var health:int
var max_health:int

func init_tower()->void:
	match type:
		Type.SingleCanon:
			tower.play("idle")
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tower.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

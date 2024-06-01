extends Area2D
class_name Projectile

@onready var hit_area = $"%HitArea"

enum Sender {Tower,Tank}
var texture :Texture2D:
	set(t):
		$Texture.texture = t

@export var damage = 1
var direction :Vector2
var speed = 20
var sender : Sender
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#direction = Vector2.ZERO
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * direction
	#print(position)
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Tank and sender == Sender.Tank or body is Tower and sender == Sender.Tower:
		return

func destroy()->void:
	direction = Vector2.ZERO
	hide()
	queue_free()

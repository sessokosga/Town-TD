extends CharacterBody2D
class_name Tank

signal arrived(tank)

@onready var center :CollisionShape2D = $"%Center"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var range :CollisionShape2D = $"%Range"
@onready var barrel :Sprite2D = $"%Barrel"

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const OUT_OF_BOUNDS = Vector2(-10000,-10000)

var target : Vector2
var direction = Vector2.ZERO
var roation_speed = 3
var barrel_rotation_speed = 3

func _ready() -> void:
	target = OUT_OF_BOUNDS

func _physics_process(delta: float) -> void:
	# Move toward path
	if target != OUT_OF_BOUNDS:
		direction = (target - position).normalized()
		var angle_to = transform.y.angle_to(direction)
		rotate(signf(angle_to) * -1 * min(delta * roation_speed, abs(angle_to)) )
		
		var rect = hit_area.shape.get_rect()
		rect.position += global_position
		if rect.has_point(target):
			arrived.emit(self)
	
		if direction.x:
			velocity.x = direction.x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if direction.y:
			velocity.y = direction.y * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
	

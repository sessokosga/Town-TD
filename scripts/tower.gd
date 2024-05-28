extends Area2D
class_name Tower

enum Type {
	SingleCanon, DoubleCanon,
	OpenSingleMissile, OpenDoubleMissile,
	ClosedDoubleMissile
}

enum Status {Alive, Dead}

var bullet_node = preload("res://scenes/bullet.tscn")

@onready var _range :CollisionShape2D = $"%Range"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var tower:AnimatedSprite2D = $"%Tower"
@onready var bullet_sample :Sprite2D = $"%Bullet"
@onready var lab_health :Label = $"%Health"
@onready var animated_sprite :AnimatedSprite2D = $"%AnimatedSprite2D"
@onready var animation_player :AnimationPlayer = $"%AnimationPlayer"

var rotation_speed = 3
var target :Tank = null
var shoot_timer = 1
var timer_shoot :float =0.5
var status:Status
@export var occupied_place :TowerPlace

var type:Type:
	set(v):
		type = v
		if not is_instance_valid(tower):
			return
		init_tower()

var health:int:
	set(v):
		health = v
		if not is_instance_valid(lab_health):
			return
		lab_health.text = str(health)
		if health <= 0:
			health = 0
			status = Status.Dead
			animated_sprite.play("explosion")
			animation_player.play("explosion")
		
var max_health:int

func init_tower()->void:
	match type:
		Type.SingleCanon:
			tower.play("idle")
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tower.play("idle")
	health = 10

func shoot(direction:Vector2)->void:
	var bullet : Bullet = bullet_node.instantiate()
	bullet.direction = direction
	bullet.global_rotation = bullet_sample.global_rotation
	add_child(bullet)
	bullet.global_position = bullet_sample.global_position
	bullet.sender = Bullet.Sender.Tower
	status = Status.Alive
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if status == Status.Dead:
		return
	if is_instance_valid(target) :
		timer_shoot -= delta
		if target.status == Tank.Status.Alive:
			# Aim at tank
			timer_shoot -= delta
			var enemy_pos = target.hit_area.position + target.global_position# - Vector2(150,0)
			var direction = (enemy_pos - global_position).normalized()
			var angle_to = tower.transform.y.angle_to(direction)
			#tank.barrel.rotate(angle_to)
			tower.rotate(signf(angle_to) * -1 * min(delta * rotation_speed, abs(angle_to))) 
			
			# Shoot at tank
			if timer_shoot <= 0:
				timer_shoot = shoot_timer
				#shoot(direction)
		#else:
			#var angle_to = 0
			#tower.rotate(signf(angle_to) * -1 * min(delta * rotation_speed, abs(angle_to)))
		else:
			target = null 
		

func _on_body_entered(body: Node2D) -> void:
	if body is Tank and body.status == Tank.Status.Alive:
		target = body


func _on_body_exited(body: Node2D) -> void:
	if body is Tank:
		if body == target:
			target = null
			

func take_damage(damage:float)->void:
	#health -= damage
	pass
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "explosion":
		hide()
		queue_free()
		occupied_place.is_occupied = false

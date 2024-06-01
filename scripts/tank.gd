extends CharacterBody2D
class_name Tank

enum Status {Alive, Dead}
enum Type {Green, Red, Dark, Blue, Sand, BigRed, Huge, Large}
enum ShootMode {Single, Double}

signal arrived(tank)
signal dead(tank)
signal out_of_screen(tank)

@onready var center :CollisionShape2D = $"%Center"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var _range :CollisionShape2D = $"%Range"
@onready var body :Sprite2D = $"%Body"
@onready var barrel :Sprite2D = $"%Barrel"
var barrel_2 :Sprite2D 
@onready var bullet_sample :Sprite2D = $"%Bullet"
@onready var bullet_sample_2 :Sprite2D
@onready var lab_health :Label = $"%Health"
@onready var animation :AnimationPlayer = $"%AnimationPlayer"
@onready var animation_sprite :AnimatedSprite2D = $"%AnimationSprite"

@export var initial_body_rotation:int
@export var initial_barrel_rotation:int
@export var type : Type :
	set(v):
		type = v
		init_tank()

var body_blue = preload("res://assets/images/Objects/tankBody_blue.png")
var barrel_blue = preload("res://assets/images/Objects/tankBlue_barrel2.png")

var body_green = preload("res://assets/images/Objects/tankBody_green.png")
var barrel_green = preload("res://assets/images/Objects/tankGreen_barrel2.png")

var body_sand = preload("res://assets/images/Objects/tankBody_sand.png")
var barrel_sand = preload("res://assets/images/Objects/tankSand_barrel2.png")

var body_red = preload("res://assets/images/Objects/tankBody_red.png")
var barrel_red = preload("res://assets/images/Objects/tankRed_barrel2.png")

var body_dark = preload("res://assets/images/Objects/tankBody_dark.png")
var barrel_dark = preload("res://assets/images/Objects/tankDark_barrel2.png")

var bullet_node 
var paused = false

const OUT_OF_BOUNDS = Vector2(-10000,-10000)

var speed = 300.0
var direction = Vector2.ZERO
var roation_speed = 3
var barrel_rotation_speed = 10
var target : Vector2 = OUT_OF_BOUNDS :
	set(v):
		target = v
		if target == OUT_OF_BOUNDS:
			out_of_screen.emit(self)
			queue_free()
			
@export var health :int:
	set(v):
		health = v
		if not is_instance_valid(lab_health):
			return
		lab_health.text = str(health)
		if health <= 0:
			health = 0
			status = Status.Dead
			animation.play("explosion")
			animation_sprite.play("explosion")
		
var enemy :Tower = null
var shoot_timer = 1
var timer_shoot :float =0.5
var timer_shoot_2 :float =0.5
var status:Status

func init_tank()->void:
	match type:
		Type.Blue:
			body.texture = body_blue
			barrel.texture = barrel_blue
		Type.Red:
			body.texture = body_red
			barrel.texture = barrel_red
		Type.Sand:
			body.texture = body_sand
			barrel.texture = barrel_sand
		Type.Green:
			body.texture = body_green
			barrel.texture = barrel_green
		Type.Dark:
			body.texture = body_dark
			barrel.texture = barrel_dark
		Type.BigRed:
			barrel_2 = $"%Barrel2"
			bullet_sample_2 = $"%Bullet2"
		

func _ready() -> void:
	health = 10
	bullet_node = load("res://scenes/bullet.tscn")
	status = Status.Alive

func shoot(direction:Vector2,second = false)->void:
	var bullet : Projectile = bullet_node.instantiate()
	get_tree().root.add_child(bullet)
	bullet.direction = direction
	if second:
		bullet.global_rotation = bullet_sample_2.global_rotation
		bullet.global_position = bullet_sample_2.global_position
	else :
		bullet.global_rotation = bullet_sample.global_rotation
		bullet.global_position = bullet_sample.global_position
	bullet.sender = Projectile.Sender.Tank

func _physics_process(delta: float) -> void:
	if status == Status.Dead or paused:
		return
	# Shoot at towers
	if is_instance_valid(enemy):
		if enemy.status == Tower.Status.Alive:
			timer_shoot -= delta
			timer_shoot_2 -= delta
			if timer_shoot <= 0:
				timer_shoot = shoot_timer
				var tg = enemy.hit_area.position+enemy.global_position# - Vector2(0,50)
				var dir = Vector2(tg - global_position).normalized()
				shoot(dir)
			if type == Type.BigRed:
				if timer_shoot_2 <= 0:
					timer_shoot_2 = shoot_timer
					var tg = enemy.hit_area.position+enemy.global_position# - Vector2(0,50)
					var dir = Vector2(tg - global_position).normalized()
					shoot(dir,true)
			
		else:
			enemy = null
	
	# Move toward path
	if target != OUT_OF_BOUNDS:
		direction = (target - body.global_position).normalized()
		var angle_to = body.transform.x.angle_to(direction) + deg_to_rad(initial_body_rotation)
		body.rotate(signf(angle_to) * 1 * min(delta * roation_speed, abs(angle_to)) )
		
		var rect = hit_area.shape.get_rect()
		rect.position += global_position
		if rect.has_point(target):
			arrived.emit(self)
	
		if direction.x:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		if direction.y:
			velocity.y = direction.y * speed
		else:
			velocity.y = move_toward(velocity.y, 0, speed)

	position += velocity * delta

func _process(delta: float) -> void:
	if status == Status.Dead or paused:
		return
	# Get an enemy to shoot at
	var rect = _range.shape.get_rect()
	rect.position += global_position
	if not is_instance_valid(enemy) or enemy.status == Tank.Status.Dead:
		for tower:Tower in get_tree().get_nodes_in_group("tower"):
			if rect.has_point(tower.hit_area.global_position) and tower.status == Tower.Status.Alive:
				enemy = tower
				
	# Check if the enemy is no more in range
	elif not rect.has_point(enemy.hit_area.global_position):
		enemy = null
	aim_at_enemy()
	

func take_damage(damage:float)->void:
	health -= damage

func _on_animation_sprite_animation_finished() -> void:
	if animation_sprite.animation == "explosion":
		dead.emit(self)
		hide()
		queue_free()
		
func aim_at_enemy()->void:
	if is_instance_valid(enemy) and enemy.status == Tower.Status.Alive:
		var tg = enemy.global_position
		var direction = (tg-barrel.global_position).normalized()
		var angle_to = barrel.transform.x.angle_to(direction) + deg_to_rad(initial_barrel_rotation)
		barrel.rotate( angle_to)
		if type == Type.BigRed:
			barrel_2.rotate( angle_to)
	else:
		barrel.rotation = body.rotation 
		if type == Type.BigRed:
			barrel_2.rotation = body.rotation 
			

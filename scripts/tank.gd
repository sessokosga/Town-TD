extends CharacterBody2D
class_name Tank

enum Status {Alive, Dead}
enum Type {Green, Red, Dark, Blue, Sand, BigRed, Huge, Large}
enum ShootMode {Single, Double}
enum ShootPos {First, Second, Third}

signal arrived(tank)
signal dead(tank)
signal out_of_screen(tank)

@onready var center :CollisionShape2D = $"%Center"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var _range :CollisionShape2D = $"%Range"
@onready var body :Sprite2D = $"%Body"
@onready var barrel :Sprite2D = $"%Barrel"
var barrel_2 :Sprite2D 
var barrel_3 :Sprite2D 
@onready var barrel_sample :Sprite2D = $"%BarrelSample"
var barrel_sample_2 :Sprite2D 
var barrel_sample_3 :Sprite2D 
@onready var bullet_sample :Sprite2D = $"%Bullet"
@onready var bullet_sample_2 :Sprite2D
@onready var bullet_sample_3 :Sprite2D
@onready var lab_health :Label = $"%Health"
@onready var animation :AnimationPlayer = $"%AnimationPlayer"
@onready var animation_sprite :AnimatedSprite2D = $"%AnimationSprite"

@export var initial_body_rotation:int
@export var initial_barrel_rotation:int
@export var type : Type :
	set(v):
		type = v
		if not is_instance_valid(lab_health):
			return
		init_tank()
		
var body_blue = preload("res://assets/images/Objects/tankBody_blue.png")
var barrel_blue = preload("res://assets/images/Objects/tankBlue_barrel2.png")
var bullet_blue = preload("res://assets/images/Objects/bulletBlue1.png")

var body_green = preload("res://assets/images/Objects/tankBody_green.png")
var barrel_green = preload("res://assets/images/Objects/tankGreen_barrel2.png")
var bullet_green = preload("res://assets/images/Objects/bulletGreen1.png")

var body_sand = preload("res://assets/images/Objects/tankBody_sand.png")
var barrel_sand = preload("res://assets/images/Objects/tankSand_barrel2.png")
var bullet_sand = preload("res://assets/images/Objects/bulletSand1.png")

var body_red = preload("res://assets/images/Objects/tankBody_red.png")
var barrel_red = preload("res://assets/images/Objects/tankRed_barrel2.png")
var bullet_red = preload("res://assets/images/Objects/bulletRed1.png")

var body_dark = preload("res://assets/images/Objects/tankBody_dark.png")
var barrel_dark = preload("res://assets/images/Objects/tankDark_barrel2.png")
var bullet_dark = preload("res://assets/images/Objects/bulletDark1.png")

var bullet_node 
var paused = false

const OUT_OF_BOUNDS = Vector2(-10000,-10000)

var direction = Vector2.ZERO
var roation_speed = 3
var barrel_rotation_speed = 10
var target : Vector2 = OUT_OF_BOUNDS :
	set(v):
		target = v
		if target == OUT_OF_BOUNDS:
			out_of_screen.emit(self)
			queue_free()

@export var speed = 300.0
@export var health :int:
	set(v):
		health = v
		if not is_instance_valid(lab_health):
			return
		lab_health.text = str(health)
		if health <= 0:
			health = 0
			status = Status.Dead
			match type:
				Type.BigRed:
					AudioPlayer.play_sfx(AudioPlayer.SFX.TankBigExplosion)
				Type.Huge:
					AudioPlayer.play_sfx(AudioPlayer.SFX.TankHugeExplosion)
				Type.Large:
					AudioPlayer.play_sfx(AudioPlayer.SFX.TankMedExplosion)
				_:
					AudioPlayer.play_sfx(AudioPlayer.SFX.TankNormalExplosion)
			barrel.hide()
			if is_instance_valid(barrel_2):
				barrel_2.hide()
			if is_instance_valid(barrel_3):
				barrel_3.hide()
				
			animation.play("explosion")
			animation_sprite.play("explosion")
		
var enemy :Tower = null
var shoot_timer = 1
var timer_shoot :float =0.1
var timer_shoot_2 :float =.6
var timer_shoot_3 :float =1.1
var status:Status
var bullet_texture : Texture2D

func init_tank()->void:
	lab_health.text = str(health)
	match type:
		Type.Blue:
			body.texture = body_blue
			barrel.texture = barrel_blue
			bullet_texture = bullet_blue
		Type.Red:
			body.texture = body_red
			barrel.texture = barrel_red
			bullet_texture = bullet_red
		Type.Sand:
			body.texture = body_sand
			barrel.texture = barrel_sand
			bullet_texture = bullet_sand
		Type.Green:
			body.texture = body_green
			barrel.texture = barrel_green
			bullet_texture = bullet_green
		Type.Dark:
			body.texture = body_dark
			barrel.texture = barrel_dark
			bullet_texture = bullet_dark

		var t when t == Type.BigRed or t == Type.Large:
			barrel_2 = $"%Barrel2"
			bullet_sample_2 = $"%Bullet2"
			barrel_sample_2 = $"%BarrelSample2"
			if type == Type.BigRed:
				bullet_texture = bullet_red
			else:
				bullet_texture = bullet_dark
				
		Type.Huge:
			barrel_2 = $"%Barrel2"
			bullet_sample_2 = $"%Bullet2"
			barrel_sample_2 = $"%BarrelSample2"
			barrel_3 = $"%Barrel3"
			bullet_sample_3 = $"%Bullet3"
			barrel_sample_3 = $"%BarrelSample3"
			bullet_texture = bullet_dark
			
			
	barrel_sample.texture = barrel.texture
		

func _ready() -> void:
	#health = 1
	init_tank()
	bullet_node = load("res://scenes/bullet.tscn")
	status = Status.Alive

func shoot(direction:Vector2,pos = ShootPos.First)->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TankShoot)
	var bullet : Projectile = bullet_node.instantiate()
	get_tree().root.add_child(bullet)
	bullet.direction = Vector2.ZERO
	#bullet.direction = direction
	bullet.texture = bullet_texture
	match pos:
		ShootPos.Third:
			bullet.global_rotation = bullet_sample_3.global_rotation
			bullet.global_position = bullet_sample_3.global_position
		ShootPos.Second:
			bullet.global_rotation = bullet_sample_2.global_rotation
			bullet.global_position = bullet_sample_2.global_position
		ShootPos.First:
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
			timer_shoot_3 -= delta
			if timer_shoot <= 0:
				timer_shoot = shoot_timer
				var tg = enemy.hit_area.position+enemy.global_position# - Vector2(0,50)
				var dir = Vector2(tg - global_position).normalized()
				shoot(dir)
				
			if type == Type.BigRed or type == Type.Huge or type == Type.Large :
				if timer_shoot_2 <= 0:
					timer_shoot_2 = shoot_timer
					var tg = enemy.hit_area.position+enemy.global_position# - Vector2(0,50)
					var dir = Vector2(tg - global_position).normalized()
					shoot(dir,ShootPos.Second)
					
			if type == Type.Huge:
				if timer_shoot_3 <= 0:
					timer_shoot_3 = shoot_timer
					var tg = enemy.hit_area.position+enemy.global_position# - Vector2(0,50)
					var dir = Vector2(tg - global_position).normalized()
					shoot(dir,ShootPos.Third)
			
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
		barrel.show()
		barrel_sample.hide()
		barrel.global_position = barrel_sample.global_position
		
		if type == Type.BigRed or type == Type.Huge or type == Type.Large:
			barrel_2.rotate( angle_to)
			barrel_2.show()
			barrel_sample_2.hide()
		
		if type == Type.Huge:
			barrel_3.rotate( angle_to)
			barrel_3.show()
			barrel_sample_3.hide()
	else:
		barrel.hide()
		barrel_sample.show()
		if type == Type.BigRed or type == Type.Huge or type == Type.Large:
			barrel_2.hide()
			barrel_sample_2.show()
		if type == Type.Huge:
			barrel_3.hide()
			barrel_sample_3.show()
			

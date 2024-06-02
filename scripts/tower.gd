extends Area2D
class_name Tower

enum Type {
	SingleCanon, DoubleCanon,
	OpenSingleMissile, OpenDoubleMissile,
	ClosedDoubleMissile
}

enum Status {Alive, Dead}
enum BulletType {Single, Double}
enum BulletGenre {Bullet, Missile}

var bullet_node = preload("res://scenes/bullet.tscn")
var big_missile_node = preload("res://scenes/big_missile.tscn")
var double_missile_node = preload("res://scenes/double_missile.tscn")
var bullet_tex = preload("res://assets/images/Objects/shotThin.png")
var tex_open_single_missile = preload("res://assets/images/Objects/towerDefense_tile206.png")

@onready var _range :CollisionShape2D = $"%Range"
@onready var hit_area :CollisionShape2D = $"%HitArea"
@onready var tower:Sprite2D = $"%Tower"
@onready var base:Sprite2D = $"%Base"
@onready var bullet_sample :Sprite2D = $"%Bullet"
@onready var bullet_sample_2 :Sprite2D = $"%Bullet2"
@onready var lab_health :Label = $"%Health"
@onready var animated_sprite :AnimatedSprite2D = $"%AnimatedSprite2D"
@onready var animation_player :AnimationPlayer = $"%AnimationPlayer"

var rotation_speed = 3
var target :Tank = null
var shoot_timer = 2
var timer_shoot :float =0
var timer_shoot_2 :float = 0.5
var status:Status
var paused = false
var occupied_place :TowerPlace
var projectile_node = null

@export var bullet_type : BulletType
@export var bullet_genre : BulletGenre
@export var type:Type:
	set(v):
		type = v
		if not is_instance_valid(tower):
			return

@export var health:int:
	set(v):
		health = v
		if not is_instance_valid(lab_health):
			return
		lab_health.text = str(health)
		if health <= 0:
			health = 0
			status = Status.Dead
			AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalExplosion)
			tower.hide()
			base.hide()
			animated_sprite.play("explosion")
			animation_player.play("explosion")
		
var max_health:int

func init_tower()->void:
	match type:
		var t when t == Type.SingleCanon or t == Type.DoubleCanon:
			projectile_node = bullet_node
		Type.OpenSingleMissile:
			projectile_node = big_missile_node
		var t when t == Type.OpenDoubleMissile or t == Type.ClosedDoubleMissile:
			projectile_node = double_missile_node
		
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#health = 10
	_range.show()
	init_tower()

func shoot(direction:Vector2,second_shoot = false)->void:
	if bullet_genre == BulletGenre.Missile:
		bullet_sample.hide()
		if bullet_type == BulletType.Double and second_shoot:
			bullet_sample_2.hide()
		
	var bullet : Projectile = projectile_node.instantiate()
	bullet.direction = direction
	add_child(bullet)
	if type == Type.SingleCanon or type == Type.DoubleCanon:
		bullet.texture = bullet_tex
		AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalShoot)
	else:
		AudioPlayer.play_sfx(AudioPlayer.SFX.TowerMissilelShoot)
		
	
	if type == Type.ClosedDoubleMissile:
		bullet.show_behind_parent = true
	
	if second_shoot:
		bullet.global_rotation = bullet_sample_2.global_rotation
		bullet.global_position = bullet_sample_2.global_position
	else:
		bullet.global_rotation = bullet_sample.global_rotation
		bullet.global_position = bullet_sample.global_position
	bullet.sender = Projectile.Sender.Tower
	
	get_tree().create_timer(.3).timeout.connect(
		func ():
			if bullet_genre == BulletGenre.Missile:
				bullet_sample.show()
				if bullet_type == BulletType.Double and second_shoot:
					bullet_sample_2.show()
	)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if status == Status.Dead or paused:
		return
		
	# Get a tank to shoot at
	var rect = _range.shape.get_rect()
	rect.position += global_position
	if not is_instance_valid(target) or target.status == Tank.Status.Dead:
		for tank:Tank in get_tree().get_nodes_in_group("tank"):
			if rect.has_point(tank.hit_area.global_position) and tank.status == Tank.Status.Alive:
				target = tank
				
	# Check if the target is no more in range
	elif not rect.has_point(target.hit_area.global_position):
		target = null
	#aim_at_enemy()
		
	if is_instance_valid(target) :
		timer_shoot -= delta
		if bullet_type == BulletType.Double:
			timer_shoot_2 -= delta
		if target.status == Tank.Status.Alive:
			# Aim at tank
			var enemy_pos = target.hit_area.position + target.global_position# - Vector2(150,0)
			var direction = (enemy_pos - global_position).normalized()
			var angle_to = tower.transform.y.angle_to(-direction)
			tower.rotate(angle_to)
			#tower.rotate(signf(angle_to) * -1 * min(delta * rotation_speed, abs(angle_to))) 
			
			# Shoot at tank
			if timer_shoot <= 0:
				timer_shoot = shoot_timer
				shoot(direction)
			if bullet_type == BulletType.Double:
				if timer_shoot_2 <= 0:
					timer_shoot_2 = shoot_timer
					shoot(direction,true)
		#else:
			#var angle_to = 0
			#tower.rotate(signf(angle_to) * -1 * min(delta * rotation_speed, abs(angle_to)))
		else:
			target = null 

func _on_body_entered(body: Node2D) -> void:
	#if body is Tank and body.status == Tank.Status.Alive:
		#target = body
	pass

func _on_body_exited(body: Node2D) -> void:
	#if body is Tank:
		#if body == target:
			#target = null
	pass
	
func take_damage(damage:float)->void:
	health -= damage

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "explosion":
		hide()
		queue_free()
		occupied_place.is_occupied = false

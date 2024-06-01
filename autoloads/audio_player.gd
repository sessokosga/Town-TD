extends Node

enum SFX{
	TankNormalExplosion,
	TankHugeExplosion,
	TankBigExplosion,
	TankMedExplosion,
	TankShoot,
	TowerNormalExplosion
}


enum Music{
}

@export var music_enabled = false :
	set(val):
		music_enabled = val
		if music_enabled:
			play_random_loop()
		else:
			stop_music_loop()

# UI

# Music

# SFX
const tank_normal_explosion = preload("res://assets/audio/sfx/tank/explosion_large_no_tail_03.wav")
const tank_huge_explosion = preload("res://assets/audio/sfx/tank/BigExplosion02.wav")
const tank_large_explosion = preload("res://assets/audio/sfx/tank/explosion_med_long_tail_01.wav")
const tank_big_explosion = preload("res://assets/audio/sfx/tank/Explosion 8.wav")
const tank_shoot = preload("res://assets/audio/sfx/tank/bullet_impact_ice_06.wav")
const tower_normal_explosion = preload("res://assets/audio/sfx/tower/DeepExplosion02.wav")

var current_music_loop_id : Music
var current_music_loop : AudioStreamPlayer = null

var diying_volume : float
var diying_music : AudioStreamPlayer 
var rising_music : AudioStreamPlayer 
var rising_volume : float

var played_loops =[]

func _ready() -> void:
	randomize()
	#if music_enabled:
		#play_music(Music.DeadWalking,true)

func play_sfx(id:SFX,looping=false)->bool:
	if music_enabled == false:
		return false
	var stream 
	match id:
		SFX.TankNormalExplosion:
			stream = tank_normal_explosion
		SFX.TankBigExplosion:
			stream = tank_big_explosion
		SFX.TankHugeExplosion:
			stream = tank_huge_explosion
		SFX.TankMedExplosion:
			stream = tank_large_explosion
		SFX.TankShoot:
			stream = tank_shoot
		SFX.TowerNormalExplosion:
			stream = tower_normal_explosion
		_:
			push_error("SFX ",id," not found")
			return false
			
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "SFX "
	add_child(asp)
	asp.play()
	
	asp.finished.connect(
		func()->void:
			if looping:
				asp.stream_paused = false
				asp.play()
			else:
				asp.queue_free()
			
			)
	return true

func play_random_loop():
	if music_enabled == false or is_instance_valid(current_music_loop) and current_music_loop.playing:
		return false
	#var id = randi() % Music.size()
	"""
	var trials = 0
	if played_loops.size() == Music.size():
		played_loops = []
	while played_loops.has(id) and trials < 100:
		id = randi() % Music.size()
		trials += 1
	played_loops.append(id)
	"""
	#current_music_loop = play_music(Music.DeadWalking)
	
func play_music(id:Music,looping = false)->AudioStreamPlayer:
	if music_enabled == false:
		return null
	var loop
	
	#match id:
		#Music.DeadWalking:
			#loop = dead_walking
		#_:
			#push_error("Music ",id," not found")
			#return null
	var asp = AudioStreamPlayer.new()
	asp.stream = loop
	#asp.volume_db = linear_to_db(0)
	asp.name = "Music Loop"
	add_child(asp)
	asp.play()
	#rising_music = asp
	asp.finished.connect(
		func():
			if looping:
				asp.stream_paused = false
				asp.play()
			else:
				play_random_loop()
	)
	return asp

func stop_music_loop()->bool:
	if current_music_loop.playing:
		diying_music = current_music_loop
		diying_volume = db_to_linear(diying_music.volume_db)
		return true
	return false
	

func _process(_delta: float) -> void:
	if is_instance_valid(diying_music):
		if diying_volume <= 0:
			diying_music.stop()
			remove_child(diying_music)
			diying_music.queue_free()
		else:
			diying_volume -= .01
			diying_music.volume_db = linear_to_db( diying_volume)
			
		
	
	if is_instance_valid(rising_music):
		if db_to_linear(rising_music.volume_db) < 1:
			rising_music.volume_db = linear_to_db( db_to_linear(rising_music.volume_db) + .008)
			if db_to_linear(rising_music.volume_db) >1:
				rising_music.volume_db = linear_to_db(1)

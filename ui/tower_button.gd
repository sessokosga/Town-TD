extends TextureButton
class_name TowerButton

signal toggled_it(tb)

@export var type : Tower.Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	toggled_it.emit(self)

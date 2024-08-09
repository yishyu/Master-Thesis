extends Area3D
class_name ARToggle

signal toggled(is_on)

@export var on : bool = false:
		set(value):
			on = value
			if is_inside_tree():
				_update_on()

@export var on_color: Color = Color(1.0, 0.0, 0.0)
@export var off_color: Color = Color(0.0, 1.0, 0.0)

var can_toggle : bool = true

func _update_on():
	var material : StandardMaterial3D = $MeshInstance3D.material_override
	if material:
		material.albedo_color = on_color if on else off_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if can_toggle:
		on = not on
		toggled.emit(on)
		can_toggle = false
		($Timer as Timer).start()


func _on_timer_timeout() -> void:
	can_toggle = true

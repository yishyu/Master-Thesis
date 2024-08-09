extends Node3D

@onready var pivot = $pivot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pivot.look_at(Globals.player_position)

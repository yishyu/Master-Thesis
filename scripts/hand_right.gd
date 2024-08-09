extends XRController3D
class_name RightHand

signal connection_creation(obj1: Node3D, obj2: Node3D)
signal switchdom

@onready var controller : XRController3D = XRHelpers.get_xr_controller(self)
@onready var pointer: XRToolsFunctionPointer = $Pointer
@onready var hand_menu = %HandMenu
@onready var connection_scene: PackedScene = preload("res://scenes/connection.tscn")


var selected_model: InstantiatedDevice = null
var last_target: Node = null

var current_connection: Connection = null

# Wether this hand is currently dominant
var dominant: bool = false :
    set(value):  # Ensure the laser is switched accordingly
        dominant = value
        pointer.enabled = dominant
        pointer.set_show_laser(XRToolsFunctionPointer.LaserShow.SHOW if dominant else XRToolsFunctionPointer.LaserShow.HIDE)


func _on_button_pressed(button: String):
    if selected_model != null:
        match button:
            "trigger_click":
                selected_model._on_placement()  # Placement logic
                selected_model = null  # Forget the reference to the selected model, locking it in place
            "by_button":
                selected_model.queue_free()  # Delete the selected model
                selected_model = null  # Forget the (now deprecated) reference to it
    elif is_instance_valid(pointer.last_target) and pointer.last_target is SelectionBall:
        if current_connection == null and button == "ax_button":
            current_connection = connection_scene.instantiate()
            get_tree().root.add_child(current_connection)
            current_connection.first_element = pointer.last_target
            current_connection.second_element = pointer
        elif button == "ax_button":
            # Connect the two objects together
            current_connection.second_element = pointer.last_target
            current_connection.placed = true
            current_connection = null  # Free the connection
        elif button == "by_button":
            current_connection.queue_free()
            current_connection = null

    if button == "trigger_click" and !dominant:  # Make the hand dominant
        switchdom.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if not is_instance_valid(last_target):
        last_target = null

    if selected_model != null:
        pointer.set_enabled(true)
        pointer.set_show_laser(XRToolsFunctionPointer.LaserShow.HIDE)
        if pointer.last_target != selected_model:
            selected_model.position = pointer.last_collided_at

    if is_instance_valid(pointer.last_target):
        last_target = pointer.last_target
    else:
        last_target = null

extends Node3D

@onready var environment : Environment = ($WorldEnvironment as WorldEnvironment).environment

var xr_interface: XRInterface

@export var max_scale: float = 5.0
@export var min_scale: float = 0.3

# The hand that currently has the pointer and all
@onready var dominant_hand: XRController3D = %rightHand
@onready var camera: XRCamera3D = %XRCamera3D

@onready var room_node: Node3D = %RoomContainer

@onready var room_instance_scene: PackedScene = preload("res://scenes/instances/room.tscn")
@onready var connection_scene: PackedScene = preload("res://scenes/connection.tscn")

const LEFT_HAND = 0
const RIGHT_HAND = 1

var picked_items: Array = [null, null]
var picked_initial_scale: Vector3 = Vector3.ZERO
var picked_initial_distance: float = 0

var ARState: bool = false

var instantiated_rooms: Dictionary = {}
var instantiated_links: Dictionary = {}


func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		# Turn off vsync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		get_viewport().use_xr = true
	else:
		print("Unable to find OpenXR interface")

	(%leftHand/Pointer as XRToolsFunctionPointer).enabled = false
	(%leftHand/Pointer as XRToolsFunctionPointer).set_show_laser(XRToolsFunctionPointer.LaserShow.HIDE)

	print("Connecting signal spawn_device: %b" % Globals.spawn_device.connect(_on_spawn_device))
	print("Connecting signal spawn_room: %b" % Globals.spawn_room.connect(_on_spawn_room))
	print("Connecting signal spawn_rule: %b" % Globals.spawn_rule.connect(_on_spawn_rule))
	print("Connecting signal delete_room: %b" % Globals.delete_room.connect(_on_delete_room))
	print("Connecting signal show_rules_from: %b" % Globals.show_rules_from.connect(_on_show_rules_from_device))
	print("Connecting signal hide_rules_from: %b" % Globals.hide_rules_from.connect(_on_hide_rules_from_device))
	print("Connecting signal room_rules_selected: %b" % Globals.room_rules_selected.connect(_on_room_rule_selected))


func _process(_delta):
	if picked_items[LEFT_HAND] == picked_items[RIGHT_HAND] and picked_items[LEFT_HAND] != null:
		if picked_initial_scale == Vector3.ZERO:
			picked_initial_scale = (picked_items[LEFT_HAND] as Node3D).find_child("RootPoint").scale
			picked_initial_distance = %leftHand.global_position.distance_to(%rightHand.global_position)

		var percent_distance_changed = %leftHand.global_position.distance_to(%rightHand.global_position) / picked_initial_distance
		var new_scale = min(max(min_scale, picked_initial_scale.x * percent_distance_changed), max_scale)
		(picked_items[LEFT_HAND] as Node3D).find_child("RootPoint").scale = Vector3(new_scale, new_scale, new_scale)
		(picked_items[LEFT_HAND] as Node3D).find_child("CollisionShape3D").scale = Vector3(new_scale, new_scale, new_scale)

	Globals.player_position = camera.global_position


func switch_to_ar() -> bool:
	if xr_interface:
		var modes = xr_interface.get_supported_environment_blend_modes()
		if XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
		elif XRInterface.XR_ENV_BLEND_MODE_ADDITIVE in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
		else:
			return false
	else:
		return false

	get_viewport().transparent_bg = true
	environment.background_mode = Environment.BG_CAMERA_FEED
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

	return true


func switch_to_vr() -> bool:
	if xr_interface:
		var modes = xr_interface.get_supported_environment_blend_modes()
		if XRInterface.XR_ENV_BLEND_MODE_OPAQUE in modes:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
		else:
			return false
	else:
		return false

	get_viewport().transparent_bg = false
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

	return true


func _on_right_hand_dom():
	dominant_hand = %rightHand
	(%leftHand as LeftHand).dominant = false
	(%rightHand as RightHand).dominant = true


func _on_left_hand_dom():
	dominant_hand = %leftHand
	(%rightHand as RightHand).dominant = false
	(%leftHand as LeftHand).dominant = true


func _on_left_hand_has_dropped() -> void:
	picked_items[LEFT_HAND] = null
	picked_initial_scale = Vector3.ZERO


func _on_right_hand_has_dropped() -> void:
	picked_items[RIGHT_HAND] = null
	picked_initial_scale = Vector3.ZERO


func _on_left_hand_has_picked_up(what: Variant) -> void:
	picked_items[LEFT_HAND] = what


func _on_right_hand_has_picked_up(what: Variant) -> void:
	picked_items[RIGHT_HAND] = what


func _on_left_hand_button_pressed(button: String) -> void:
	if button != "by_button":
		return

	ARState = not ARState
	if ARState:
		if !switch_to_ar():
			print("Unable to switch to AR")
	else:
		if !switch_to_vr():
			print("Unable to switch to VR")

	($XROrigin3D/leftHand/MovementDirect as XRToolsMovementDirect).enabled = !ARState
	($XROrigin3D/rightHand/MovementTurn as XRToolsMovementTurn).enabled = !ARState


func instantiate_room(room_info: Dictionary) -> Node3D:
	var iroom: Node3D = room_instance_scene.instantiate()
	var instantiated_room: InstantiatedRoom = iroom.find_children("Room", "InstantiatedRoom")[0]
	instantiated_room.object_file = load((room_info["path"] as String))
	instantiated_room.room_id = room_info["id"]
	instantiated_room.room_name = room_info["name"]
	iroom.name = room_info["name"]
	%RoomContainer.add_child(iroom)
	iroom.global_position = ($XROrigin3D/rightHand as Node3D).global_position + Vector3.UP * 0.2
	instantiated_rooms[room_info["id"]] = iroom

	return iroom


# Spawns a device
# @deprecated, only the rooms spawn now
func _on_spawn_device(room_info: Dictionary, device_id: int) -> void:
	if instantiated_rooms.has(room_info["id"]):
		instantiated_rooms[room_info["id"]].global_position = ($XROrigin3D/rightHand as Node3D).global_position + Vector3.UP * 0.2
		print("Room already instantiated %s (for device %d) moving it to the player" % [room_info["name"], device_id])
	else:
		var _iroom: Node3D = instantiate_room(room_info)
		print("'%s' instantiated, asking glow for device %d" % [room_info["name"], device_id])

	# TODO: Ask the room to light up device `device_id`
	# Problem, no actual way of knowing the actual instance, just go with the type (check path)

# Spawn a room given its information from the database
func _on_spawn_room(room_info: Dictionary) -> void:
	print("Attempting to spawn room %d" % room_info["id"])
	if instantiated_rooms.has(room_info["id"]):
		instantiated_rooms[room_info["id"]].global_position = ($XROrigin3D/rightHand as Node3D).global_position + Vector3.UP * 0.2
		print("Room already instantiated %s, moving it to the player" % room_info["name"])
	else:
		var _iroom: Node3D = instantiate_room(room_info)
		print("'%s' was instantiated" % room_info["name"])

# Spawns a rule given its information from the database.
# This is a two-step process, first spawn the room(s) associated
# with the concerned device(s), then spawn the actual rule.
func _on_spawn_rule(rule: Dictionary) -> void:
	if !instantiated_rooms.has(rule["from_room_id"]):
		var _iroom = instantiate_room({
			"name": rule["from_room_name"],
			"path": rule["from_room_path"],
			"id": rule["from_room_id"],
		})

	if !instantiated_rooms.has(rule["to_room_id"]):
		var _iroom = instantiate_room({
			"name": rule["to_room_name"],
			"path": rule["to_room_path"],
			"id": rule["to_room_id"],
		})

	# Defer the call
	_generate_rule.call_deferred(rule)

# This is the second step of the spawn rule method.
# This methods spawns the actual rule between the two devices
# that have been spawned in the first step.
func _generate_rule(rule: Dictionary):
	# Check that the rule is not already existing !
	if !instantiated_links.has(rule["id"]):
		# Otherwise, spawn it
		var first_device: InstantiatedDevice = (
			(
				instantiated_rooms[rule["from_room_id"]] as Node
			).find_children(
				"Room", "InstantiatedRoom")[0] as InstantiatedRoom
			).find_device_in_room(rule["from_device_path"] as String)
		var second_device: InstantiatedDevice = (
			(
				instantiated_rooms[rule["to_room_id"]] as Node
			).find_children(
				"Room", "InstantiatedRoom")[0] as InstantiatedRoom
			).find_device_in_room(rule["to_device_path"] as String)

		if first_device == null or second_device == null:
			print("A device is missing for the link to be created")
			return

		var connection: Connection = connection_scene.instantiate()
		connection.first_element = first_device.selectionBall
		connection.second_element = second_device.selectionBall
		connection.rule = rule
		%RoomContainer.add_child(connection)

		instantiated_links[rule["id"]] = connection

	# Select the object
	Globals.obj_selected.emit()
	(instantiated_links[rule["id"]] as Connection).selected = true


# When selected is true:
#   If the room selected is not instantiated,
#       instantiate it and then instantiate all the links that come or go from this room
#   If the room is instantiated,
#       do nothing or maybe highlight some stuff
# When selected is false
#   If the room is instantiated, hide the rules in it
#   Otherwise do nothing
func _on_room_rule_selected(room_id: int, selected: bool) -> void:
	if selected:  # Spawn the rules from this room
		for rule in Globals.get_rules_in_room(room_id):
			_on_spawn_rule((rule as Dictionary))


func _on_delete_room(room_id: int) -> void:
	print("Attempting to delete room %d" % room_id)
	if instantiated_rooms.has(room_id):
		(instantiated_rooms[room_id] as Node3D).queue_free()
		if instantiated_rooms.erase(room_id):
			print("Room %d deleted" % room_id)


func _on_show_rules_from_device(device_id: int):
	for rule in Globals.get_rules_to_or_from(device_id):
		if !instantiated_links.has(rule["id"]):
			_on_spawn_rule(rule as Dictionary)


func _on_hide_rules_from_device(device_id: int):
	for rule in Globals.get_rules_to_or_from(device_id):
		if instantiated_links.has(rule["id"]):
			if is_instance_valid(instantiated_links[rule["id"]]):
				(instantiated_links[rule["id"]] as Node3D).queue_free()
				if instantiated_links.erase(rule["id"]):
					print("Rule %d erased" % rule["id"])
			else:
				# Deprecated link, delete
				if instantiated_links.erase(rule["id"]):
					print("Cleaned deprecated link")

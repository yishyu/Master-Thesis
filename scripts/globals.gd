extends Node

# Emitted when an object (connection ball/rule link) is selected,
# To let other objects know that they should become deselected
signal obj_selected

# The room is a dictionary with information about the room (if spawn is needed)
# The device_id allows to identify the device within the room
signal spawn_device(room: Dictionary, device_id: int)

# Contains information about the room to spawn. Allows to avoid spawning the same room multiple times
signal spawn_room(room: Dictionary)

signal show_rules_from(room_id: int, device_path: int)
signal hide_rules_from(room_id: int, device_path: int)

# Contains the rule's information, might need to spawn multiple rooms, create a link between some objects in said room(s)
signal spawn_rule(rule: Dictionary)

# Emitted when a room is clicked from the rule menu in hand
signal room_rules_selected(room_id: int, selected: bool)

# Emitted when a room is hidden from the world
signal delete_room(room_id: int)


var player_position: Vector3 = Vector3.ZERO
var database: SQLite
var error: bool = false
var error_message: String = ""

func _ready():
    database = SQLite.new()
    database.path = "res://data.db"
    database.read_only = true  # Required for android (Or need to push the database to the userspace seems complicated)
    if database.open_db() != true:
        print("Failed to open database")
        error_message = database.error_message
        error = true


func get_rooms() -> Array:
    if error:
        return [{
            "id": 0,
            "name": error_message,
            "path": ""
        }]
    var result = database.select_rows("room", "", ["id", "name", "path"])
    return result


func get_room(room_id: int) -> Dictionary:
    if error or database.query_with_bindings("SELECT id, name, path FROM room WHERE id = ?", [room_id]) == false:
        print("An error occured while fetching room with id %d in database" % room_id)
        return {
            "id": 0,
            "name": error_message,
            "path": error_message
        }
    return database.query_result[0]


# Used when spawning a room to get a list of all rules applied in the currently instantiated rooms
func get_rules_in_rooms(room_ids: Array):
    if error:
        return [{
            "id": 0,
            "from_device_id": -1,
            "from_device_name": error_message,
            "from_device_path": error_message,
            "from_room_id": -1,
            "from_room_name": error_message,
            "from_room_path": error_message,
            "from_property_name": error_message,
            "from_property_value": error_message,
            "to_device_id": -1,
            "to_device_name": error_message,
            "to_device_path": error_message,
            "to_room_id": -1,
            "to_room_name": error_message,
            "to_room_path": error_message,
            "to_property_name": error_message,
            "to_property_value": error_message,
        }]

    var success = database.query_with_bindings("
    SELECT
        from_device_instance.id as from_device_id,
        from_device.id as from_device_id_non_instance,
        from_device.name as from_device_name,
        from_device.path as from_device_path,
        from_room.id as from_room_id,
        from_room.name as from_room_name,
        from_room.path as from_room_path,
        from_device_property.name as from_property_name,
        from_device_property_value as from_property_value,
        from_device_property_type.type as from_device_property_type,

        to_device_instance.id as to_device_id,
        to_device.id as to_device_id_non_instance,
        to_device.name as to_device_name,
        to_device.path as to_device_path,
        to_room.id as to_room_id,
        to_room.name as to_room_name,
        to_room.path as to_room_path,
        to_device_property.name as to_property_name,
        to_device_property_value as to_property_value,
        to_device_property_type.type as to_device_property_type
    from link
        -- From device information
        join device_instance as from_device_instance
            on link.from_device_id = from_device_instance.id
        join device as from_device
            on from_device_instance.device_id = from_device.id
        join room as from_room
            on from_device_instance.room_id = from_room.id
        -- From property information
        join device_instance_property as from_device_property_instance
            on link.from_device_property_id = from_device_property_instance.id
        join device_property as from_device_property
            on from_device_property_instance.property_id = from_device_property.id
        join property_value_type as from_device_property_type
            on from_device_property.property_type_id = from_device_property_type.id
        -- To device information
        join device_instance as to_device_instance
            on link.to_device_id = to_device_instance.id
        join device as to_device
            on to_device_instance.device_id = to_device.id
        join room as to_room
            on to_device_instance.room_id = to_room.id
        -- To property information
        join device_instance_property as to_device_property_instance
            on link.to_device_property_id = to_device_property_instance.id
        join device_property as to_device_property
            on to_device_property_instance.property_id = to_device_property.id
        join property_value_type as to_device_property_type
            on to_device_property.property_type_id = to_device_property_type.id
    where
        from_room_id in ? AND to_room_id in ?", [room_ids, room_ids])
    if !success:
        print("OHNO")
    return database.query_result


func get_rules_in_room(room_id: int):
    if error:
        return [{
            "id": 0,
            "from_device_id": -1,
            "from_device_name": error_message,
            "from_device_path": error_message,
            "from_room_id": -1,
            "from_room_name": error_message,
            "from_room_path": error_message,
            "from_property_name": error_message,
            "from_property_value": error_message,
            "to_device_id": -1,
            "to_device_name": error_message,
            "to_device_path": error_message,
            "to_room_id": -1,
            "to_room_name": error_message,
            "to_room_path": error_message,
            "to_property_name": error_message,
            "to_property_value": error_message,
        }]

    var success = database.query_with_bindings("
    SELECT
        link.id as id,
        from_device_instance.id as from_device_id,
        from_device.id as from_device_id_non_instance,
        from_device.name as from_device_name,
        from_device.path as from_device_path,
        from_room.id as from_room_id,
        from_room.name as from_room_name,
        from_room.path as from_room_path,
        from_device_property.name as from_property_name,
        from_device_property_value as from_property_value,
        from_device_property_type.type as from_device_property_type,

        to_device_instance.id as to_device_id,
        to_device.id as to_device_id_non_instance,
        to_device.name as to_device_name,
        to_device.path as to_device_path,
        to_room.id as to_room_id,
        to_room.name as to_room_name,
        to_room.path as to_room_path,
        to_device_property.name as to_property_name,
        to_device_property_value as to_property_value,
        to_device_property_type.type as to_device_property_type
    from link
        -- From device information
        join device_instance as from_device_instance
            on link.from_device_id = from_device_instance.id
        join device as from_device
            on from_device_instance.device_id = from_device.id
        join room as from_room
            on from_device_instance.room_id = from_room.id
        -- From property information
        join device_instance_property as from_device_property_instance
            on link.from_device_property_id = from_device_property_instance.id
        join device_property as from_device_property
            on from_device_property_instance.property_id = from_device_property.id
        join property_value_type as from_device_property_type
            on from_device_property.property_type_id = from_device_property_type.id
        -- To device information
        join device_instance as to_device_instance
            on link.to_device_id = to_device_instance.id
        join device as to_device
            on to_device_instance.device_id = to_device.id
        join room as to_room
            on to_device_instance.room_id = to_room.id
        -- To property information
        join device_instance_property as to_device_property_instance
            on link.to_device_property_id = to_device_property_instance.id
        join device_property as to_device_property
            on to_device_property_instance.property_id = to_device_property.id
        join property_value_type as to_device_property_type
            on to_device_property.property_type_id = to_device_property_type.id
    where
        from_room_id = ? OR to_room_id = ?", [room_id, room_id])
    if !success:
        print("OHNO")
    return database.query_result


# Used in the hand_menu to get a list of all the rules
func get_rules() -> Array:
    if error:
        return [{
            "id": 0,
            "from_device_id": -1,
            "from_device_name": error_message,
            "from_device_path": error_message,
            "from_room_id": -1,
            "from_room_name": error_message,
            "from_room_path": error_message,
            "from_property_name": error_message,
            "from_property_value": error_message,
            "to_device_id": -1,
            "to_device_name": error_message,
            "to_device_path": error_message,
            "to_room_id": -1,
            "to_room_name": error_message,
            "to_room_path": error_message,
            "to_property_name": error_message,
            "to_property_value": error_message,
        }]

    var success = database.query("
    SELECT
        from_device_instance.id as from_device_id,
        from_device.id as from_device_id_non_instance,
        from_device.name as from_device_name,
        from_device.path as from_device_path,
        from_room.id as from_room_id,
        from_room.name as from_room_name,
        from_room.path as from_room_path,
        from_device_property.name as from_property_name,
        from_device_property_value as from_property_value,
        from_device_property_type.type as from_device_property_type,

        to_device_instance.id as to_device_id,
        to_device.id as to_device_id_non_instance,
        to_device.name as to_device_name,
        to_device.path as to_device_path,
        to_room.id as to_room_id,
        to_room.name as to_room_name,
        to_room.path as to_room_path,
        to_device_property.name as to_property_name,
        to_device_property_value as to_property_value,
        to_device_property_type.type as to_device_property_type
    from link
        -- From device information
        join device_instance as from_device_instance
            on link.from_device_id = from_device_instance.id
        join device as from_device
            on from_device_instance.device_id = from_device.id
        join room as from_room
            on from_device_instance.room_id = from_room.id
        -- From property information
        join device_instance_property as from_device_property_instance
            on link.from_device_property_id = from_device_property_instance.id
        join device_property as from_device_property
            on from_device_property_instance.property_id = from_device_property.id
        join property_value_type as from_device_property_type
            on from_device_property.property_type_id = from_device_property_type.id
        -- To device information
        join device_instance as to_device_instance
            on link.to_device_id = to_device_instance.id
        join device as to_device
            on to_device_instance.device_id = to_device.id
        join room as to_room
            on to_device_instance.room_id = to_room.id
        -- To property information
        join device_instance_property as to_device_property_instance
            on link.to_device_property_id = to_device_property_instance.id
        join device_property as to_device_property
            on to_device_property_instance.property_id = to_device_property.id
        join property_value_type as to_device_property_type
            on to_device_property.property_type_id = to_device_property_type.id
    ")
    if !success:
        print("An error occured while getting rules")
    return database.query_result

func get_devices() -> Array:
    if error:
        return [{
            "id": 0,
            "d_name": error_message,
            "d_path": "",
            "r_name": error_message,
            "r_path": ""
        }]

    var success = database.query("select
        device_instance.id,
        device.name as d_name,
        device.path as d_path,
        room.id as r_id,
        room.name as r_name,
        room.path as r_path
    from device_instance
    join device on
        device_instance.device_id = device.id
    join room on
        device_instance.room_id = room.id
    order by room.id")
    if !success:
        print("Error executing device query")
    return database.query_result


func get_devices_in_room(room_id: int) -> Array:
    if error:
        return []
    
    var success = database.query_with_bindings("
        SELECT
            device_instance.id as id,
            device.path as path,
            device.name as name,
            device_instance.room_id as rid
        FROM
            device_instance
        join device
            on device.id = device_instance.device_id
        where
            device_instance.room_id = ?", [room_id]
    )
    if !success:
        print("Unable to fetch devices from room %d" % room_id)
        return []
    return database.query_result


# Returns a list of rules from or to a device instance
func get_rules_to_or_from(device_id: int) -> Array:
    if error:
        return [{
            "id": 0,
            "from_device_id": -1,
            "from_device_name": error_message,
            "from_device_path": error_message,
            "from_room_id": -1,
            "from_room_name": error_message,
            "from_room_path": error_message,
            "from_property_name": error_message,
            "from_property_value": error_message,
            "to_device_id": -1,
            "to_device_name": error_message,
            "to_device_path": error_message,
            "to_room_id": -1,
            "to_room_name": error_message,
            "to_room_path": error_message,
            "to_property_name": error_message,
            "to_property_value": error_message,
        }]

    var success = database.query_with_bindings("
    SELECT
        link.id as id,

        from_device_instance.id as from_device_id,
        from_device.id as from_device_id_non_instance,
        from_device.name as from_device_name,
        from_device.path as from_device_path,
        from_room.id as from_room_id,
        from_room.name as from_room_name,
        from_room.path as from_room_path,
        from_device_property.name as from_property_name,
        from_device_property_value as from_property_value,
        from_device_property_type.type as from_device_property_type,

        to_device_instance.id as to_device_id,
        to_device.id as to_device_id_non_instance,
        to_device.name as to_device_name,
        to_device.path as to_device_path,
        to_room.id as to_room_id,
        to_room.name as to_room_name,
        to_room.path as to_room_path,
        to_device_property.name as to_property_name,
        to_device_property_value as to_property_value,
        to_device_property_type.type as to_device_property_type
    from link
        -- From device information
        join device_instance as from_device_instance
            on link.from_device_id = from_device_instance.id
        join device as from_device
            on from_device_instance.device_id = from_device.id
        join room as from_room
            on from_device_instance.room_id = from_room.id
        -- From property information
        join device_instance_property as from_device_property_instance
            on link.from_device_property_id = from_device_property_instance.id
        join device_property as from_device_property
            on from_device_property_instance.property_id = from_device_property.id
        join property_value_type as from_device_property_type
            on from_device_property.property_type_id = from_device_property_type.id
        -- To device information
        join device_instance as to_device_instance
            on link.to_device_id = to_device_instance.id
        join device as to_device
            on to_device_instance.device_id = to_device.id
        join room as to_room
            on to_device_instance.room_id = to_room.id
        -- To property information
        join device_instance_property as to_device_property_instance
            on link.to_device_property_id = to_device_property_instance.id
        join device_property as to_device_property
            on to_device_property_instance.property_id = to_device_property.id
        join property_value_type as to_device_property_type
            on to_device_property.property_type_id = to_device_property_type.id
    WHERE
        from_device_instance.id = ? OR
        to_device_instance.id = ?
    ", [device_id, device_id])
    if !success:
        print("An error occured while getting rules")
    return database.query_result


# Returns the list of properties on a device
func get_device_properties(device_id: int) -> Array:
    var success = database.query_with_bindings("
        SELECT * from device_property
        WHERE device_id = ?
    ", [device_id])
    if !success:
        return []
    return database.query_result

SELECT
	from_device_instance.id as from_device_id,
	from_device.name as from_device_name,
	from_device.file_path as from_device_path,
	from_room.id as from_room_id,
	from_room.name as from_room_name,
	from_room.file_path as from_room_path,
	from_device_property.name as from_property_name,
	from_device_property_value as from_property_value,

	to_device_instance.id as to_device_id,
	to_device.name as to_device_name,
	to_device.file_path as to_device_path,
	to_room.id as to_room_id,
	to_room.name as to_room_name,
	to_room.file_path as to_room_path,
	to_device_property.name as to_property_name,
	to_device_property_value as to_property_value	
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
        on to_device_property.property_type_id = to_device_property_type.id;
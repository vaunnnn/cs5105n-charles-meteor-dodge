extends SceneTree
# Run with: godot --headless --path . --script tools/build_arenas.gd
# Original 32px pixel tiles; no downloads or third-party assets.

func _initialize() -> void:
	var image := Image.create(192, 32, false, Image.FORMAT_RGBA8)
	var colors := [Color("142c40"), Color("392443"), Color("52677d"),
		Color("d85b37"), Color("235d60"), Color("60394f")]
	for tile in range(6):
		for y in range(32):
			for x in range(32):
				var color: Color = colors[tile]
				if x == 0 or y == 0:
					color = color.lightened(0.16)
				if tile == 2 and (x == 4 or y == 4 or x == 27 or y == 27):
					color = Color("a2b7ce")
				if tile == 3:
					if (x + y) % 12 < 4:
						color = Color("512c28")
					if absi(x - y) < 2 or absi(x + y - 31) < 2:
						color = Color("ffe294")
				if tile >= 4 and (y == 14 or y == 17) and x > 8 and x < 24:
					color = Color("97e8df")
				image.set_pixel(tile * 32 + x, y, color)
	var texture := ImageTexture.create_from_image(image)
	ResourceSaver.save(texture, "res://assets/arena_tiles.tres")
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32, 32)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(0, 1)
	tiles.add_custom_data_layer()
	tiles.set_custom_data_layer_name(0, "hazard")
	tiles.set_custom_data_layer_type(0, TYPE_BOOL)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/arena_tiles.tres")
	source.texture_region_size = Vector2i(32, 32)
	tiles.add_source(source, 0)
	for index in range(6):
		var coord := Vector2i(index, 0)
		source.create_tile(coord)
		var data := source.get_tile_data(coord, 0)
		# Show space through floors, the movement row, and outer walls.
		if index in [0, 1, 2, 4, 5]:
			data.modulate = Color(1, 1, 1, 0)
		if index == 2:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([
				Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]))
		if index == 3:
			data.set_custom_data("hazard", true)
	ResourceSaver.save(tiles, "res://assets/arena_tileset.tres")
	for number in [1, 2]:
		var root := Node2D.new()
		root.name = "ArenaRoot"
		var layer := TileMapLayer.new()
		layer.name = "Arena"
		layer.tile_set = load("res://assets/arena_tileset.tres")
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.z_index = -1
		root.add_child(layer)
		layer.owner = root
		for y in range(4, 18):
			for x in range(30):
				var tile := 0 if number == 1 else 1
				if y == 16:
					tile = 4 if number == 1 else 5
				if x == 0 or x == 29 or y == 4 or y == 17:
					tile = 2
				elif number == 2 and (x == 1 or x == 28):
					tile = 3
				layer.set_cell(Vector2i(x, y), 0, Vector2i(tile, 0))
		# Save a layer scene with painted cells, directly editable in Godot.
		root.remove_child(layer)
		var packed := PackedScene.new()
		packed.pack(layer)
		ResourceSaver.save(packed, "res://assets/arena_%d.tscn" % number)
		layer.free()
		root.free()
	quit()

class_name ThreeWayAnimatedsprite2D
extends AnimatedSprite2D

const _SUFFIXES := [
	["side", 0],
	["down", 1],
	["up", 2]
]

@export var sprite_texture_overrides: SpriteTextureOverrides

# TODO: Make this a toolscript that can bake these animations into the sprite frames
func _ready() -> void:
	_override_animations()
	
func _override_animations() -> void:
	if sprite_texture_overrides == null && OS.is_debug_build():
		push_warning("Missing animation overrides")
		return
		
	for animation_name in sprite_texture_overrides.overrides:
		var sprite_texture = sprite_texture_overrides.overrides[animation_name]
		
		# Each animation should have three directions, suffixed with side, up, and down
		for suffix_row in _SUFFIXES:
			var suffix = suffix_row[0]
			var row = suffix_row[1]
			
			var animation_to_override = "%s_%s" % [animation_name.to_lower(), suffix]
			
			# If we don't have that animation, we don't care about it
			if !sprite_frames.has_animation(animation_to_override):
				continue
			
			var frame_texture = sprite_frames.get_frame_texture(animation_to_override, 0)
			
			var frame_count = sprite_frames.get_frame_count(animation_to_override)
			var frame_width = frame_texture.get_width()
			var frame_height = frame_texture.get_height()
			
			# For each frame in the original sprite frames, replace with a new frame
			for i in range(0, frame_count):
				var atlas_texture = AtlasTexture.new()
				atlas_texture.atlas = sprite_texture
				var region = Rect2(
					frame_width * i,
					frame_height * row,
					frame_width,
					frame_height
				)
				atlas_texture.region = region
				
				sprite_frames.set_frame(animation_to_override, i, atlas_texture)

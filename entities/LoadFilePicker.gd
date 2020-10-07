extends FileDialog

var save_data: Dictionary

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	self.connect("file_selected", self, "_on_file_selected")
	
	var screen_middle: Vector2 = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
	self.set_global_position(screen_middle)
	self.rect_size = screen_middle
	popup_centered(screen_middle)
	
	self.connect("popup_hide", self, "_on_popup_hide")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_file_selected(path: String) -> void:
	"""
	Each dialogue file should consist of a single line of data. This line is
	a compacted JSON data.
	"""
	var save_file: File = File.new()
	save_file.open(path, File.READ)
	
	save_data = parse_json(save_file.get_line())
	
	save_file.close()

func _on_popup_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################



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

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_file_selected(path: String) -> void:
	var save_file: File = File.new()
	save_file.open(path, File.WRITE)
	
	save_file.store_line(to_json(save_data))
	save_file.close()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################



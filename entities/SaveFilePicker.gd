extends FileDialog

var save_confirmation: Resource = preload("res://entities/SaveConfirmation.tscn")

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
	var save_file: File = File.new()
	save_file.open(path, File.WRITE)
	
	save_file.store_line(to_json(save_data))
	save_file.close()
	
	var save_confirmation_instance: AcceptDialog = save_confirmation.instance()
	save_confirmation_instance.dialog_text = "File saved at " + path
	get_parent().add_child(save_confirmation_instance)
	
	self.queue_free()

func _on_popup_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################



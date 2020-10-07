extends AcceptDialog

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	self.connect("confirmed", self, "_on_confirmed")
	
	popup_centered()
	
	self.connect("popup_hide", self, "_on_popup_hide")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_confirmed() -> void:
	queue_free()

func _on_popup_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################


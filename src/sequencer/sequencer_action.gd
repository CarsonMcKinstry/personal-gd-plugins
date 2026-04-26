class_name SequencerAction
extends RefCounted

signal handled

func finished() -> void:
	handled.emit()

func _execute(context: SequencerContext) -> void:
	if OS.is_debug_build():
		push_warning("Execute not implemented for %s" % get_script().get_path())
	finished()
	
func _on_canceled() -> void:
	pass
	
func _on_unhandled_input(event: InputEvent) -> void:
	pass

func _on_input(event: InputEvent) -> void:
	pass
	
func _on_process(delta: float) -> void:
	pass
	
func _on_process_physics(delta: float) -> void:
	pass

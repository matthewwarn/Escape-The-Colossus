extends Node2D

enum UnlockCondition {
	CORE_ONE,
	CORE_TWO,
	NEVER,
}

## Remove self after this miniboss is defeated.
@export
var unlock_after: UnlockCondition;

## Attach signal here to remove immediately after a miniboss is defeated
func _on_heart_core_defeated() -> void:
	self.queue_free();


## If the selected core has been defeated then remove this barrier while loading level.
func _ready() -> void:
	match unlock_after:
		UnlockCondition.CORE_ONE:
			if Global.core_one_defeated:
				self.queue_free();
		UnlockCondition.CORE_TWO:
			if Global.core_two_defeated:
				self.queue_free();

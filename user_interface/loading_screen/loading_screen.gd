extends Control

@onready var counter: Label = $Counter
var progress: Array = []
var sceneName: String
var scene_load_status: int = 0
var uids: scene_uid

func _ready() -> void:
	sceneName = uids.LEVEL
	ResourceLoader.load_threaded_request(sceneName)

func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	counter.text = str(floor(progress[0]*100)) + "%"
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene: PackedScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)

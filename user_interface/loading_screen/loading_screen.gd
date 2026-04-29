extends CanvasLayer

@onready var counter: Label = $Counter
var progress: Array = []
var sceneName: String
var scene_load_status: int = 0
var uids: scene_uid

var total_chunks: int = 0

func _ready() -> void:
	sceneName = uids.LEVEL
	ResourceLoader.load_threaded_request(sceneName)

func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	
	#Resource Loading
	if scene_load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		counter.text = "Loading Files " + str(floor(progress[0]*100)) + "%"
	
	#Map Generation Loading
	elif scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false) 
		
		var newScene: PackedScene = ResourceLoader.load_threaded_get(sceneName)
		var level_instance: Node = newScene.instantiate()
		
		var map_gen: MapGenerator = level_instance.get_node("MapGenerator")
		
		#Signal connection
		map_gen.total_rooms.connect(_on_total_rooms)
		map_gen.chunk_loaded.connect(_on_chunk_loaded)
		map_gen.map_fully_generated.connect(_on_map_fully_generated)
		
		#Adds main scene to begin the map generation on the background 
		# ( generation is obviously still done in the main thread!! )
		get_tree().root.add_child(level_instance)
		get_tree().current_scene = level_instance

#Gives us the amount of rooms are inside of the object pool
func _on_total_rooms(total: int) -> void:
	total_chunks = total

#Runs everytime we instantiate a room
func _on_chunk_loaded(current: int) -> void:
	var percent: float = (float(current) / float(total_chunks)) * 100.0
	counter.text = "Generating Map " + str(floor(percent)) + "%"

#Runs when everything is finished
func _on_map_fully_generated() -> void:
	queue_free()

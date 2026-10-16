extends SceneTree

const MissionDriver = preload("res://tests/mission_driver.gd")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("This mouse-input traversal requires a graphical backend; use gameplay_contract.gd for headless rules.")
		quit(2)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var driver := MissionDriver.new()
	root.add_child(driver)
	driver.begin(game)
	var result: Dictionary = await driver.completed
	print("INPUT_RUN_RESULT ", JSON.stringify(result))
	var args := OS.get_cmdline_user_args()
	if args.size() == 1:
		var report := FileAccess.open(args[0], FileAccess.WRITE)
		if report == null:
			push_error("Cannot save traversal evidence")
			quit(1)
			return
		report.store_string(JSON.stringify(result, "\t"))
		report.close()
	driver.queue_free()
	game.queue_free()
	await process_frame
	quit.call_deferred(0 if result.pass else 1)

extends Node

@onready var node := Node.new()

var assertions: int
var assertions_failed: int
var tests_run: int
var tests_failed: int

func run_tests() -> void:
	if not OS.is_debug_build():
		print("Not running tests in release build")
		return
	
	var dir := DirAccess.open("res://tests")
	if not dir:
		printerr("Failed to open test directory")
		return
	
	tests_run = 0
	tests_failed = 0
	
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		run_test_script(file)
		file = dir.get_next()
	dir.list_dir_end()
	
	print("")
	if tests_failed > 0:
		printerr("%d / %d Tests Failed" % [tests_failed, tests_run])
	else:
		print("All %d Tests Passed" % tests_run)


func run_test_script(file: String) -> void:
	if file == "." or file == ".." or file == "Test.gd" or file == "assets":
		return
	
	node.set_script(load("res://tests/" + file))
	node.tree = get_tree()
	node.main = node.tree.current_scene
	
	for method in node.get_method_list():
		if method.name.begins_with("test_"):
			print("Running test: %s -> %s" % [file, method.name])
			run_test(method.name)

func run_test(method: String) -> void:
	assertions = 0
	assertions_failed = 0
	
	node.call(method)
	
	tests_run += 1
	
	if assertions == 0:
		printerr("No assertions made")
		tests_failed += 1
	elif assertions_failed > 0:
		tests_failed += 1

func assertion_made(passed: bool) -> void:
	assertions += 1
	if not passed:
		assertions_failed += 1


func assertion_passed() -> void:
	assertion_made(true)
	assertions += 1


func assertion_failed(error: String) -> void:
	printerr(error)
	assertions += 1
	assertions_failed += 1

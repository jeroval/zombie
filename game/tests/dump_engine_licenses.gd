extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("License dump requires one output path")
		quit(2)
		return
	var lines := PackedStringArray([
		"GODOT ENGINE AND THIRD-PARTY COPYRIGHT NOTICES",
		"Generated from " + Engine.get_version_info().string,
		"",
		"GODOT ENGINE LICENSE",
		Engine.get_license_text(),
		"",
		"THIRD-PARTY COMPONENT COPYRIGHTS",
	])
	for component in Engine.get_copyright_info():
		lines.append("")
		lines.append(str(component.get("name", "Unnamed component")))
		for part in component.get("parts", []):
			var files: Array = part.get("files", [])
			var copyrights: Array = part.get("copyright", [])
			lines.append("Files: " + ", ".join(files))
			lines.append("Copyright: " + " | ".join(copyrights))
			lines.append("License: " + str(part.get("license", "UNKNOWN")))
	lines.append("")
	lines.append("LICENSE TEXTS FOR THIRD-PARTY COMPONENTS")
	var license_info: Dictionary = Engine.get_license_info()
	var names: Array = license_info.keys()
	names.sort()
	for license_name in names:
		lines.append("")
		lines.append("===== " + str(license_name) + " =====")
		lines.append(str(license_info[license_name]))
	var output := FileAccess.open(args[0], FileAccess.WRITE)
	if output == null:
		push_error("Cannot write Godot license notice")
		quit(1)
		return
	output.store_string("\n".join(lines) + "\n")
	output.close()
	print("ENGINE_LICENSE_DUMP_PASS components=", Engine.get_copyright_info().size(), " licenses=", names.size())
	quit(0)

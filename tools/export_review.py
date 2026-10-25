"""Build the browser review fixture, restoring production settings even on failure."""
from pathlib import Path
import os
import subprocess

root = Path(__file__).resolve().parent.parent
project = root / "project.godot"
presets = root / "export_presets.cfg"
original_project = project.read_text()
original_presets = presets.read_text()
engine = os.environ.get("GODOT_BIN", "godot")
try:
    project.write_text(original_project.replace("res://scenes/main.tscn", "res://tests/polish_capture.tscn"))
    presets.write_text(original_presets.replace("tests/*,", ""))
    (root / "build/web").mkdir(parents=True, exist_ok=True)
    for arguments in [["--import"], ["--export-release", "Web", "build/web/index.html"]]:
        subprocess.run([engine, "--headless", "--path", str(root), *arguments], check=True)
finally:
    project.write_text(original_project)
    presets.write_text(original_presets)

"""Publish the complete Slides Extended bundle after Quarto has rendered."""

import os
from pathlib import Path
import shutil


project = Path(__file__).resolve().parents[1]
tutorial = "colliders-entomology-tutorial"
source = project / "_tutorials" / tutorial

required = (
    "index.html",
    "assets/storyline/splashscreen.png",
    "export/colliders_entomology_EN/index.html",
    "export/colliders_entomology_FR/index.html",
)
missing = [path for path in required if not (source / path).is_file()]
if missing:
    raise SystemExit("Incomplete tutorial bundle: " + ", ".join(missing))

# Quarto supplies the configured output directory, including profile overrides.
output = Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "_site"))
if not output.is_absolute():
    output = project / output
destination = output / "resources" / tutorial

# Replace only this tutorial's output so removed upstream assets cannot linger.
if destination.exists():
    shutil.rmtree(destination)
shutil.copytree(source, destination)
if os.environ.get("QUARTO_PROJECT_SCRIPT_QUIET") != "1":
    print(f"Published tutorial: {destination}")

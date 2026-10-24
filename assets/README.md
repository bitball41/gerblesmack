# Gatefold artwork and sound

Active Relic illustrations are original 64px drawings in `plates/`, with editable pixel shapes and palettes in `tools/build_relic_plates.py`. The same source draws the 80x100 board portraits. It uses no image-generation model output. Small pictograms remain in `pixel/`; the bitmap alphabet remains in `fonts/pixel.fnt`. Textures use nearest sampling.

The ivory print framing, dark ink, upper-left highlights, muted card palettes, and quiet teal table form the shared style. Original catalog names, colors, and rules are retained. The older SVGs and Nimbus fonts remain reference material excluded from the Web export.

`audio/` contains original PCM effects built by `tools/build_sound_assets.py`: filtered noise for paper, damped resonators for wood and bronze, and short struck chords for milestones. No audio or imagery from the reference games is included.

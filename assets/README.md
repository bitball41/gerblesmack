# Gatefold artwork and sound

Active Relic illustrations are original 64px drawings in `plates/`, with editable pixel shapes and palettes in `tools/build_relic_plates.py`. The same source draws the 80x100 board portraits. It uses no image-generation model output. Small pictograms remain in `pixel/`; the bitmap alphabet remains in `fonts/pixel.fnt`. Textures use nearest sampling.

The ivory print framing, dark ink, upper-left highlights, muted card palettes, and quiet teal table form the shared style. Original catalog names, colors, and rules are retained. The older SVGs and Nimbus fonts remain reference material excluded from the Web export.

`audio/` contains original PCM effects built by `tools/build_sound_assets.py`: filtered noise for paper, damped resonators for wood and bronze, and short struck chords for milestones. No audio or imagery from the reference games is included.

## Typography provenance

`type/PixelOperator.ttf` and `type/PixelOperator-Bold.ttf` are Pixel Operator by Jayvee Enaguas (HarvettFox96), licensed CC0 1.0. The original license is in `type/LICENSE.txt`. Source listing: https://www.dafont.com/pixel-operator.font ; creator repository: https://notabug.org/HarvettFox96/ttf-pixeloperator . The earlier homemade bitmap font remains for provenance but is no longer the interface default.

The active interface uses **m6x11plus by Daniel Linssen**, downloaded from the creator: https://managore.itch.io/m6x11 . Permission is "Free to use with attribution," both on that page and in the font's license metadata. See `type/m6x11plus-NOTICE.txt`; an attribution is also visible in Options. Pixel Operator remains as an earlier unused asset.

Shop objects (`plates/shop_sign.png`, `supply_pack.png`, and `voucher_*.png`) are manually specified pixel shapes in `tools/build_shop_art.py`, with the licensed m6x11plus font and existing upgrade pictograms. No image-generation model is used.


Fracture Relics, upgrade pictograms, 15 Fractures, 10 board portraits, and 15 typed/size pack wrappers are manually specified in `tools/build_fracture_art.py`. It writes original Pillow pixel geometry; it does not call an image model. `tools/build_shop_art.py` includes voucher art for all 30 permanent upgrades. The new catalog keeps an individual card palette for every Relic and selects a contrasting ink color.

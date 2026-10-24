# Gatefold artwork

The active game uses the original pixel drawings in `pixel/` and the original bitmap font in `fonts/pixel.fnt` with its atlas. Their editable source is `tools/build_pixel_assets.py`: 32px illustration grids, fifteen distinct 80x100 board portraits, and a hand-authored 5x7 alphabet. Raster assets are generated without antialiasing and sampled with nearest filtering. The title, cards, board, tiles, enhancements, icons, shop, collection, menus, and loading mark use this system.

Card colors and descriptions retain the supplied `Gatefold (6)(1).html` reference. The older SVGs and extracted Nimbus TTFs remain as source reference, with their embedded metadata and notices, and are excluded from the Web build.

The background is a native shader with a fixed pixel grid, a stepped palette, subtle dithering, and a warmer shop state. Tiles and frames use hard pixel edges and small bevels. Coin/card flights, score effects, and gate banners are transient Godot nodes. Sound uses an original short, quantized oscillator; no audio clips from the reference games are included.

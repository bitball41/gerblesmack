# Original Gatefold artwork

The three embedded fonts and the line illustrations were extracted from the supplied `Gatefold (6)(1).html` reference. Card colors and short descriptions are retained in `ui/visual_catalog.gd`.

SVGs retain the original paths. Hatch-pattern fills were simplified to a translucent solid fill for Godot's SVG importer. White source strokes are tinted by each card's original ink color at runtime. The app icon uses the same gate illustration.

Font files retain their embedded name and copyright metadata. They are Nimbus Sans Narrow (display), Nimbus Sans (body), and Nimbus Sans Bold (body emphasis), converted from the original WOFF payloads to TTF for engine import.

The background is a lightweight native shader. Tiles, card frames, button depth, and transient feedback are drawn or animated by Godot.

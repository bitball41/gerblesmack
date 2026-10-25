#!/usr/bin/env python3
"""Give each game pack a content-addressed URL to prevent stale browser assets."""
from pathlib import Path
import hashlib
import base64
import json
import re
import sys

folder = Path(sys.argv[1] if len(sys.argv) > 1 else 'build/web')
html_path = folder / 'index.html'
html = html_path.read_text()
match = re.search(r'const GODOT_CONFIG = (\{[^\n]+\});', html)
if not match:
    raise SystemExit('Godot export config was not found; leaving the export unchanged.')
config = json.loads(match.group(1))
old_name = config.get('mainPack') or config['executable'] + '.pck'
pack = folder / old_name
if not pack.is_file():
    raise SystemExit('Main pack does not exist: ' + old_name)
new_name = 'gatefold.' + hashlib.sha256(pack.read_bytes()).hexdigest()[:16] + '.pck'
new_path = folder / new_name
if new_name != old_name:
    pack.replace(new_path)
config['mainPack'] = new_name
sizes = config.setdefault('fileSizes', {})
sizes.pop(old_name, None)
sizes[new_name] = new_path.stat().st_size
html = html[:match.start(1)] + json.dumps(config, separators=(',', ':')) + html[match.end(1):]
logo = Path(__file__).resolve().parents[1] / 'assets/pixel/logo.png'
if logo.is_file():
    uri = 'data:image/png;base64,' + base64.b64encode(logo.read_bytes()).decode()
    style = '<style id="gatefold-pixel-loader">#status{background:#172e36!important}#status::before{content:""!important;display:block;width:392px;height:96px;background:url(' + uri + ') center/contain no-repeat;image-rendering:pixelated}#status-progress{border-radius:5px!important;border:2px solid #d5b46d;height:12px!important}#status-notice{font-family:monospace}</style>'
    html = re.sub(r'<style id="gatefold-pixel-loader">.*?</style>', '', html)
    html = html.replace('</head>', style + '</head>')
html_path.write_text(html)
(folder / '.nojekyll').touch()
print('Prepared Web build:', new_name)

#!/usr/bin/env python3
"""Editable pixel shop objects. Explicit shapes and an existing licensed font; no image models."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/plates'; OUT.mkdir(exist_ok=True)
FONT=ROOT/'assets/type/m6x11plus.ttf'
INK='#1d2d35'; PAPER='#f4e5bb'; LIGHT='#fff4d2'; GOLD='#d7a04c'; TEAL='#569b96'
def canvas(size):
 im=Image.new('RGBA',size,(0,0,0,0)); d=ImageDraw.Draw(im); d.fontmode='1'; return im,d
def text(d,xy,s,size,color,center=False):
 f=ImageFont.truetype(str(FONT),size); b=d.textbbox((0,0),s,font=f)
 x,y=xy
 if center:x-=d.textlength(s,font=f)/2
 d.text((round(x),round(y-b[1])),s,font=f,fill=color)
# Hanging shop sign: warm painted wood, two hangers, top-left lighting.
im,d=canvas((96,48))
for x in [24,72]:
 d.rectangle((x-2,0,x+2,15),fill=INK)
 d.rectangle((x-1,1,x,13),fill='#8ca6a0')
d.rectangle((6,13,91,46),fill=INK)
d.polygon([(7,11),(88,11),(92,15),(92,40),(88,44),(7,44),(3,40),(3,15)],fill=INK)
d.polygon([(8,13),(87,13),(90,16),(90,38),(87,41),(8,41),(5,38),(5,16)],fill='#866242')
d.line((9,14,85,14),fill='#e5b76f',width=2)
d.line((6,17,6,36),fill='#bc925d')
d.line((9,40,86,40),fill='#493e35',width=2)
d.line((89,18,89,37),fill='#594637')
for x in [11,84]:
 d.rectangle((x,17,x+2,19),fill=GOLD)
 d.rectangle((x,35,x+2,37),fill='#4e4033')
text(d,(49,20),'SHOP',27,INK,True);text(d,(48,19),'SHOP',27,LIGHT,True)
im.save(OUT/'shop_sign.png')
# Foil pack: crimped edges and a three-card mystery emblem.
im,d=canvas((64,64))
d.polygon([(9,2),(54,2),(57,6),(57,58),(53,62),(10,62),(6,58),(6,6)],fill=INK)
d.rectangle((9,6,54,57),fill='#75608f')
d.rectangle((10,10,14,54),fill='#a88ac3')
d.rectangle((50,10,54,56),fill='#4f405f')
d.polygon([(14,11),(22,11),(17,52),(14,52)],fill='#8f73a8')
for x in range(10,54,4):
 d.rectangle((x,3,x+1,8),fill=GOLD)
 d.rectangle((x,57,x+1,60),fill='#a78c57')
d.line((10,10,53,10),fill='#d9bc82');d.line((10,55,53,55),fill='#453a55')
text(d,(32,14),'SUPPLY',18,LIGHT,True)
# Offset cards are large, joined clusters, not decorative noise.
d.polygon([(15,32),(30,29),(36,48),(20,52)],fill=INK)
d.polygon([(17,33),(29,31),(33,47),(21,49)],fill=GOLD)
d.polygon([(34,29),(49,32),(45,52),(30,48)],fill=INK)
d.polygon([(35,31),(47,33),(43,49),(32,47)],fill=TEAL)
d.rectangle((23,28,41,52),fill=INK);d.rectangle((25,30,39,50),fill=PAPER)
text(d,(32,33),'?',18,INK,True)
im.save(OUT/'supply_pack.png')
# Each upgrade has its own paper coupon, using its existing unframed pictogram.
source=(ROOT/'scripts/catalog.gd').read_text()
upgrades=json.loads(source.split('const UPGRADES = ',1)[1].split('\nconst BOARDS',1)[0])
for ident,data in upgrades.items():
 im,d=canvas((80,56))
 d.polygon([(7,4),(72,4),(76,8),(76,46),(72,50),(7,50),(3,46),(3,8)],fill=INK)
 d.polygon([(8,6),(71,6),(74,9),(74,44),(71,47),(8,47),(5,44),(5,9)],fill=PAPER)
 d.rectangle((7,7,72,20),fill=GOLD)
 d.line((8,7,70,7),fill=LIGHT)
 d.rectangle((7,21,15,45),fill='#d6c598')
 for y in range(23,45,5):d.rectangle((17,y,17,y+1),fill='#9e8b60')
 for y in [24,37]:
  d.rectangle((2,y,6,y+4),fill=(0,0,0,0));d.rectangle((73,y,77,y+4),fill=(0,0,0,0))
 text(d,(40,9),'UPGRADE',18,INK,True)
 icon=Image.open(ROOT/'assets/pixel'/f"{data['art']}.png").convert('RGBA')
 icon=icon.resize((24,24),Image.Resampling.NEAREST)
 im.alpha_composite(icon,(30,22))
 d=ImageDraw.Draw(im);d.fontmode='1'
 d.line((21,46,69,46),fill='#bcaa7f')
 # Visible tier marks distinguish related coupons without crowding their symbol.
 tier='III' if ident.endswith('3') else 'II' if ident.endswith('2') else 'I'
 text(d,(9,28),tier,12,INK)
 im.save(OUT/f'voucher_{ident}.png')
print('Wrote shop sign, Supply Pack, and',len(upgrades),'upgrade coupons.')

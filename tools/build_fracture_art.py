#!/usr/bin/env python3
"""Explicit pixel shapes for Fracture. No image model, downloaded illustration, or random pixels."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/plates';SMALL=ROOT/'assets/pixel'
s=(ROOT/'scripts/fracture_catalog.gd').read_text()
def data(name,next_name=None):
 part=s.split('const '+name+' = ',1)[1]
 return json.loads(part.split('\nconst '+next_name,1)[0] if next_name else part)
R=data('RELICS','UPGRADES');U=data('UPGRADES','FRACTURES');F=data('FRACTURES','BOARDS');B=data('BOARDS','PACKS');P=data('PACKS')
INK='#1d2d35';PAPER='#f4e5bb';LIGHT='#fff4d2';GOLD='#d7a04c';SHADE='#a87942';TEAL='#569b96';BLUE='#527c9d';RED='#bd6254';GREEN='#7c9f68';PURPLE='#9d7caf'
font=ROOT/'assets/type/m6x11plus.ttf'
def label(d,at,text,size=18,color=PAPER):
 f=ImageFont.truetype(str(font),size);b=d.textbbox((0,0),text,font=f)
 d.text((round(at[0]-d.textlength(text,font=f)/2),round(at[1]-b[1])),text,font=f,fill=color)
def artwork(id,bg):
 im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im);d.fontmode='1'
 d.rounded_rectangle((0,0,63,63),radius=6,fill=bg)
 d.rounded_rectangle((3,3,60,60),radius=4,outline=PAPER)
 d.rounded_rectangle((5,5,58,58),radius=3,outline=INK)
 r=lambda xy,c,o=None:d.rectangle(xy,fill=c,outline=o)
 p=lambda xy,c,o=None:d.polygon(xy,fill=c,outline=o)
 e=lambda xy,c,o=None:d.ellipse(xy,fill=c,outline=o)
 l=lambda xy,c,w=1:d.line(xy,fill=c,width=w)
 def rim(xy,c=PAPER):
  x,y,x2,y2=xy;r(xy,INK);r((x+2,y+2,x2-2,y2-2),c)
 def star(x,y,c=GOLD):l([(x-2,y),(x+2,y)],c);l([(x,y-2),(x,y+2)],c)
 if id=='handbrake':
  rim((14,45,49,52),SHADE);p([(24,45),(29,17),(35,17),(32,45)],INK);p([(27,44),(31,21),(33,21),(30,44)],PAPER)
  rim((26,12,45,21),RED);l([(29,14),(40,14)],LIGHT,2);r((12,38,19,41),GOLD)
 elif id=='matchbox':
  p([(14,27),(39,19),(53,29),(28,39)],INK);p([(17,27),(39,22),(49,29),(28,36)],PAPER)
  p([(14,30),(28,40),(51,32),(51,50),(29,56),(14,45)],RED,INK)
  l([(21,29),(36,24)],SHADE,2);l([(29,45),(43,40)],GOLD,2)
  l([(31,29),(27,14)],PAPER,3);p([(27,20),(22,16),(24,9),(28,7),(32,15)],GOLD,INK)
 elif id=='spare_change':
  p([(14,42),(23,25),(31,35),(39,22),(51,41),(43,53),(20,53)],TEAL,INK)
  for x,y in [(14,40),(31,45),(39,35)]:e((x,y,x+13,y+7),GOLD,PAPER);l([(x+4,y+3),(x+8,y+3)],SHADE)
  l([(27,18),(30,26),(35,18)],PAPER,2);star(42,14)
 elif id=='copper_coil':
  rim((12,43,51,52),SHADE)
  for y in range(15,43,5):d.arc((18,y,47,y+9),10,350,fill=INK,width=5);d.arc((18,y,47,y+9),10,350,fill=GOLD,width=2)
  l([(20,16),(16,12),(11,12)],PAPER,2);l([(43,43),(50,41),(53,32)],PAPER,2)
 elif id=='seedling':
  rim((18,42,46,53),SHADE);l([(32,43),(32,20)],PAPER,2)
  p([(31,32),(20,29),(15,19),(25,21)],GREEN,INK);l([(20,24),(31,32)],LIGHT)
  p([(33,26),(43,24),(49,13),(38,16)],TEAL,INK);l([(34,25),(44,17)],PAPER)
  for x in [15,43]:r((x,51,x+4,53),GOLD)
 elif id=='shipping_crate':
  p([(11,25),(33,14),(53,24),(32,36)],PAPER,INK);p([(11,25),(32,36),(32,55),(11,43)],SHADE,INK);p([(32,36),(53,24),(53,44),(32,55)],GOLD,INK)
  l([(23,19),(43,30),(43,46)],LIGHT,3);l([(15,33),(27,39)],INK,2);r((35,35,45,43),PAPER);l([(37,38),(42,36)],BLUE)
 elif id=='leech':
  d.arc((14,14,51,50),30,300,fill=INK,width=14);d.arc((14,14,51,50),30,300,fill=PURPLE,width=9)
  for x,y in [(19,26),(20,37),(29,44),(41,40)]:l([(x-3,y),(x+3,y-3)],PAPER,2)
  e((39,13,50,24),RED,INK);e((42,16,44,18),PAPER);p([(36,47),(43,44),(44,50)],GOLD)
 elif id=='spore_cloud':
  for x,y,c in [(10,31,RED),(28,20,TEAL),(39,35,GOLD)]:
   r((x+7,y+8,x+10,y+22),PAPER);e((x,y,x+19,y+13),INK);e((x+2,y+1,x+17,y+10),c);r((x+6,y+4,x+8,y+6),LIGHT)
  for x,y in [(17,15),(26,9),(48,23)]:star(x,y,PAPER)
 elif id=='cuckoo_clock':
  p([(12,25),(32,9),(52,25)],INK);p([(17,24),(32,13),(47,24)],RED)
  rim((18,25,46,47),SHADE);e((24,28,40,43),PAPER,INK);l([(32,31),(32,36),(37,38)],INK,2)
  l([(26,47),(24,55)],GOLD,2);l([(38,47),(40,55)],GOLD,2);p([(28,20),(31,17),(35,20),(33,23)],GOLD,INK)
 elif id=='morgue':
  p([(17,53),(17,21),(24,12),(40,12),(47,21),(47,53)],INK);p([(21,50),(21,23),(26,17),(38,17),(43,23),(43,50)],BLUE)
  l([(25,28),(39,28)],PAPER,3);l([(32,22),(32,38)],PAPER,3);e((26,43,38,52),RED,INK)
 elif id=='spare_parts':
  p([(12,22),(19,14),(26,14),(25,22),(31,28),(43,42),(39,48),(24,33),(18,28),(12,29)],PAPER,INK)
  e((35,13,51,29),INK);e((38,16,48,26),GOLD);e((41,19,45,23),INK)
  for x,y in [(13,43),(27,46),(44,45)]:rim((x,y,x+8,y+8),TEAL)
 elif id=='body_double':
  for x,y,c in [(14,13,BLUE),(30,23,TEAL)]:
   e((x+4,y,x+16,y+12),PAPER,INK);p([(x,y+29),(x+3,y+14),(x+17,y+14),(x+21,y+29)],c,INK)
  l([(13,49),(49,49)],GOLD,2);star(47,13)
 elif id=='recycling_bin':
  rim((18,22,46,53),TEAL);rim((15,17,49,24),PAPER);rim((26,12,38,17),SHADE)
  p([(31,29),(37,35),(33,35),(33,39),(27,39),(27,35),(24,35)],GOLD)
  l([(23,43),(27,47),(37,47),(41,43)],PAPER,2)
 elif id=='pandora':
  p([(12,26),(32,14),(53,26),(33,38)],GOLD,INK);p([(12,28),(33,39),(33,55),(12,43)],RED,INK);p([(33,39),(53,28),(53,43),(33,55)],PURPLE,INK)
  l([(32,16),(32,34)],PAPER,3);l([(18,29),(46,29)],PAPER,3);star(17,14);star(48,11)
 elif id=='red_thread':
  rim((20,18,44,49),PAPER)
  for y in range(23,46,4):l([(19,y),(45,y)],RED,3)
  rim((16,14,48,20),GOLD);rim((16,48,48,53),GOLD);l([(45,35),(53,38),(52,48),(44,53)],RED,2)
 elif id=='double_exposure':
  for x,y,c in [(12,15,BLUE),(25,25,TEAL)]:
   rim((x,y,x+26,y+28),PAPER);r((x+4,y+4,x+22,y+24),INK);p([(x+5,y+22),(x+13,y+10),(x+21,y+22)],c)
  star(47,14)
 elif id=='clone_vat':
  rim((18,11,46,17),PAPER);rim((15,17,49,52),INK);r((19,20,45,47),TEAL)
  e((27,26,37,36),PAPER,INK);p([(23,44),(25,37),(39,37),(42,44)],BLUE,INK)
  for x,y in [(22,23),(40,38),(23,41)]:e((x,y,x+3,y+3),GOLD)
 elif id=='guillotine':
  rim((12,10,19,53),SHADE);rim((45,10,52,53),SHADE);rim((11,10,53,17),PAPER)
  p([(20,20),(44,20),(44,28),(20,38)],INK);p([(23,22),(42,22),(42,27),(23,34)],BLUE)
  rim((10,50,54,55),RED);e((27,41,37,51),PAPER,INK);l([(17,18),(17,45)],GOLD)
 elif id=='loan_shark':
  p([(10,35),(20,25),(33,24),(37,13),(43,26),(53,33),(47,46),(26,49),(12,42)],BLUE,INK)
  p([(18,36),(29,35),(40,38),(47,35),(41,44),(24,44)],PAPER,INK);p([(25,36),(28,41),(31,36),(34,41),(37,37)],RED)
  e((42,29,45,32),INK);e((12,47,26,54),GOLD,PAPER)
 elif id=='stowaway':
  rim((14,23,50,52),SHADE);rim((24,16,40,24),PAPER)
  r((18,28,46,48),RED);l([(21,24),(21,51)],GOLD,3);l([(43,24),(43,51)],GOLD,3)
  rim((27,31,38,43),PAPER);r((29,34,35,36),INK)
 elif id=='chain_reaction':
  for x,y in [(12,16),(28,25),(43,39)]:
   d.ellipse((x,y,x+12,y+17),outline=INK,width=5);d.ellipse((x,y,x+12,y+17),outline=GOLD,width=2)
  p([(41,12),(37,25),(44,23),(40,34),(52,18),(45,20)],PAPER,INK);star(16,45)
 elif id=='ghostwriter':
  p([(13,47),(16,27),(23,15),(39,13),(49,22),(46,37),(42,47),(36,43),(30,49),(23,44),(17,49)],PAPER,INK)
  e((24,23,27,29),INK);e((35,22,38,28),INK);l([(34,48),(52,28)],GOLD,3);p([(43,30),(52,21),(55,30),(44,39)],TEAL,INK)
 elif id=='risky_investment':
  rim((12,16,50,48),PAPER);r((17,21,46,44),INK)
  l([(19,40),(27,31),(32,36),(42,25)],TEAL,3);p([(37,24),(45,22),(43,31)],GOLD)
  e((12,47,28,55),GOLD,PAPER);e((30,48,46,55),GOLD,PAPER)
 elif id=='chrysalis':
  l([(29,10),(35,14),(32,20)],PAPER,2);p([(32,16),(21,27),(19,42),(27,53),(38,50),(45,35),(41,23)],GREEN,INK)
  l([(25,28),(39,24)],PAPER,2);l([(22,35),(43,31)],GOLD,2);l([(23,43),(39,40)],PAPER,2);star(49,17)
 elif id=='conductor':
  p([(12,48),(22,33),(29,38),(17,54)],BLUE,INK);p([(22,33),(24,28),(31,30),(34,37),(29,41)],PAPER,INK)
  l([(30,33),(49,13)],INK,5);l([(30,32),(48,13)],GOLD,2)
  for x,y in [(18,17),(41,44)]:l([(x,y),(x+8,y)],PAPER,2);l([(x,y+4),(x+6,y+4)],TEAL)
 elif id=='perpetuum':
  for x in [11,31]:e((x,22,x+22,44),INK);e((x+3,25,x+19,41),GOLD);e((x+7,29,x+15,37),INK)
  l([(24,29),(40,38)],PAPER,3);l([(24,38),(40,29)],PAPER,3);star(32,13);star(49,50)
 elif id=='devourer':
  p([(11,24),(23,12),(41,12),(53,24),(49,48),(38,55),(24,52),(14,44)],RED,INK)
  e((16,23,48,49),INK);p([(18,25),(23,34),(28,25),(33,35),(39,25),(45,27),(40,38),(35,45),(29,38),(23,45),(18,36)],PAPER)
  e((23,17,27,21),GOLD);e((37,17,41,21),GOLD)
 elif id=='crown_echoes':
  p([(12,24),(19,31),(23,16),(32,29),(42,16),(46,31),(54,24),(48,48),(18,48)],INK)
  p([(16,29),(21,36),(25,23),(32,34),(40,23),(44,36),(50,29),(45,44),(21,44)],GOLD)
  rim((17,46,49,53),PAPER);e((28,37,36,45),RED,INK);star(32,12)
 elif id=='paradox':
  rim((17,12,47,18),PAPER);rim((17,47,47,54),PAPER)
  p([(22,19),(42,19),(38,27),(33,32),(40,40),(42,46),(22,46),(25,38),(30,32),(24,25)],INK)
  p([(25,21),(39,21),(32,30)],GOLD);p([(25,44),(32,35),(39,44)],TEAL)
  d.arc((8,16,53,52),85,260,fill=PURPLE,width=3);p([(7,34),(8,23),(16,29)],PAPER)
 elif id=='mobius':
  p([(10,27),(21,15),(38,17),(53,34),(43,48),(27,48)],INK)
  p([(14,28),(22,19),(35,21),(45,34),(40,39),(29,27),(24,28),(38,44),(28,44)],TEAL)
  p([(17,32),(29,42),(39,43),(49,34),(45,30),(39,37),(33,35),(23,24)],GOLD)
  l([(22,21),(35,23),(40,28)],PAPER,2);star(47,13)
 elif id.startswith('storefront'):
  rim((13,25,51,52),TEAL);rim((12,17,52,28),PAPER)
  for x in range(15,51,8):r((x,18,x+3,28),RED)
  rim((29,32,44,51),PAPER);r((32,35,41,49),INK)
 elif id.startswith('shatterproof'):
  p([(32,10),(50,18),(47,39),(32,54),(17,39),(14,18)],INK);p([(32,15),(45,21),(42,37),(32,47),(22,37),(19,21)],TEAL)
  l([(25,30),(30,35),(40,24)],PAPER,4)
 elif id.startswith('satchel'):
  rim((16,21,48,52),SHADE);rim((25,14,39,22),PAPER);rim((14,24,50,36),RED);rim((28,32,36,42),GOLD)
 elif id.startswith('scrapyard'):
  for x,y,c in [(12,39,TEAL),(24,30,BLUE),(39,43,GOLD)]:rim((x,y,x+13,y+12),c)
  l([(18,15),(45,42)],INK,7);l([(18,14),(45,41)],PAPER,3);e((12,10,23,21),SHADE,INK)
 elif id.startswith('wagers'):
  for x,y,c in [(13,34,RED),(27,41,GOLD),(35,26,TEAL)]:e((x,y,x+17,y+9),INK);e((x,y-3,x+17,y+5),c,PAPER)
  p([(18,15),(30,11),(34,25),(22,29)],PAPER,INK);e((24,18,27,21),RED)
 elif id.startswith('fusion'):
  rim((20,11,43,18),PAPER);p([(25,18),(25,30),(14,47),(18,54),(47,54),(51,47),(38,30),(38,18)],INK)
  p([(28,20),(28,31),(19,46),(22,50),(43,50),(46,46),(35,31),(35,20)],BLUE)
  p([(23,39),(41,39),(47,47),(43,51),(22,51),(18,47)],PURPLE);star(32,40,LIGHT)
 elif id in ['glasshouse','treasury','eclipse','vortex','hollow','reactor','twinfall','nomad','labyrinth','rich_get_richer']:
  if id=='glasshouse':
   p([(13,29),(32,13),(51,29),(51,51),(13,51)],TEAL,INK);l([(32,14),(32,50)],PAPER,2);l([(14,29),(50,29)],PAPER,2);l([(21,23),(21,48),(43,48),(43,23)],LIGHT)
  elif id=='treasury':
   rim((14,15,50,53),GOLD);rim((19,21,45,47),INK);e((25,27,40,42),BLUE,PAPER);l([(33,29),(33,40)],GOLD,2);l([(27,35),(39,35)],GOLD,2)
  elif id=='eclipse':
   e((12,12,52,52),INK);e((16,16,48,48),GOLD);d.pieslice((16,16,48,48),90,270,fill=PURPLE);e((25,23,30,29),PAPER);star(48,12)
  elif id=='vortex':
   for box,start,end,c in [((12,12,52,52),15,315,PAPER),((18,18,46,46),170,480,TEAL),((25,25,39,39),10,320,GOLD)]:d.arc(box,start,end,fill=c,width=3)
   p([(45,12),(54,21),(43,24)],GOLD,INK)
  elif id=='hollow':
   p([(17,50),(17,20),(25,12),(40,12),(48,21),(48,50)],INK);p([(23,47),(23,25),(28,20),(36,20),(42,26),(42,47)],BLUE);p([(28,46),(28,30),(36,30),(36,46)],INK)
  elif id=='reactor':
   for bounds in [(12,23,52,40),(23,12,40,52)]:d.ellipse(bounds,outline=PAPER,width=2)
   e((25,25,39,39),RED,INK);e((29,29,35,35),GOLD);star(15,45);star(46,18)
  elif id=='twinfall':
   p([(12,17),(27,17),(24,34),(30,45),(23,54),(12,45),(19,32)],BLUE,INK);p([(37,12),(52,12),(46,31),(52,45),(43,53),(34,43),(41,29)],TEAL,INK)
   l([(20,20),(18,29)],PAPER,2);l([(44,16),(41,26)],PAPER,2)
  elif id=='nomad':
   p([(11,48),(32,15),(53,48)],PAPER,INK);p([(32,17),(32,47),(50,47)],GOLD,INK);p([(24,47),(32,31),(40,47)],INK);l([(10,51),(54,51)],TEAL,2)
  elif id=='labyrinth':
   rim((11,11,53,53),PAPER);r((15,15,49,49),INK);l([(15,19),(40,19),(40,29),(24,29),(24,41),(44,41)],TEAL,4);l([(19,49),(19,35)],GOLD,3);r((44,23,49,31),PAPER)
  else:
   p([(14,41),(23,27),(27,31),(37,17),(48,20),(53,35),(44,48),(26,51)],GOLD,INK);l([(23,39),(30,31),(35,37),(44,25)],PAPER,3);star(15,17);star(46,12)
 elif id in F:
  # Each transformation has a concrete silhouette within the fractured print stock.
  if id=='liberation':
   for x,y in [(12,29),(35,18)]:d.ellipse((x,y,x+17,y+15),outline=PAPER,width=4)
   l([(26,30),(30,25)],RED,3);star(32,39,GOLD);l([(24,20),(20,13)],GOLD,2)
  elif id=='overexposure':
   e((22,22,42,42),GOLD,PAPER)
   for x,y,x2,y2 in [(32,10,32,17),(32,47,32,54),(10,32,17,32),(47,32,54,32),(16,16,21,21),(43,43,48,48),(16,48,21,43),(43,21,48,16)]:l([(x,y),(x2,y2)],PAPER,2)
  elif id=='erosion':
   p([(15,44),(21,21),(36,15),(47,25),(49,46),(31,51)],BLUE,INK);l([(34,18),(29,31),(38,34),(29,48)],PAPER,2)
   for x,y in [(11,49),(46,52),(49,17)]:r((x,y,x+4,y+4),GOLD)
  elif id=='rebirth':
   e((20,17,45,53),PAPER,INK);p([(22,39),(30,32),(27,25),(36,30),(42,24),(41,39),(34,46)],RED);l([(22,38),(31,40),(36,35),(43,39)],INK,2);star(15,15)
  elif id=='schism':
   for x,y,c in [(12,14,BLUE),(34,25,RED)]:rim((x,y,x+18,y+27),PAPER);r((x+4,y+5,x+14,y+22),c)
   l([(32,12),(29,25),(35,32),(29,48)],GOLD,2)
  elif id=='transmutation':
   p([(16,43),(32,15),(49,44)],TEAL,INK);d.arc((10,10,54,54),30,165,fill=PAPER,width=3);d.arc((10,10,54,54),210,345,fill=GOLD,width=3)
   p([(44,14),(54,20),(43,25)],GOLD);e((27,34,37,44),RED,INK)
  elif id=='genesis':
   for x,y in [(15,31),(35,20)]:rim((x,y,x+16,y+20),PAPER);r((x+4,y+5,x+12,y+16),TEAL)
   l([(24,12),(24,23)],GOLD,3);l([(19,17),(29,17)],GOLD,3)
  elif id=='collapse':
   for x,y in [(11,14),(40,15),(28,42)]:p([(x,y),(x+12,y+2),(x+10,y+13),(x+1,y+11)],BLUE,INK)
   e((23,24,42,42),INK);d.arc((18,20,46,46),0,300,fill=GOLD,width=3);star(32,30,RED)
  elif id=='transference':
   for x,y,c in [(12,15,GOLD),(40,14,TEAL),(13,43,RED)]:e((x,y,x+9,y+9),c,PAPER);l([(x+8,y+8),(35,38)],PAPER,2)
   rim((31,34,49,54),PURPLE);e((36,39,44,47),GOLD,INK)
  elif id=='pandemonium':
   for pts,c in [([(12,18),(24,13),(30,27),(17,31)],RED),([(35,12),(51,17),(47,32),(32,26)],GOLD),([(19,37),(38,33),(47,49),(26,54)],TEAL)]:p(pts,c,INK)
   l([(15,14),(49,52)],PAPER,2);l([(47,14),(17,52)],PAPER,2)
  elif id=='monoculture':
   for x in [13,32]:
    for y in [14,34]:rim((x,y,x+16,y+16),TEAL);e((x+5,y+5,x+11,y+11),RED,INK)
  elif id=='liquidation':
   p([(15,15),(44,15),(49,34),(41,40),(39,51),(19,51),(17,40),(12,34)],BLUE,INK)
   l([(18,18),(39,38),(23,41),(39,48)],PAPER,2);e((40,43,54,52),GOLD,PAPER)
  elif id=='overdraft':
   rim((13,18,51,48),RED);rim((18,25,46,42),INK);l([(23,33),(41,33)],PAPER,3);l([(32,24),(32,42)],PAPER,3);star(47,13)
  elif id=='asceticism':
   p([(32,11),(44,22),(43,40),(32,53),(20,40),(20,23)],PAPER,INK);p([(32,18),(38,25),(32,32),(26,25)],TEAL)
   for x,y in [(14,18),(47,17),(11,41),(48,43)]:star(x,y,GOLD)
  else:
   p([(12,25),(22,32),(25,14),(33,29),(42,14),(46,32),(54,25),(47,49),(18,49)],GOLD,INK)
   rim((17,47,49,54),PAPER);e((29,35,37,43),PURPLE,INK);star(32,11,PAPER)
 else:raise ValueError(id)
 return im
for id,item in {**R,**U,**F}.items():
 bg=item.get('accent','#75608f')
 image=artwork(id,bg)
 image.save(OUT/(id+'.png'),optimize=True)
 image.resize((32,32),Image.Resampling.NEAREST).save(SMALL/(id+'.png'),optimize=True)
for b in B:
 id=b['id'];image=artwork(id,b['color']);image.save(OUT/(id+'.png'),optimize=True)
 image.resize((32,32),Image.Resampling.NEAREST).save(SMALL/(id+'.png'),optimize=True)
 im=Image.new('RGBA',(80,100));d=ImageDraw.Draw(im)
 for rect,rad,col in [((4,5,77,99),7,INK),((1,1,74,95),7,PAPER),((4,4,71,92),5,INK),((6,6,69,90),4,b['color'])]:d.rounded_rectangle(rect,radius=rad,fill=col)
 im.alpha_composite(image,(6,17))
 for x,y in [(9,9),(62,9),(9,84),(62,84)]:d.rectangle((x,y,x+3,y+3),fill=GOLD)
 d.line((15,11,60,11),fill=PAPER);d.line((15,86,60,86),fill=PAPER)
 im.save(OUT/('board_'+id+'.png'),optimize=True)
for type,pack in P.items():
 for size in ['Standard','Jumbo','Mega']:
  im=Image.new('RGBA',(64,64));d=ImageDraw.Draw(im);d.fontmode='1';bg=pack['color']
  d.rounded_rectangle((5,3,58,61),radius=4,fill=INK)
  d.rectangle((8,9,55,55),fill=bg);d.rectangle((9,11,13,53),fill=PURPLE if type=='fracture' else PAPER);d.rectangle((51,11,55,54),fill=INK)
  for x in range(9,55,4):d.rectangle((x,4,x+1,8),fill=GOLD);d.rectangle((x,56,x+1,60),fill=SHADE)
  title={'standard':'SUPPLY','reliquary':'RELIC','grimoire':'SPELL','sigil':'RUNE','fracture':'RIFT'}[type]
  label(d,(32,13),title)
  if type=='standard':
   for xy,c in [((16,30,29,47),GOLD),((35,30,48,47),TEAL),((24,28,40,49),PAPER)]:d.rectangle(xy,fill=c,outline=INK)
   label(d,(32,33),'?',18,INK)
  elif type=='reliquary':d.ellipse((20,29,45,49),fill=GOLD,outline=PAPER);d.ellipse((26,34,39,44),fill=INK);d.rectangle((29,26,36,31),fill=PAPER)
  elif type=='grimoire':d.polygon([(19,30),(32,28),(46,30),(45,48),(32,46),(19,48)],fill=PAPER,outline=INK);d.line((32,30,32,45),fill=SHADE,width=2);d.line((23,36,28,34),fill=RED,width=2);d.line((36,35,41,37),fill=TEAL,width=2)
  elif type=='sigil':d.ellipse((21,28,44,49),fill=BLUE,outline=PAPER);d.line((32,31,27,38,36,40,31,46),fill=PAPER,width=2)
  else:d.polygon([(32,27),(46,38),(34,50),(19,39)],fill=PURPLE,outline=PAPER);d.line((34,28,29,36,36,39,31,48),fill=INK,width=2)
  if size!='Standard':
   d.rectangle((11,48,52,55),fill=INK)
   label(d,(32,49),'JUMBO' if size=='Jumbo' else 'MEGA',9,GOLD)
  im.save(OUT/f'pack_{type}_{size.lower()}.png',optimize=True)
print('Wrote',len(R)+len(U)+len(F),'content illustrations, 10 board portraits, 15 typed pack wrappers.')

#!/usr/bin/env python3
"""Editable 64px pixel plates: explicit silhouettes, four-tone ink, one light source.
No image-model output, rasterized vectors, or downloaded artwork is used.
Run only to rebuild committed PNGs; Pillow is a development dependency.
"""
from pathlib import Path
from PIL import Image, ImageDraw
OUT=Path(__file__).resolve().parents[1]/'assets/plates';OUT.mkdir(exist_ok=True)
INK='#1d2d35';PAPER='#f4e5bb';LIGHT='#fff4d2';GOLD='#d7a04c';SHADE='#a87942';TEAL='#569b96';BLUE='#527c9d';RED='#bd6254';GREEN='#7c9f68'
NAMES=['carbon','corner','echo','coins','fork','domino','feedback','monolith','battery','anvil','purse','mirror','match','stair','flask','plant','horizon','magnet','hand','mountain','wings','ticket','telescope','orbit']
BACK=['#46605b','#876343','#496a85','#8a7440','#995747','#39666b','#7d5260','#4c4b66','#977440','#526860','#7c6948','#6a597d','#964e41','#4f6b54','#386e6b','#4b6c48','#8b634a','#8a4b43','#92723e','#466b83','#806745','#657046','#515e83','#6b466a']
for name,bg in zip(NAMES,BACK):
 im=Image.new('RGBA',(64,64),bg);d=ImageDraw.Draw(im)
 r=lambda b,c,o=None:d.rectangle(b,fill=c,outline=o)
 p=lambda pts,c,o=None:d.polygon(pts,fill=c,outline=o)
 l=lambda pts,c,w=1:d.line(pts,fill=c,width=w)
 e=lambda b,c,o=None:d.ellipse(b,fill=c,outline=o)
 def star(x,y,c=PAPER):
  l([(x-2,y),(x+2,y)],c);l([(x,y-2),(x,y+2)],c)
 def rim(b,c=PAPER):
  x,y,x2,y2=b;r(b,INK);r((x+2,y+2,x2-2,y2-2),c)
 # Quiet, repeatable print framing. Large clusters, no stochastic texture.
 r((3,3,60,60),None,PAPER);r((5,5,58,58),None,INK)
 for x,y in [(7,7),(55,7),(7,55),(55,55)]:r((x,y,x+1,y+1),GOLD)
 if name=='carbon':
  p([(13,19),(43,13),(51,45),(21,52)],INK)
  p([(12,18),(42,12),(49,43),(20,50)],'#798e91',PAPER)
  p([(19,13),(48,16),(45,46),(16,43)],PAPER,INK)
  p([(42,16),(48,16),(47,23),(41,21)],SHADE)
  for y in [24,28,32,36]:l([(23,y),(39,y+2)],BLUE,2)
  r((31,42,51,48),INK);r((33,42,49,46),TEAL);r((39,48,44,55),SHADE)
 elif name=='corner':
  p([(11,34),(31,21),(52,29),(34,45)],PAPER,INK)
  p([(11,34),(34,45),(34,56),(11,44)],SHADE,INK)
  p([(34,45),(52,29),(52,42),(34,56)],GOLD,INK)
  l([(17,34),(31,26),(44,31)],LIGHT,2)
  l([(26,46),(26,41),(19,38)],INK)
  l([(34,30),(34,17)],GREEN,2)
  p([(34,22),(27,19),(26,14),(32,16)],GREEN,INK)
  p([(35,19),(38,12),(44,12),(41,18)],GOLD,INK)
 elif name=='echo':
  p([(12,52),(12,26),(17,16),(25,11),(39,11),(47,16),(52,26),(52,52)],PAPER,INK)
  p([(20,52),(20,28),(24,21),(31,18),(39,21),(44,28),(44,52)],INK)
  for b,c in [((23,25,41,44),BLUE),((27,29,37,40),TEAL),((30,32,34,37),PAPER)]:d.arc(b,210,510,fill=c,width=2)
  for x,y in [(14,32),(44,20),(24,13),(15,45),(45,40)]:r((x,y,x+4,y+1),SHADE)
  r((11,53,53,55),GOLD)
 elif name=='coins':
  rim((15,25,49,45),SHADE);rim((19,15,46,28),PAPER)
  r((23,19,42,24),INK);r((25,20,40,21),TEAL)
  r((14,43,50,50),INK);r((16,44,48,47),GOLD)
  for y in [31,36]:
   for x in [21,28,35,42]:r((x,y,x+3,y+2),LIGHT)
  for x,y in [(10,49),(41,52),(29,52)]:
   e((x,y,x+12,y+5),INK);e((x,y-2,x+12,y+3),GOLD,PAPER);l([(x+3,y),(x+8,y)],SHADE)
 elif name=='fork':
  p([(18,13),(25,13),(25,31),(28,34),(36,34),(39,31),(39,13),(46,13),(46,33),(39,41),(35,41),(35,52),(29,52),(29,41),(24,41),(18,33)],INK)
  l([(21,15),(21,32),(27,38),(37,38),(42,32),(42,15)],PAPER,3)
  r((31,39,33,52),GOLD);r((23,53,41,55),INK)
  for x in [12,50]:l([(x,17),(x-2,22),(x,27)],TEAL,2)
 elif name=='domino':
  p([(11,24),(25,13),(40,34),(25,46)],INK);p([(13,25),(25,16),(37,34),(25,43)],PAPER)
  l([(19,31),(30,24)],SHADE)
  for x,y in [(21,23),(27,34),(25,30)]:e((x,y,x+2,y+2),INK)
  p([(32,29),(48,27),(53,53),(36,55)],INK);p([(34,31),(46,30),(50,51),(38,53)],LIGHT)
  l([(36,41),(48,40)],SHADE)
  for x,y in [(39,35),(42,46),(45,48)]:e((x,y,x+2,y+2),INK)
 elif name=='feedback':
  for b in [(12,12,51,51),(19,19,44,44)]:d.arc(b,32,332,fill=INK,width=6);d.arc(b,32,332,fill=GOLD,width=3)
  p([(46,12),(54,23),(42,25)],PAPER,INK)
  e((26,26,39,39),INK);e((28,28,37,37),RED,PAPER);star(32,31,LIGHT)
 elif name=='monolith':
  p([(19,51),(23,18),(36,10),(45,18),(43,51)],INK)
  p([(23,18),(36,10),(36,49),(19,54)],'#59627e',PAPER)
  p([(36,10),(45,18),(43,51),(36,49)],'#313c54',INK)
  l([(27,22),(27,41)],'#8c9bb0',2);e((27,26,34,34),None,INK);e((29,28,32,31),GOLD)
  r((13,53,50,55),SHADE);star(15,15);star(49,27)
 elif name=='battery':
  rim((21,13,43,20),GOLD);rim((16,20,48,52),PAPER)
  r((20,24,45,46),SHADE);r((21,26,24,45),LIGHT)
  p([(33,25),(26,36),(32,36),(29,46),(40,32),(34,32)],INK)
  l([(12,25),(9,30),(13,34)],BLUE,2);l([(52,39),(55,43),(51,49)],TEAL,2)
 elif name=='anvil':
  p([(9,25),(21,22),(47,22),(51,28),(42,34),(37,34),(37,42),(45,48),(45,52),(19,52),(19,48),(27,42),(27,34),(19,34)],INK)
  p([(12,25),(46,25),(49,28),(40,31),(20,31)],PAPER)
  p([(27,33),(35,33),(35,44),(42,49),(22,49),(29,43)],TEAL)
  r((28,20,44,23),RED);l([(30,20),(42,20)],GOLD,2);star(40,14);star(22,17,GOLD)
 elif name=='purse':
  p([(25,16),(19,11),(44,11),(39,19),(46,29),(50,46),(43,53),(20,53),(13,46),(18,29)],INK)
  p([(25,18),(39,18),(43,30),(46,46),(40,49),(22,49),(17,44),(21,29)],RED)
  l([(25,24),(21,41),(24,46)],PAPER,2);l([(38,26),(42,42)],SHADE,2)
  l([(21,20),(43,20)],GOLD,3);l([(40,20),(48,27)],GOLD,2)
  for x in [10,41]:e((x,49,x+14,55),GOLD,PAPER);l([(x+4,52),(x+10,52)],SHADE)
 elif name=='mirror':
  e((15,10,49,47),INK);e((18,12,46,44),GOLD);e((21,15,43,41),INK);e((23,17,41,39),BLUE)
  l([(26,22),(33,18)],PAPER,2);l([(26,27),(36,20)],TEAL,2)
  r((30,46,34,52),PAPER);r((20,53,45,55),INK);star(36,31)
 elif name=='match':
  p([(14,36),(39,29),(53,39),(28,48)],INK);p([(16,37),(39,32),(50,39),(28,45)],PAPER)
  p([(14,39),(28,48),(51,42),(51,52),(29,56),(14,48)],RED,INK)
  for x in [22,27,32]:l([(x,40),(x+13,36)],SHADE)
  l([(35,40),(29,20)],PAPER,3)
  p([(29,24),(23,20),(24,14),(29,7),(33,17),(33,21)],GOLD,INK)
  p([(28,21),(27,17),(29,13),(31,20)],LIGHT)
 elif name=='stair':
  for i in range(5):
   x=12+i*6;y=47-i*7
   r((x,y,x+15,55),INK);r((x+1,y,x+14,y+3),PAPER);r((x+1,y+4,x+13,y+6),TEAL)
  star(44,11,GOLD);l([(15,14),(23,14)],PAPER);l([(19,10),(19,18)],PAPER)
 elif name=='flask':
  p([(25,12),(40,12),(40,17),(37,17),(37,28),(48,45),(46,53),(18,53),(16,46),(28,28),(28,17),(25,17)],INK)
  p([(29,18),(35,18),(35,29),(45,46),(43,50),(21,50),(19,46),(30,29)],BLUE)
  p([(25,37),(39,37),(45,46),(42,50),(21,50),(20,46)],TEAL)
  l([(27,34),(22,44),(23,47)],LIGHT,2);r((26,12,39,14),PAPER)
  for x,y in [(30,41),(37,46),(35,33)]:e((x,y,x+3,y+3),PAPER)
 elif name=='plant':
  p([(18,39),(47,39),(42,55),(23,55)],INK);p([(20,42),(44,42),(40,52),(25,52)],RED)
  r((17,36,47,41),INK);r((19,37,45,39),GOLD)
  l([(32,37),(32,14)],INK,3);l([(31,35),(31,15)],PAPER)
  for pts in [[(30,26),(20,25),(15,16),(24,17)],[(33,32),(43,29),(47,20),(38,22)],[(32,17),(30,8),(37,12),(37,17)]]:p(pts,GREEN,INK);l([pts[0],pts[2]],PAPER)
 elif name=='horizon':
  e((18,15,46,43),GOLD,PAPER)
  for y in [27,32,37]:r((14,y,49,y+1),bg)
  p([(7,42),(19,38),(31,43),(41,35),(57,40),(57,57),(7,57)],INK)
  l([(9,49),(26,47),(40,49),(55,45)],RED,3)
 elif name=='magnet':
  p([(16,13),(26,13),(26,35),(29,39),(36,39),(39,35),(39,13),(49,13),(49,36),(43,46),(37,50),(27,50),(17,45),(13,35)],INK)
  l([(20,15),(20,34),(25,43),(38,43),(44,34),(44,15)],RED,5)
  r((16,13,24,22),PAPER);r((40,13,47,22),PAPER)
  for x,y in [(27,16),(31,25),(31,8)]:r((x,y,x+4,y+4),TEAL,INK)
 elif name=='hand':
  p([(15,44),(22,43),(21,29),(25,27),(28,38),(28,18),(32,16),(34,34),(36,19),(40,19),(40,36),(44,27),(48,28),(46,44),(37,53),(23,53)],INK)
  p([(19,46),(25,45),(24,31),(26,36),(30,43),(30,20),(32,20),(33,41),(38,23),(38,41),(45,30),(43,44),(35,50),(24,50)],GOLD)
  l([(27,46),(33,43),(40,44)],PAPER,2);star(16,19);star(49,16)
 elif name=='mountain':
  p([(8,53),(27,13),(34,28),(40,20),(57,53)],INK)
  p([(12,51),(28,18),(46,51)],BLUE)
  p([(28,18),(20,34),(26,31),(30,35),(33,29)],PAPER)
  p([(28,20),(31,36),(41,51),(48,51)],'#34516b')
  p([(32,38),(37,41),(35,45),(44,48),(47,54),(30,54),(32,48),(28,44)],LIGHT)
 elif name=='wings':
  p([(31,45),(21,44),(12,36),(8,19),(18,27),(26,29),(32,38),(38,29),(47,26),(56,17),(53,36),(44,44)],INK)
  for dy in [0,5,10]:
   l([(11,23+dy),(22,33+dy),(30,36+dy)],PAPER,3)
   l([(54,22+dy),(43,33+dy),(35,36+dy)],GOLD,3)
  e((26,13,39,26),GOLD,PAPER);r((30,46,35,53),PAPER);star(32,8)
 elif name=='ticket':
  p([(13,15),(49,15),(49,25),(45,29),(49,33),(49,48),(13,48),(13,39),(17,35),(13,31)],INK)
  p([(16,18),(46,18),(46,24),(42,29),(46,34),(46,45),(16,45),(16,40),(20,35),(16,30)],GREEN)
  for y in range(21,45,4):r((36,y,37,y+1),PAPER)
  e((21,24,31,34),GOLD,PAPER);l([(23,38),(30,38)],PAPER,2)
 elif name=='telescope':
  p([(12,22),(18,12),(47,27),(41,39)],INK)
  p([(17,22),(21,16),(44,28),(40,35)],BLUE)
  l([(17,20),(41,31)],PAPER,2);p([(12,22),(15,16),(18,18),(15,24)],GOLD)
  l([(33,35),(33,43),(21,54)],PAPER,3);l([(33,43),(47,54)],GOLD,3);r((30,35,36,40),INK)
  star(48,14);star(16,40)
 elif name=='orbit':
  e((12,12,52,52),INK);e((17,17,47,47),'#927ca2');e((22,22,42,42),INK)
  d.arc((8,23,56,44),155,345,fill=GOLD,width=3);d.arc((13,15,53,48),335,505,fill=PAPER,width=2)
  e((27,27,37,37),INK);star(46,17);star(14,46)
 im.save(OUT/(name+'.png'),optimize=True)
print('Wrote',len(NAMES),'editable 64px relic plates')
# Board portraits share the paper stock and deliberate crest composition.
boards=[('red','#bd554e','hourglass'),('yellow','#ca9b39','coins'),('blue','#3b729f','echo'),('robot','#71858e','auto'),('classic','#3d8073','gate'),('green','#4d8b62','flask'),('purple','#77569b','seal'),('orange','#c87b3c','battery'),('white','#d5d6be','heart'),('black','#3e3459','orbit'),('foundry','#43828b','anvil'),('bazaar','#af7b44','ticket'),('chronicle','#395e87','hourglass'),('archivist','#80638e','carbon'),('curio','#a25b75','pack')]
for name,color,symbol in boards:
 im=Image.new('RGBA',(80,100));d=ImageDraw.Draw(im)
 d.rectangle((4,5,77,99),fill=INK)
 d.rectangle((1,1,74,95),fill=PAPER)
 d.rectangle((4,4,71,92),fill=INK)
 d.rectangle((6,6,69,90),fill=color)
 plate=OUT/(symbol+'.png')
 if plate.is_file():im.alpha_composite(Image.open(plate),(6,17))
 else:
  icon=Image.open(OUT.parent/'pixel'/(symbol+'.png'))
  im.alpha_composite(icon,(22,32))
 for x,y in [(9,9),(62,9),(9,84),(62,84)]:
  d.rectangle((x,y,x+3,y+3),fill=GOLD)
 d.line((15,11,60,11),fill=PAPER)
 d.line((15,86,60,86),fill=PAPER)
 im.save(OUT/('board_'+name+'.png'),optimize=True)

#!/usr/bin/env python3
"""Original material SFX, built with noise excitation and damped resonators.
No stock game samples or external recordings. WAVs are committed for runtime use.
"""
from pathlib import Path
import numpy as np
import wave
OUT=Path(__file__).resolve().parents[1]/'assets/audio';OUT.mkdir(exist_ok=True)
SR=22050
rng=np.random.default_rng(2048)
def write(name,x):
 x=np.tanh(x*1.15)*.62
 with wave.open(str(OUT/(name+'.wav')),'wb') as w:
  w.setparams((1,2,SR,0,'NONE','not compressed'));w.writeframes((x*30000).astype('<i2').tobytes())
def make(kind,tier=0):
 duration={'win':.8,'start':.55,'pack':.48,'cash':.34,'fail':.36}.get(kind,.19)
 t=np.arange(int(SR*duration))/SR
 noise=rng.uniform(-1,1,len(t))
 smooth=np.convolve(noise,np.ones(5)/5,'same');rough=noise-smooth
 y=np.zeros_like(t)
 def strike(at,freq,decay,amp=1):
  u=np.maximum(0,t-at);active=t>=at
  return amp*active*(1-np.exp(-u*1800))*np.exp(-u*decay)*np.sin(2*np.pi*freq*u)
 if kind in ['click','select','hover','slide','shuffle','pack']:
  # Paper friction + a short wooden table contact; no sustained oscillator voice.
  envelope=(1-np.exp(-t*500))*np.exp(-t*(30 if kind=='hover' else 20))
  y=smooth*envelope*(.3 if kind=='hover' else .65)+rough*np.exp(-t*95)*.12
  y+=strike(.002,180 if kind=='slide' else 410,62,.25)
  if kind in ['pack','shuffle']:
   y=np.zeros_like(t)
   for at,amp in [(.0,.4),(.045,.8),(.12,.65),(.21,.35)]:
    u=np.maximum(0,t-at);y+=(t>=at)*rough*np.exp(-u*30)*amp
   y+=strike(.08,260,45,.3)
 elif kind=='merge':
  f=[240,280,330,390,465,550][tier]
  y=rough*np.exp(-t*95)*.45
  for ratio,amp,decay in [(1,.7,24),(1.51,.35,35),(2.39,.18,46)]:y+=strike(.005,f*ratio,decay,amp)
  y+=smooth*np.exp(-t*65)*.4
 elif kind in ['coin','buy','cash']:
  # Inharmonic bronze overtones and two separate contacts make a metal clink.
  for at,amp in [(0,1),(.045,.45)]:
   for f,a in [(1640,.45),(2715,.3),(4480,.12),(6700,.04)]:y+=strike(at,f,35+f/160,amp*a)
  y+=rough*np.exp(-t*170)*.2
  if kind=='cash': y+=strike(.12,1890,25,.25)
  if kind=='coin': y*=.3
 elif kind in ['win','start']:
  y=rough*np.exp(-t*85)*.08
  notes=[261.63,329.63,392,523.25] if kind=='win' else [293.66,440,587.33]
  for i,f in enumerate(notes):
   for ratio,a in [(1,.32),(2.01,.12),(3.98,.05)]:y+=strike(i*.065,f*ratio,9+i, a)
 elif kind=='fail':
  for f in [97,143,201]:y+=strike(0,f,14,.25)
  y+=smooth*np.exp(-t*32)*.65
 return y
for event in ['click','select','hover','slide','shuffle','pack','coin','buy','cash','win','start','fail']:
 write(event,make(event))
for tier in range(6):write('merge'+str(tier),make('merge',tier))
print('Wrote 18 original material sound cues')

const {chromium}=require('playwright');
const http=require('http'),fs=require('fs'),path=require('path'),assert=require('assert');
const web=path.resolve(__dirname,'../build/web'),out=path.resolve(__dirname,'../build/review');fs.mkdirSync(out,{recursive:true});
const server=http.createServer((req,res)=>{let p=path.join(web,new URL(req.url,'http://localhost').pathname);if(p.endsWith('/'))p+='index.html';res.setHeader('Content-Type',p.endsWith('.wasm')?'application/wasm':p.endsWith('.js')?'application/javascript':'application/octet-stream');if(p.endsWith('.html'))res.setHeader('Content-Type','text/html');fs.createReadStream(p).on('error',()=>res.end()).pipe(res)});
(async()=>{await new Promise(r=>server.listen(8768,'127.0.0.1',r));const browser=await chromium.launch({executablePath:process.env.GATEFOLD_CHROMIUM||chromium.executablePath(),args:['--no-sandbox','--enable-unsafe-swiftshader']});try{
 const page=await browser.newPage({viewport:{width:1440,height:900}}),errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/SCRIPT ERROR|Parse Error|^ERROR:/.test(m.text()))errors.push(m.text())});
 const q=()=>page.evaluate(()=>window.gatefoldQA);
 async function scene(s){await page.goto('http://127.0.0.1:8768/?qa='+s);await page.waitForFunction(s=>window.gatefoldQA?.scenario===s,s,{timeout:60000});await page.waitForTimeout(300);return q()}
 async function click(rect){const r=await q();await page.mouse.click((rect[0]+rect[2]/2)*1440/r.run_rect[2],(rect[1]+rect[3]/2)*900/r.run_rect[3]);await page.waitForTimeout(160)}
 for(const size of [{width:1440,height:900},{width:1366,height:768}]){
  await page.setViewportSize(size);
  for(const s of ['numbers_display','numbers_ee','numbers_layer','numbers_layers','numbers_hollow','numbers_hollow_selector']){
   const r=await scene(s);assert(!/Infinity|NaN/.test(r.score));
   if(!s.includes('selector')){assert(r.score_rect[2]<=188.01);assert(r.target_rect[2]<=188.01);assert(r.score_width<=r.score_rect[2]);assert(r.target_width<=r.target_rect[2]);}
   if(s==='numbers_ee'){assert(r.receipt.startsWith('+1e1.12202e248'));assert(r.receipt_detail.includes('10^('));assert(r.receipt_rect[2]<=300.01);assert(r.receipt_width<=r.receipt_rect[2]);}
   if(s==='numbers_display')assert.equal(r.score,'1.23457e4.56e7');
   if(s==='numbers_hollow'){assert(r.relics.includes('avalanche'));assert.equal(r.relic_timers[0],3);}
   await page.screenshot({path:path.join(out,s+'-'+size.width+'.png')});
  }
 }
 await page.setViewportSize({width:1440,height:900});
 let r=await scene('numbers_sale');const card=r.card_controls.find(c=>c.owner==='RelicRack'&&c.id==='singularity');assert(card);await click(card.rect);r=await q();const sell=r.dock_buttons.find(b=>b.text.startsWith('Sell'));assert(sell);await click(sell.rect);r=await q();assert.equal(r.ghostwriter,'1e12');assert(!r.relics.includes('singularity'));
 await scene('numbers_hollow_final');await page.keyboard.press('ArrowLeft');await page.waitForFunction(()=>!window.gatefoldQA.moving&&!window.gatefoldQA.scoring,null,{timeout:5000});r=await q();assert.equal(r.cleared,3);assert(!r.relics.includes('avalanche'));assert.equal(r.overlay,'result');
 assert.deepEqual(errors,[]);console.log('Browser huge-number, sale, Hollow and layout checks passed');
}finally{await browser.close();server.close()}})().catch(e=>{console.error(e);server.close();process.exitCode=1});

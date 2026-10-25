// Export tools/export_review.py first; production exports exclude this bridge.
const {chromium}=require('playwright');
const http=require('http'),fs=require('fs'),path=require('path'),assert=require('assert');
const web=path.resolve(__dirname,'../build/web'),output=path.resolve(__dirname,'../build/review');fs.mkdirSync(output,{recursive:true});
const server=http.createServer((req,res)=>{let p=path.join(web,new URL(req.url,'http://localhost').pathname);if(p.endsWith('/'))p+='index.html';res.setHeader('Cross-Origin-Opener-Policy','same-origin');res.setHeader('Cross-Origin-Embedder-Policy','require-corp');res.setHeader('Content-Type',p.endsWith('.wasm')?'application/wasm':p.endsWith('.js')?'application/javascript':'text/html');fs.createReadStream(p).on('error',()=>res.end()).pipe(res)});
(async()=>{
 await new Promise(r=>server.listen(8766,'127.0.0.1',r));
 const browser=await chromium.launch({executablePath:process.env.GATEFOLD_CHROMIUM||chromium.executablePath(),args:['--no-sandbox','--disable-dev-shm-usage','--enable-unsafe-swiftshader']});
 try{
  const page=await browser.newPage({viewport:{width:1440,height:900}});const errors=[];
  page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/SCRIPT ERROR|Parse Error|^ERROR:/.test(m.text()))errors.push(m.text())});
  let score,hash;
  for(const scenario of ['scoring_huge','scoring_huge_2x','scoring_huge_4x','scoring_huge_fast','scoring_huge_reduced']){
   await page.goto('http://127.0.0.1:8766/?qa='+scenario);
   await page.waitForFunction(s=>window.gatefoldQA?.scenario===s,scenario,{timeout:60000});
   await page.keyboard.press('ArrowLeft');
   if(scenario==='scoring_huge'){
    await page.waitForFunction(()=>window.gatefoldQA.scoring);
    await page.waitForTimeout(300);
    await page.screenshot({path:path.join(output,'retriggers-active.png')});
    const active=await page.evaluate(()=>window.gatefoldQA);
    assert(active.scoring_queue<=112);assert(active.receipt&&!/NaN|Infinity/.test(active.receipt));
   }
   await page.waitForFunction(()=>!window.gatefoldQA.moving&&!window.gatefoldQA.scoring,null,{timeout:5000});
   const result=await page.evaluate(()=>window.gatefoldQA);
   assert.equal(result.triggers,'663552');assert(!/NaN|Infinity/.test(result.score));assert.equal(result.score_text,result.score);
   if(score){assert.equal(result.score,score);assert.equal(result.state_hash,hash)}else{score=result.score;hash=result.state_hash;await page.screenshot({path:path.join(output,'retriggers-settled.png')})}
   if(scenario.endsWith('fast')||scenario.endsWith('reduced'))assert.equal(result.scoring_count,0);
   console.log(scenario,':',result.triggers,'triggers,',result.score,'points; identical saved state');
  }
  assert.deepEqual(errors,[]);console.log('Browser retrigger acceptance passed');
 }finally{await browser.close();server.close()}
})().catch(e=>{console.error(e);server.close();process.exitCode=1});

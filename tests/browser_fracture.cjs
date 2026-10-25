// Optional Playwright browser acceptance checks. Export the review build first.
const {chromium}=require('playwright');
const http=require('http'),fs=require('fs'),path=require('path'),assert=require('assert');
const root=path.resolve(__dirname,'../build/web');
const reviewDir=path.resolve(process.env.GATEFOLD_QA_OUTPUT||path.join(__dirname,'../build/review'));fs.mkdirSync(reviewDir,{recursive:true});
const server=http.createServer((req,res)=>{let p=path.join(root,new URL(req.url,'http://localhost').pathname);if(p.endsWith('/'))p+='index.html';res.setHeader('Cross-Origin-Opener-Policy','same-origin');res.setHeader('Cross-Origin-Embedder-Policy','require-corp');res.setHeader('Content-Type',p.endsWith('.wasm')?'application/wasm':p.endsWith('.html')?'text/html':p.endsWith('.js')?'application/javascript':'application/octet-stream');fs.createReadStream(p).on('error',()=>res.end()).pipe(res)});
(async()=>{
 await new Promise(r=>server.listen(8765,'127.0.0.1',r));
 const browser=await chromium.launch({executablePath:process.env.GATEFOLD_CHROMIUM||chromium.executablePath(),args:['--no-sandbox','--no-zygote','--single-process','--disable-dev-shm-usage','--disable-crash-reporter','--enable-unsafe-swiftshader']});
 const page=await browser.newPage({viewport:{width:1440,height:900}});let errors=[];page.on('console',m=>{if(/SCRIPT ERROR|Parse Error|^ERROR:/.test(m.text()))errors.push(m.text())});page.on('pageerror',e=>errors.push(e.message));
 const q=()=>page.evaluate(()=>window.gatefoldQA);
 const wait=ms=>page.waitForTimeout(ms);
 async function scene(s){await page.goto('http://127.0.0.1:8765/?qa='+s);await page.waitForFunction(s=>window.gatefoldQA?.scenario===s,s,{timeout:60000});await wait(450);return q()}
 async function rect(r){let x=await q(),v=page.viewportSize();await page.mouse.click((r[0]+r[2]/2)*v.width/x.run_rect[2],(r[1]+r[3]/2)*v.height/x.run_rect[3]);await wait(160)}
 async function btn(text){const r=await q();const b=r.ui_buttons.find(b=>b.text===text&&!b.disabled);assert(b,`Missing button ${text}: ${r.ui_buttons.map(b=>b.text)}`);await rect(b.rect)}
 async function card(id){const r=await q();const b=r.card_controls.find(b=>b.id===id);assert(b,`missing ${id}`);await rect(b.rect)}
 if(!process.argv.includes('--quick')) for(const s of ['fracture_selector','fracture_nomad','fracture_shop','fracture_pack','fracture_target','fracture_workshop','fracture_dense','fracture_blocked']){await scene(s);await page.screenshot({path:path.join(reviewDir,s+'-review.png')});}
 await scene('fracture_nomad');await btn('Take');let r=await q();assert.equal(r.overlay,'gates');assert.equal(r.relics.length,2);console.log('Nomad buttons',r.ui_buttons.map(b=>b.text));
 await scene('fracture_shop');r=await q();let hash=r.state_hash;await rect(r.board_button_rect);r=await q();assert.equal(r.overlay,'board');assert.equal(r.state_hash,hash);console.log('Board buttons',r.ui_buttons.map(b=>b.text));await btn('Back to shop');assert.equal((await q()).state_hash,hash);
 await card('carbon');r=await q();assert(r.context&&r.dock_buttons.some(b=>b.text.startsWith('Sell')));await card('carbon');assert(!(await q()).context);console.log('Item repeat click closes');
 await card('echo');await page.screenshot({path:path.join(reviewDir,'fracture-tooltip.png')});await btn('Close');
 await btn('Offers >');assert((await q()).card_controls.some(c=>c.id==='mobius'));console.log('Extra offers retain full-sized cards');
 await scene('fracture_pack');r=await q();assert.equal(r.pack_remaining,2);assert.equal(r.money,'70');hash=r.state_hash;await rect(r.board_button_rect);await btn('Back to pack');assert.equal((await q()).state_hash,hash);assert.equal((await q()).overlay,'pack');await btn('TAKE');assert.equal((await q()).pack_remaining,1);assert.equal((await q()).overlay,'pack');
 await card('venus');r=await q();let sell=r.dock_buttons.find(b=>b.text.startsWith('Sell'));assert(sell);await rect(sell.rect);assert.equal((await q()).overlay,'pack');await btn('TAKE');r=await q();assert.equal(r.overlay,'shop');assert.equal(r.pack_remaining,0);assert.equal(r.pack_offers[0].bought,true);console.log('Mega pick, Board detour, sell for space, second pick');
 await scene('fracture_target');r=await q();let board=r.boards.find(b=>b.name==='TargetBoard');assert(board);await rect([board.rect[0]+10,board.rect[1]+10,90,90]);r=await q();assert.equal(r.overlay,'shop');assert(!r.inventory.includes('genesis'));assert.equal(r.cells.filter(Boolean).length,5);console.log('Genesis tile targeting commits once');
 await scene('fracture_shop');await card('liberation');await btn('Use');await btn('Transform');r=await q();assert.equal(r.overlay,'shop');assert(!r.inventory.includes('liberation'));console.log('Relic transformation through picker');
 await scene('fracture_dense');r=await q();assert.equal(r.card_controls.filter(c=>c.owner==='RelicRack').length,r.relics.length);assert(!r.ui_buttons.some(b=>/1 \/ 3/.test(b.text)));console.log('All relics visible in one row');
 await scene('fracture_vortex');await page.keyboard.press('ArrowLeft');await wait(200);await page.screenshot({path:path.join(reviewDir,'fracture-vortex-turn.png')});await wait(4000);assert(!(await q()).moving);
 await scene('scoring');await page.keyboard.press('ArrowLeft');await wait(220);r=await q();assert(r.scoring&&r.score_text==='20');await wait(220);await page.screenshot({path:path.join(reviewDir,'scoring-active.png')});await wait(4200);r=await q();assert(!r.moving&&!r.scoring&&r.score_text===r.score);let total=r.score;console.log('Scoring settles exact total',total);
 await scene('scoring_fast');await page.keyboard.press('ArrowLeft');await wait(300);r=await q();assert(!r.moving&&!r.scoring&&r.scoring_count===0&&r.score===total);console.log('8x bypass retains identical score');
 await page.setViewportSize({width:1366,height:768});for(const s of ['fracture_selector','fracture_shop','fracture_pack','fracture_dense']){await scene(s);await page.screenshot({path:path.join(reviewDir,s+'-laptop-review.png')});}
 await scene('live');await btn('NEW RUN');await btn('Cursed');
 // Seed is a canvas LineEdit; select its center in the logical new-run panel.
 r=await q();await rect([r.panel_rect[0]+404,r.panel_rect[1]+698,220,60]);await page.keyboard.type('WAKE-FRACTURE');await btn('Start run');r=await q();assert.equal(r.overlay,'gates');assert.equal(r.difficulty,'cursed');assert.equal(r.run_seed,'WAKE-FRACTURE');
 await btn('Enter gate');await page.keyboard.press('ArrowLeft');await wait(4000);r=await q();assert(r.phase==='play'||r.phase==='reward');hash=r.state_hash;let savedBoard=r.board_id;
 // A reload passes through the real persistence layer and the home Continue button.
 await page.reload();await page.waitForFunction(()=>window.gatefoldQA?.scenario==='live');await wait(650);await btn('CONTINUE');r=await q();assert.equal(r.state_hash,hash);assert.equal(r.board_id,savedBoard);assert.equal(r.run_seed,'WAKE-FRACTURE');assert.equal(r.difficulty,'cursed');await page.screenshot({path:path.join(reviewDir,'fracture-save-reloaded.png')});console.log('Real seeded Cursed run persists through browser reload');

 assert.deepStrictEqual(errors,[]);console.log('PASS no browser runtime errors');await browser.close();server.close();
})().catch(e=>{console.error(e);server.close();process.exit(1)});

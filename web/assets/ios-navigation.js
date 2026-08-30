(() => {
  const isIOSApp = () => !!window.Capacitor?.isNativePlatform?.() && window.Capacitor?.getPlatform?.() === 'ios';
  const groups = {
    forward: [
      ['主机管理','服务器与 Agent','/hosts','server'],
      ['链路管理','隧道、转发链与转发组','/tunnels','route'],
      ['转发规则','端口、目标与流量规则','/rules','arrows']
    ],
    manage: [
      ['用户管理','用户、权限与额度','/users','users'],['套餐管理','套餐与订阅','/plans','box'],
      ['支付对接','支付通道与订单','/payments','card'],['账单与兑换','余额、账单与兑换码','/billing','wallet'],
      ['流量计费','流量资源与计费','/traffic-billing','chart'],['插件管理','插件、商店与扩展','/plugins','puzzle'],
      ['Agent Token','在系统设置中管理','/settings','key'],['公告','公告与消息','/announcements','bell'],
      ['网络测试','Looking Glass','/looking-glass','globe'],['个人资料','账户与安全','/profile','user'],
      ['应用商店','购买套餐','/store','store'],['我的订阅','订阅与有效期','/subscriptions','receipt'],
      ['我的钱包','余额与交易','/wallet','wallet']
    ],
    me: [
      ['个人资料','头像、密码与安全','/profile','user'],['系统设置','面板、通知与服务','/settings','settings'],
      ['公告','查看公告消息','/announcements','bell'],['网络测试','诊断网络质量','/looking-glass','globe']
    ]
  };
  const icons = {
    dashboard:'⌂', forward:'⇄', manage:'▦', me:'●', server:'▤', route:'⌁', arrows:'⇆', users:'♚', box:'◇', card:'▭', wallet:'◉', chart:'⌁', puzzle:'✣', key:'⌘', bell:'♢', globe:'◎', user:'●', store:'▣', receipt:'▧', settings:'⚙'
  };
  function go(path){ closeHub(); history.pushState({},'',path); dispatchEvent(new PopStateEvent('popstate')); setTimeout(markActive,60); }
  function itemHTML(x){ return `<button class="fx-hub-item" data-path="${x[2]}"><span class="fx-round-icon">${icons[x[3]]||'•'}</span><b>${x[0]}</b><small>${x[1]}</small></button>`; }
  function openHub(kind){
    closeHub(); const wrap=document.createElement('div'); wrap.id='fx-ios-hub';
    const title=kind==='forward'?'转发中心':kind==='manage'?'管理中心':'我的';
    wrap.innerHTML=`<div class="fx-hub-mask"></div><section class="fx-hub-sheet"><i></i><header><div><h2>${title}</h2><p>${kind==='forward'?'主机、链路与规则集中管理':kind==='manage'?'ForwardX 全部业务功能':'账户与系统'}</p></div><button class="fx-hub-close">×</button></header><div class="fx-hub-grid">${groups[kind].map(itemHTML).join('')}</div></section>`;
    document.body.appendChild(wrap); requestAnimationFrame(()=>wrap.classList.add('show'));
    wrap.querySelector('.fx-hub-mask').onclick=closeHub; wrap.querySelector('.fx-hub-close').onclick=closeHub;
    wrap.querySelectorAll('[data-path]').forEach(b=>b.onclick=()=>go(b.dataset.path));
  }
  function closeHub(){ const e=document.getElementById('fx-ios-hub'); if(e){e.classList.remove('show');setTimeout(()=>e.remove(),180)} }
  function markActive(){
    const p=location.pathname; document.querySelectorAll('#fx-ios-tabbar button').forEach(x=>x.classList.remove('active'));
    const k=p==='/'?'dashboard':['/hosts','/tunnels','/rules','/forward-groups'].some(x=>p.startsWith(x))?'forward':p==='/settings'||p==='/profile'?'me':'manage';
    document.querySelector(`#fx-ios-tabbar [data-tab="${k}"]`)?.classList.add('active');
  }
  function makeTabs(){
    if(document.getElementById('fx-ios-tabbar'))return;
    const nav=document.createElement('nav');nav.id='fx-ios-tabbar';
    nav.innerHTML=[['dashboard','仪表盘'],['forward','转发'],['manage','管理'],['me','我的']].map(x=>`<button data-tab="${x[0]}"><span>${icons[x[0]]}</span><b>${x[1]}</b></button>`).join('');
    document.body.appendChild(nav);
    nav.querySelector('[data-tab="dashboard"]').onclick=()=>go('/');
    ['forward','manage','me'].forEach(k=>nav.querySelector(`[data-tab="${k}"]`).onclick=()=>openHub(k));markActive();
  }
  function dashboardGrid(){
    if(location.pathname!=='/'||document.getElementById('fx-dashboard-grid'))return;
    const h=[...document.querySelectorAll('h1')].find(x=>x.textContent.trim()==='仪表盘'); if(!h)return;
    const host=h.parentElement?.parentElement; if(!host)return;
    const box=document.createElement('div');box.id='fx-dashboard-grid';
    box.innerHTML=[['主机','/hosts','server'],['链路','/tunnels','route'],['规则','/rules','arrows'],['用户','/users','users'],['套餐','/plans','box'],['账单','/billing','wallet'],['插件','/plugins','puzzle'],['设置','/settings','settings']].map(x=>`<button data-path="${x[1]}"><span>${icons[x[2]]}</span><b>${x[0]}</b></button>`).join('');
    host.insertAdjacentElement('afterend',box);box.querySelectorAll('button').forEach(b=>b.onclick=()=>go(b.dataset.path));
  }
  function boot(){ if(!isIOSApp())return; document.documentElement.classList.add('fx-ios-native'); makeTabs();dashboardGrid(); new MutationObserver(()=>{makeTabs();dashboardGrid();markActive()}).observe(document.getElementById('root')||document.body,{childList:true,subtree:true}); addEventListener('popstate',()=>setTimeout(()=>{markActive();dashboardGrid()},50)); }
  document.readyState==='loading'?document.addEventListener('DOMContentLoaded',()=>setTimeout(boot,100)):setTimeout(boot,100);
})();

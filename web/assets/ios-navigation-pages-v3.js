(() => {
  const isIOS = () => !!window.Capacitor?.isNativePlatform?.() && window.Capacitor?.getPlatform?.() === 'ios';
  const groups = {
    forward: { title:'转发', sub:'主机、链路和规则', items:[
      ['主机管理','服务器、Agent、状态与流量','/hosts','server'],
      ['链路管理','隧道、转发链与转发组','/tunnels','route'],
      ['转发规则','端口、目标、协议与流量','/rules','arrows']
    ]},
    manage: { title:'管理', sub:'业务、用户和扩展服务', items:[
      ['用户管理','权限与额度','/users','users'],['套餐管理','套餐与订阅','/plans','box'],
      ['支付对接','支付通道与订单','/payments','card'],['账单与兑换','余额与兑换码','/billing','wallet'],
      ['流量计费','资源与计费','/traffic-billing','chart'],['插件管理','插件与扩展','/plugins','puzzle'],
      ['Agent Token','节点接入凭据','/settings','key'],['公告','公告与消息','/announcements','bell'],
      ['网络测试','Looking Glass','/looking-glass','globe'],['个人资料','账户与安全','/profile','user'],
      ['应用商店','购买套餐','/store','store'],['我的订阅','订阅与有效期','/subscriptions','receipt'],
      ['我的钱包','余额与交易','/wallet','wallet']
    ]},
    me: { title:'我的', sub:'账户、外观和系统', items:[
      ['个人资料','头像、密码与安全','/profile','user'],['系统设置','面板、通知与服务','/settings','settings'],
      ['公告','查看公告消息','/announcements','bell'],['网络测试','诊断网络质量','/looking-glass','globe'],
      ['我的订阅','订阅与有效期','/subscriptions','receipt'],['我的钱包','余额与交易','/wallet','wallet']
    ]}
  };
  const glyph={dashboard:'⌂',forward:'⇄',manage:'▦',me:'●',server:'▤',route:'⌁',arrows:'⇆',users:'♚',box:'◇',card:'▭',wallet:'◉',chart:'⌁',puzzle:'✣',key:'⌘',bell:'♢',globe:'◎',user:'●',store:'▣',receipt:'▧',settings:'⚙'};
  const virtual={forward:'#fx-forward',manage:'#fx-manage',me:'#fx-me'};
  let currentVirtual='';
  function reactNavigate(path){ removeSection(); currentVirtual=''; history.pushState({},'',path); dispatchEvent(new PopStateEvent('popstate')); setTimeout(mark,80); }
  function item(x){return `<button class="fx-page-item" data-path="${x[2]}"><span class="fx-page-icon">${glyph[x[3]]||'•'}</span><span class="fx-page-copy"><b>${x[0]}</b><small>${x[1]}</small></span><em>›</em></button>`}
  function showSection(kind,push=true){
    const g=groups[kind]; if(!g)return; currentVirtual=kind;
    document.documentElement.classList.add('fx-section-active');
    let page=document.getElementById('fx-section-page');if(!page){page=document.createElement('main');page.id='fx-section-page';document.body.appendChild(page)}
    page.innerHTML=`<div class="fx-section-aurora a"></div><div class="fx-section-aurora b"></div><header><div><p>ForwardX · 四栏页面</p><h1>${g.title}</h1><span>${g.sub}</span></div><div class="fx-header-orb">${glyph[kind]}</div></header><section class="fx-page-grid ${kind}">${g.items.map(item).join('')}</section>`;
    page.querySelectorAll('[data-path]').forEach(b=>b.onclick=()=>reactNavigate(b.dataset.path));
    if(push && location.hash!==virtual[kind]) history.pushState({fxSection:kind},'',virtual[kind]); mark();
  }
  function removeSection(){document.documentElement.classList.remove('fx-section-active');document.getElementById('fx-section-page')?.remove()}
  function sectionFromPath(){return Object.keys(virtual).find(k=>virtual[k]===location.hash)||''}
  function mark(){const p=location.pathname,k=currentVirtual||sectionFromPath()||(p==='/'?'dashboard':['/hosts','/tunnels','/rules','/forward-groups'].some(x=>p.startsWith(x))?'forward':p==='/settings'||p==='/profile'?'me':'manage');document.querySelectorAll('#fx-ios-tabbar button').forEach(x=>x.classList.toggle('active',x.dataset.tab===k))}
  function tab(kind){if(kind==='dashboard'){reactNavigate('/');return}showSection(kind)}
  function tabs(){if(document.getElementById('fx-ios-tabbar'))return;const nav=document.createElement('nav');nav.id='fx-ios-tabbar';nav.innerHTML=[['dashboard','仪表盘'],['forward','转发'],['manage','管理'],['me','我的']].map(x=>`<button data-tab="${x[0]}" aria-label="${x[1]}"><i></i><b>${x[1]}</b></button>`).join('')+'<i class="fx-tab-lens"></i>';document.body.appendChild(nav);nav.querySelectorAll('button').forEach(b=>b.onclick=()=>tab(b.dataset.tab));mark()}
  function dashboardGrid(){if(location.pathname!=='/'||document.getElementById('fx-dashboard-grid'))return;const h=[...document.querySelectorAll('h1')].find(x=>x.textContent.trim()==='仪表盘');const host=h?.parentElement?.parentElement;if(!host)return;const box=document.createElement('div');box.id='fx-dashboard-grid';box.innerHTML=[['主机','/hosts','server'],['链路','/tunnels','route'],['规则','/rules','arrows'],['用户','/users','users'],['套餐','/plans','box'],['账单','/billing','wallet'],['插件','/plugins','puzzle'],['设置','/settings','settings']].map(x=>`<button data-path="${x[1]}"><span>${glyph[x[2]]}</span><b>${x[0]}</b></button>`).join('');host.insertAdjacentElement('afterend',box);box.querySelectorAll('button').forEach(b=>b.onclick=()=>reactNavigate(b.dataset.path))}
  function routeChanged(){const s=sectionFromPath();if(s)showSection(s,false);else if(currentVirtual)removeSection(),currentVirtual='';mark();dashboardGrid()}
  function boot(){if(!isIOS())return;document.documentElement.classList.add('fx-ios-native','fx-nav-pages-v3');document.body.dataset.fxNavigation='pages-v3';tabs();routeChanged();new MutationObserver(()=>{tabs();if(!currentVirtual)dashboardGrid();mark()}).observe(document.getElementById('root')||document.body,{childList:true,subtree:true});addEventListener('popstate',()=>setTimeout(routeChanged,40))}
  document.readyState==='loading'?document.addEventListener('DOMContentLoaded',()=>setTimeout(boot,100)):setTimeout(boot,100);
})();

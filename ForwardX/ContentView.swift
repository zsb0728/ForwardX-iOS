import SwiftUI

struct ContentView: View {
    @State private var store = ForwardXStore()
    var body: some View { ZStack { LiquidBackground(); if store.signedIn { MainShell(store:store) } else { LoginView(store:store) } }.alert("ForwardX",isPresented:Binding(get:{!store.error.isEmpty},set:{if !$0{store.error=""}})){Button("好"){store.error=""}} message:{Text(store.error)} }
}

struct LoginView: View {
    @Bindable var store:ForwardXStore
    @State private var username = ""
    @State private var password = ""
    var body: some View { ScrollView { VStack(spacing:28) {
        Spacer().frame(height:60)
        Image("AppIconImage").resizable().scaledToFit().frame(width:92,height:92).clipShape(RoundedRectangle(cornerRadius:24)).shadow(color:.blue.opacity(0.25),radius:24,y:12)
        VStack(spacing:6){Text("ForwardX").font(.largeTitle.bold());Text("掌控每一条链路").foregroundStyle(.secondary)}
        GlassCard { VStack(spacing:18) {
            TextField("用户名或邮箱",text:$username).textContentType(.username).textInputAutocapitalization(.never).padding().background(.white.opacity(0.08),in:RoundedRectangle(cornerRadius:16))
            SecureField("密码",text:$password).textContentType(.password).padding().background(.white.opacity(0.08),in:RoundedRectangle(cornerRadius:16))
            Button { Task { _ = await store.login(username:username,password:password) } } label: { HStack { if store.loading { ProgressView().tint(.white) }; Text(store.loading ? "正在连接":"登录").bold() }.frame(maxWidth:.infinity).padding().foregroundStyle(.white).background(.blue.gradient,in:Capsule()) }.disabled(username.isEmpty || password.isEmpty || store.loading)
        }}
        Text("安全连接 · vps.na21.icu").font(.caption).foregroundStyle(.secondary)
    }.padding(24) }.scrollDismissesKeyboard(.interactively) }
}

struct MainShell: View {
    @Bindable var store:ForwardXStore
    var body: some View { TabView {
        NavigationStack { DashboardView(store:store) }.tabItem{Label("概览",systemImage:"square.grid.2x2.fill")}
        NavigationStack { ItemsView(store:store,kind:.hosts) }.tabItem{Label("主机",systemImage:"server.rack")}
        NavigationStack { ItemsView(store:store,kind:.rules) }.tabItem{Label("规则",systemImage:"arrow.left.arrow.right")}
        NavigationStack { ItemsView(store:store,kind:.tunnels) }.tabItem{Label("链路",systemImage:"point.3.connected.trianglepath.dotted")}
        NavigationStack { AccountView(store:store) }.tabItem{Label("我的",systemImage:"person.crop.circle")}
    }.task{await store.refresh()}.tint(.blue) }
}

struct DashboardView: View {
    @Bindable var store:ForwardXStore
    var body: some View { ScrollView { VStack(spacing:16) {
        HStack { VStack(alignment:.leading){Text("欢迎回来").foregroundStyle(.secondary);Text(store.user.text("name","username")).font(.largeTitle.bold())};Spacer();Button{Task{await store.refresh()}}label:{Image(systemName:"arrow.clockwise").padding(12).modifier(GlassButtonModifier())} }
        HStack(spacing:12){ MetricCard(title:"主机",value:"\(Int(store.stats.num("totalHosts","hostCount")))",icon:"server.rack",color:.blue);MetricCard(title:"规则",value:"\(Int(store.stats.num("totalRules","ruleCount")))",icon:"arrow.left.arrow.right",color:.purple) }
        HStack(spacing:12){ MetricCard(title:"上行流量",value:bytes(store.traffic.num("totalTrafficOut")),icon:"arrow.up",color:.orange);MetricCard(title:"下行流量",value:bytes(store.traffic.num("totalTrafficIn")),icon:"arrow.down",color:.cyan) }
        GlassCard { VStack(alignment:.leading,spacing:14){Label("网络态势",systemImage:"waveform.path.ecg").font(.headline);HStack{StatusPill(online:true);Text("\(store.hosts.count) 台主机 · \(store.tunnels.count) 条链路").foregroundStyle(.secondary);Spacer()};ProgressView(value:store.hosts.isEmpty ? 0:Double(store.hosts.filter{$0.data.flag("online","isOnline")}.count),total:max(1,Double(store.hosts.count))).tint(.green)} }
        GlassCard { VStack(alignment:.leading,spacing:12){Text("快捷入口").font(.headline);HStack{Quick(icon:"plus",title:"新建规则",color:.blue);Quick(icon:"link",title:"链路",color:.purple);Quick(icon:"chart.xyaxis.line",title:"流量",color:.cyan)} } }
    }.padding() }.navigationTitle("概览").toolbarBackground(.hidden,for:.navigationBar).refreshable{await store.refresh()} }
}
struct Quick:View{let icon,title:String;let color:Color;var body:some View{VStack(spacing:8){Image(systemName:icon).font(.title2).foregroundStyle(color).frame(width:48,height:48).background(color.opacity(0.12),in:Circle());Text(title).font(.caption)}.frame(maxWidth:.infinity)}}

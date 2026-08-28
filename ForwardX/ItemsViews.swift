import SwiftUI

enum ItemKind { case hosts,rules,tunnels
    var title:String { switch self {case .hosts:"主机";case .rules:"转发规则";case .tunnels:"链路与隧道"} }
    var icon:String { switch self {case .hosts:"server.rack";case .rules:"arrow.left.arrow.right";case .tunnels:"point.3.connected.trianglepath.dotted"} }
}

struct ItemsView: View {
    @Bindable var store:ForwardXStore; let kind:ItemKind
    @State private var search=""
    var source:[FXItem] { switch kind {case .hosts:store.hosts;case .rules:store.rules;case .tunnels:store.tunnels} }
    var filtered:[FXItem] { search.isEmpty ? source : source.filter{$0.data.text("name","remark","address","targetAddress").localizedCaseInsensitiveContains(search)} }
    var body: some View { ScrollView { LazyVStack(spacing:14) {
        if filtered.isEmpty { EmptyState(icon:kind.icon,title:"暂无\(kind.title)",detail:"数据会从 ForwardX 面板实时同步") }
        ForEach(filtered) { item in switch kind {case .hosts:HostCard(item:item);case .rules:RuleCard(store:store,item:item);case .tunnels:TunnelCard(item:item)} }
    }.padding() }.navigationTitle(kind.title).searchable(text:$search,prompt:"搜索").refreshable{await store.refresh()}.toolbar{ToolbarItem(placement:.topBarTrailing){Button{ }label:{Image(systemName:"plus").padding(8).modifier(GlassButtonModifier())}}} }
}

struct HostCard: View { let item:FXItem
    var online:Bool { item.data.flag("online","isOnline","agentOnline") }
    var body:some View { NavigationLink { ItemDetail(title:item.data.text("name"),item:item) } label:{ GlassCard { VStack(alignment:.leading,spacing:14){HStack{Image(systemName:"server.rack").font(.title2).foregroundStyle(.blue);VStack(alignment:.leading){Text(item.data.text("name")).font(.headline).foregroundStyle(.primary);Text(item.data.text("address","ip","publicIp")).font(.caption).foregroundStyle(.secondary)};Spacer();StatusPill(online:online)};Divider().opacity(0.4);HStack{Mini(label:"CPU",value:"\(Int(item.data.num("cpuUsage","cpu")))%");Mini(label:"内存",value:"\(Int(item.data.num("memoryUsage","memory")))%");Mini(label:"流量",value:bytes(item.data.num("trafficOut","totalTraffic")))} } } }.buttonStyle(.plain) }
}

struct RuleCard:View { @Bindable var store:ForwardXStore;let item:FXItem
    var active:Bool{item.data.flag("isEnabled","enabled")}
    var body:some View{GlassCard{VStack(alignment:.leading,spacing:14){HStack{ZStack{Circle().fill((active ? Color.green:Color.gray).opacity(0.13));Image(systemName:"arrow.left.arrow.right").foregroundStyle(active ? .green:.secondary)}.frame(width:44,height:44);VStack(alignment:.leading){Text(item.data.text("name","remark")).font(.headline);Text("\(item.data.text("listenPort","port")) → \(item.data.text("targetAddress","targetHost")):\(item.data.text("targetPort"))").font(.caption).foregroundStyle(.secondary)};Spacer();Toggle("",isOn:Binding(get:{active},set:{_ in Task{await store.toggleRule(item)}})).labelsHidden()};HStack{Text(item.data.text("protocol","type").uppercased()).font(.caption.bold()).padding(.horizontal,9).padding(.vertical,5).background(.blue.opacity(0.12),in:Capsule());Spacer();Text(bytes(item.data.num("trafficIn")+item.data.num("trafficOut"))).font(.caption).foregroundStyle(.secondary)}}}}
}
struct TunnelCard:View{let item:FXItem;var active:Bool{item.data.flag("isEnabled","enabled","available")};var body:some View{NavigationLink{ItemDetail(title:item.data.text("name"),item:item)}label:{GlassCard{VStack(alignment:.leading,spacing:14){HStack{Image(systemName:"point.3.connected.trianglepath.dotted").font(.title2).foregroundStyle(.purple);VStack(alignment:.leading){Text(item.data.text("name")).font(.headline).foregroundStyle(.primary);Text(item.data.text("type","protocol")).font(.caption).foregroundStyle(.secondary)};Spacer();StatusPill(online:active)};HStack{Text(item.data.text("entryHostName","entryAddress")).lineLimit(1);Image(systemName:"arrow.right").foregroundStyle(.secondary);Text(item.data.text("exitHostName","exitAddress")).lineLimit(1)}}}}.buttonStyle(.plain)}}
struct Mini:View{let label,value:String;var body:some View{VStack(alignment:.leading,spacing:3){Text(value).font(.subheadline.bold());Text(label).font(.caption2).foregroundStyle(.secondary)}.frame(maxWidth:.infinity,alignment:.leading)}}
struct ItemDetail:View{let title:String;let item:FXItem;var body:some View{ScrollView{GlassCard{VStack(alignment:.leading,spacing:14){ForEach(item.data.keys.sorted(),id:\.self){k in if let value=item.data[k]?.string{HStack(alignment:.top){Text(k).foregroundStyle(.secondary);Spacer();Text(value).multilineTextAlignment(.trailing)}}}}}.padding()}.navigationTitle(title)}}

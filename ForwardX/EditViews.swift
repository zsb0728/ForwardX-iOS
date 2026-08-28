import SwiftUI

struct CompactEditView: View {
    @Bindable var store: ForwardXStore; let kind: ItemKind; let item: FXItem
    @Environment(\.dismiss) private var dismiss
    @State private var name = "", address = "", targetPort = "", listenPort = ""
    var body: some View {
        Form {
            Section("基本信息") {
                TextField("名称", text: $name)
                if kind == .hosts { TextField("IP 或域名", text: $address).textInputAutocapitalization(.never) }
                if kind == .rules { TextField("目标地址", text: $address).textInputAutocapitalization(.never); TextField("目标端口",text:$targetPort).keyboardType(.numberPad) }
                if kind == .tunnels { TextField("监听端口", text: $listenPort).keyboardType(.numberPad) }
            }
            Section { Button("保存") { Task { var f:[String:JSONValue] = ["name":.string(name)]; if kind == .hosts { f["ip"] = .string(address) }; if kind == .rules { f["targetIp"] = .string(address); if let p=Double(targetPort){f["targetPort"] = .number(p)} }; if kind == .tunnels, let p=Double(listenPort){f["listenPort"] = .number(p)}; if await store.update(kind,item:item,fields:f){dismiss()} } }.frame(maxWidth:.infinity) }
        }.navigationTitle("编辑\(kind.title)").navigationBarTitleDisplayMode(.inline).onAppear { name=item.data.text("name","remark"); address = kind == .hosts ? item.data.text("ip","address") : item.data.text("targetIp","targetAddress"); targetPort=item.data.text("targetPort"); listenPort=item.data.text("listenPort") }
    }
}

struct ManageDetailView: View {
    @Bindable var store:ForwardXStore; let kind:ItemKind; let item:FXItem
    @State private var confirmDelete=false
    var body:some View { List {
        Section { NavigationLink("编辑",destination:CompactEditView(store:store,kind:kind,item:item)); if kind == .rules { Button(item.data.flag("isEnabled","enabled") ? "停用":"启用"){Task{await store.toggleRule(item)}} }; Button("删除",role:.destructive){confirmDelete=true} }
        Section("详情") { ForEach(item.data.keys.sorted(),id:\.self){k in if let value=item.data[k]?.string { LabeledContent(k,value:value) } } }
    }.navigationTitle(item.data.text("name","remark")).navigationBarTitleDisplayMode(.inline).confirmationDialog("确定删除？",isPresented:$confirmDelete,titleVisibility:.visible){Button("删除",role:.destructive){Task{await store.delete(kind,item:item)}}} }
}

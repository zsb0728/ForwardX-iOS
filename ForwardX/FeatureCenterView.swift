import SwiftUI

struct FeatureCenterView: View {
    @Bindable var store: ForwardXStore
    @State private var search = ""
    private var filtered: [FXOperation] { search.isEmpty ? forwardXOperations : forwardXOperations.filter { $0.path.localizedCaseInsensitiveContains(search) } }
    private var modules: [String] { Array(Set(filtered.map(\.module))).sorted() }
    var body: some View {
        List {
            ForEach(modules, id: \.self) { module in
                Section(moduleTitle(module)) {
                    ForEach(filtered.filter { $0.module == module }) { op in
                        NavigationLink { OperationView(store: store, operation: op) } label: {
                            OperationRow(operation: op, module: module)
                        }
                    }
                }
            }
        }.navigationTitle("全部功能").searchable(text: $search, prompt: "搜索 255 项功能")
    }
}

struct OperationRow: View {
    let operation: FXOperation; let module: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: moduleIcon(module)).foregroundStyle(.blue).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) { Text(operationTitle(operation.name)).font(.subheadline); Text(operation.path).font(.caption2).foregroundStyle(.secondary) }
            Spacer()
            Text(operation.mutation ? "操作" : "查询").font(.caption2.bold()).foregroundStyle(operation.mutation ? Color.orange : Color.cyan)
        }.padding(.vertical, 2)
    }
}

struct OperationView: View {
    @Bindable var store: ForwardXStore; let operation: FXOperation
    @State private var input = "{}"
    @State private var output = ""
    @State private var running = false
    var body: some View {
        Form {
            Section("接口") { LabeledContent("功能", value: operationTitle(operation.name)); LabeledContent("路径", value: operation.path); LabeledContent("类型", value: operation.mutation ? "写入操作" : "数据查询") }
            Section("参数 JSON") { TextEditor(text: $input).font(.system(.caption, design: .monospaced)).frame(minHeight: 130); Text("无参数请输入 null；对象参数使用 {\"id\":1} 格式。服务端会执行权限和字段校验。").font(.caption2).foregroundStyle(.secondary) }
            Section { Button { Task { running=true; defer{running=false}; do { output = try await store.execute(operation.path,inputText:input,mutation:operation.mutation) } catch { output=error.localizedDescription } } } label: { HStack { if running { ProgressView() }; Text(running ? "正在执行…":"执行").frame(maxWidth:.infinity) } }.disabled(running) }
            if !output.isEmpty { Section("服务器结果") { ScrollView(.horizontal) { Text(output).font(.system(.caption2,design:.monospaced)).textSelection(.enabled) } } }
        }.navigationTitle(operationTitle(operation.name)).navigationBarTitleDisplayMode(.inline)
    }
}

private func moduleTitle(_ s:String)->String { ["auth":"账户认证","dashboard":"仪表盘","hosts":"主机管理","rules":"转发规则","tunnels":"隧道链路","forwardGroups":"转发组","users":"用户管理","plans":"套餐订阅","billing":"余额计费","payment":"支付订单","plugins":"插件中心","system":"系统设置","telegram":"Telegram","trafficBilling":"流量计费","agentTokens":"Agent Token","announcements":"公告","lookingGlass":"网络测试","setup":"初始化" ][s] ?? s }
private func moduleIcon(_ s:String)->String { ["hosts":"server.rack","rules":"arrow.left.arrow.right","tunnels":"link","users":"person.2","system":"gearshape","plugins":"puzzlepiece.extension","billing":"creditcard","plans":"shippingbox","dashboard":"chart.xyaxis.line"][s] ?? "square.grid.2x2" }
private func operationTitle(_ s:String)->String { ["create":"创建","update":"编辑","delete":"删除","list":"列表","listPage":"分页列表","toggle":"启停","test":"测试","status":"状态","summary":"汇总","options":"可选项","resetTraffic":"重置流量","startSelfTest":"开始自测","reorder":"调整排序","me":"我的资料","updateProfile":"编辑资料","changePassword":"修改密码","panelLogs":"面板日志","getSettings":"读取设置","updateSettings":"编辑设置","createOrder":"创建订单","runAction":"执行操作"][s] ?? s }

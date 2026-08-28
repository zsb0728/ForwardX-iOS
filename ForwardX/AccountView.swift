import SwiftUI

struct AccountView: View {
    @Bindable var store: ForwardXStore
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GlassCard {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle().fill(.blue.gradient)
                            Text(String(store.user.text("name", "username").prefix(1))).font(.title.bold()).foregroundStyle(.white)
                        }.frame(width: 68, height: 68)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(store.user.text("name", "username")).font(.title2.bold())
                            Text(store.user.text("username")).foregroundStyle(.secondary)
                            Text(store.user.text("role").uppercased()).font(.caption.bold()).foregroundStyle(.blue)
                        }
                    }
                }
                GlassCard {
                    VStack(spacing: 0) {
                        AccountRow(icon: "person.text.rectangle", title: "账户资料", color: .blue)
                        Divider().padding(.leading, 44)
                        AccountRow(icon: "gauge.with.dots.needle.33percent", title: "流量与额度", color: .cyan)
                        Divider().padding(.leading, 44)
                        AccountRow(icon: "bell", title: "通知设置", color: .orange)
                        Divider().padding(.leading, 44)
                        AccountRow(icon: "lock.shield", title: "安全与双重验证", color: .green)
                    }
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("面板", systemImage: "network").font(.headline)
                        Text("https://vps.na21.icu").foregroundStyle(.secondary)
                        Label("连接安全", systemImage: "checkmark.shield.fill").foregroundStyle(.green)
                    }
                }
                Button(role: .destructive) { store.logout() } label: {
                    Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right").frame(maxWidth: .infinity).padding()
                }.modifier(GlassButtonModifier())
                Text("ForwardX Native · AGPL-3.0").font(.caption2).foregroundStyle(.tertiary)
            }.padding()
        }.navigationTitle("我的")
    }
}

struct AccountRow: View {
    let icon: String, title: String; let color: Color
    var body: some View {
        HStack { Image(systemName: icon).foregroundStyle(color).frame(width: 30); Text(title); Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary) }.padding(.vertical, 14)
    }
}

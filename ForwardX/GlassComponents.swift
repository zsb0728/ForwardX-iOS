import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(13).frame(maxWidth:.infinity,alignment:.leading)
            .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:20,style:.continuous))
            .overlay(RoundedRectangle(cornerRadius:20).stroke(.white.opacity(0.18)))
            .shadow(color:.black.opacity(0.07),radius:12,y:5)
    }
}

struct LiquidBackground: View {
    var body: some View { ZStack { LinearGradient(colors:[Color(.systemBackground),.blue.opacity(0.12),.cyan.opacity(0.08)],startPoint:.topLeading,endPoint:.bottomTrailing); Circle().fill(.blue.opacity(0.18)).blur(radius:70).frame(width:260).offset(x:150,y:-290); Circle().fill(.purple.opacity(0.12)).blur(radius:80).frame(width:250).offset(x:-160,y:300) }.ignoresSafeArea() }
}

struct StatusPill: View {
    let online: Bool; var text: String { online ? "在线":"离线" }
    var body: some View { Label(text,systemImage:"circle.fill").font(.caption.bold()).foregroundStyle(online ? .green:.secondary).padding(.horizontal,10).padding(.vertical,6).background((online ? Color.green:Color.gray).opacity(0.12),in:Capsule()) }
}

struct MetricCard: View {
    let title:String, value:String, icon:String, color:Color
    var body: some View { GlassCard { VStack(alignment:.leading,spacing:12) { Image(systemName:icon).font(.headline).foregroundStyle(color); Text(value).font(.title2.bold()).lineLimit(1).minimumScaleFactor(0.7); Text(title).font(.caption).foregroundStyle(.secondary) } } }
}

struct EmptyState: View {
    let icon:String,title:String,detail:String
    var body: some View { VStack(spacing:10) { Image(systemName:icon).font(.system(size:44)).foregroundStyle(.secondary); Text(title).font(.headline); Text(detail).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center) }.frame(maxWidth:.infinity).padding(50) }
}

struct GlassButtonModifier: ViewModifier {
    func body(content:Content)->some View { if #available(iOS 26.0,*) { content.glassEffect(.regular.interactive(),in:.capsule) } else { content.background(.ultraThinMaterial,in:Capsule()) } }
}

import SwiftUI
import WebKit
import Observation

private let panel = URL(string: "https://vps.na21.icu")!

struct ContentView: View {
    @State private var web = WebState()
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ForwardXWebView(state: web, url: panel).ignoresSafeArea(.container, edges: .bottom)
            HStack(spacing: 18) {
                Button { web.goBack() } label: { Image(systemName: "chevron.left") }.disabled(!web.canGoBack)
                Button { web.goHome(panel) } label: { Image(systemName: "house.fill") }
                Button { web.reload() } label: { Image(systemName: "arrow.clockwise") }
                Spacer()
                if web.loading { ProgressView() }
                Button { showSettings = true } label: { Image(systemName: "ellipsis") }
            }
            .font(.title3).padding(.horizontal, 20).frame(height: 54)
            .modifier(ForwardXGlass()).padding(.horizontal, 14).padding(.bottom, 8)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                List {
                    Section("面板") { Text("vps.na21.icu"); Button("重新载入") { web.reload(); showSettings = false } }
                    Section("ForwardX") { Link("开源项目", destination: URL(string:"https://github.com/poouo/Forwardx")!); Text("客户端遵循 AGPL-3.0") }
                }.navigationTitle("ForwardX").toolbar { Button("完成") { showSettings = false } }
            }.presentationDetents([.medium]).presentationBackground(.ultraThinMaterial)
        }
    }
}

@Observable final class WebState {
    weak var view: WKWebView?
    var canGoBack = false
    var loading = false
    func goBack() { view?.goBack() }
    func reload() { view?.reload() }
    func goHome(_ url: URL) { view?.load(URLRequest(url: url)) }
}

struct ForwardXWebView: UIViewRepresentable {
    let state: WebState; let url: URL
    func makeCoordinator() -> Coordinator { Coordinator(state) }
    func makeUIView(context: Context) -> WKWebView {
        let c = WKWebViewConfiguration(); c.websiteDataStore = .default(); c.allowsInlineMediaPlayback = true
        let v = WKWebView(frame: .zero, configuration: c); state.view = v; v.navigationDelegate = context.coordinator
        v.allowsBackForwardNavigationGestures = true; v.scrollView.contentInset.bottom = 68
        v.load(URLRequest(url: url)); return v
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate {
        let state: WebState; init(_ state: WebState) { self.state = state }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { state.loading = true }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { state.loading = false; state.canGoBack = webView.canGoBack }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { state.loading = false }
    }
}

struct ForwardXGlass: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.glassEffect(.regular.interactive(), in: .capsule) }
        else { content.background(.ultraThinMaterial, in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.22))) }
    }
}

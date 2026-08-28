import Foundation
import Observation

@MainActor @Observable
final class ForwardXStore {
    let panel = URL(string: "https://vps.na21.icu")!
    var token = UserDefaults.standard.string(forKey: "fx.token") ?? ""
    var user: [String: JSONValue] = [:]
    var stats: [String: JSONValue] = [:]
    var traffic: [String: JSONValue] = [:]
    var hosts: [FXItem] = []
    var rules: [FXItem] = []
    var tunnels: [FXItem] = []
    var loading = false
    var error = ""
    var signedIn: Bool { !token.isEmpty }

    func login(username: String, password: String) async -> Bool {
        loading = true; error = ""; defer { loading = false }
        do {
            let v = try await request("auth.login", input: .object(["username":.string(username),"password":.string(password),"mobile":.bool(true)]), mutation: true, authorized: false)
            guard let o = v.object, let t = o["mobileToken"]?.string else { throw FXError.message("服务器未返回移动令牌") }
            token = t; user = o; UserDefaults.standard.set(t, forKey: "fx.token")
            await refresh(); return true
        } catch { self.error = friendly(error); return false }
    }

    func refresh() async {
        guard signedIn else { return }; loading = true; error = ""; defer { loading = false }
        do {
            async let a = request("dashboard.stats")
            async let b = request("dashboard.trafficTotals")
            async let c = request("hosts.listPage", input: pageInput())
            async let d = request("rules.listPage", input: .object(["page":.number(1),"pageSize":.number(50),"category":.string("all"),"search":.string("")]))
            async let e = request("tunnels.listPage", input: pageInput())
            let (av,bv,cv,dv,ev) = try await (a,b,c,d,e)
            stats = av.object ?? [:]; traffic = bv.object ?? [:]
            hosts = items(cv); rules = items(dv); tunnels = items(ev)
        } catch { self.error = friendly(error); if errorText(error).contains("登录") { logout() } }
    }

    func toggleRule(_ item: FXItem) async {
        guard let n = Double(item.id) else { return }
        do { _ = try await request("rules.toggle", input: .object(["id":.number(n),"isEnabled":.bool(!item.data.flag("isEnabled","enabled"))]), mutation: true); await refresh() }
        catch { self.error = friendly(error) }
    }

    func logout() { token = ""; user = [:]; hosts=[]; rules=[]; tunnels=[]; UserDefaults.standard.removeObject(forKey:"fx.token") }
    private func pageInput() -> JSONValue { .object(["page":.number(1),"pageSize":.number(50),"search":.string("")]) }
    private func items(_ value: JSONValue) -> [FXItem] { let list: [JSONValue] = value.object?["items"]?.array ?? value.array ?? []; return list.enumerated().map(FXItem.init) }

    private func request(_ path: String, input: JSONValue? = nil, mutation: Bool = false, authorized: Bool = true) async throws -> JSONValue {
        var url = panel.appending(path: "api/trpc/\(path)")
        let envelope: JSONValue = .object(["json": input ?? .null])
        let body = try JSONEncoder().encode(envelope)
        if !mutation {
            var c = URLComponents(url: url, resolvingAgainstBaseURL: false)!; c.queryItems = [URLQueryItem(name:"input", value:String(data:body,encoding:.utf8)!)] ; url = c.url!
        }
        var r = URLRequest(url:url); r.httpMethod = mutation ? "POST":"GET"; r.setValue("application/json",forHTTPHeaderField:"Content-Type"); r.setValue("1",forHTTPHeaderField:"x-forwardx-mobile")
        if authorized { r.setValue("Bearer \(token)",forHTTPHeaderField:"Authorization") }; if mutation { r.httpBody = body }
        let (data,response) = try await URLSession.shared.data(for:r)
        guard let http=response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw FXError.message(parseError(data)) }
        let root = try JSONDecoder().decode(JSONValue.self,from:data)
        guard let result=root.object?["result"]?.object?["data"]?.object?["json"] else { throw FXError.message(parseError(data)) }
        return result
    }
    private func parseError(_ d:Data)->String { (try? JSONDecoder().decode(JSONValue.self,from:d).object?["error"]?.object?["json"]?.object?["message"]?.string) ?? "请求失败" }
    private func errorText(_ e:Error)->String { if case FXError.message(let s)=e{return s}; return e.localizedDescription }
    private func friendly(_ e:Error)->String { let s=errorText(e); return s.contains("用户名或密码") ? "用户名或密码错误":s }
}
enum FXError: Error { case message(String) }

import Foundation

enum JSONValue: Codable, Sendable {
    case string(String), number(Double), bool(Bool), object([String: JSONValue]), array([JSONValue]), null
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Double.self) { self = .number(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([String: JSONValue].self) { self = .object(v) }
        else { self = .array(try c.decode([JSONValue].self)) }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self { case .string(let v): try c.encode(v); case .number(let v): try c.encode(v); case .bool(let v): try c.encode(v); case .object(let v): try c.encode(v); case .array(let v): try c.encode(v); case .null: try c.encodeNil() }
    }
    var object: [String: JSONValue]? { if case .object(let v) = self { v } else { nil } }
    var array: [JSONValue]? { if case .array(let v) = self { v } else { nil } }
    var string: String? { switch self { case .string(let v): v; case .number(let v): String(format: "%.0f", v); default: nil } }
    var number: Double { switch self { case .number(let v): v; case .string(let v): Double(v) ?? 0; default: 0 } }
    var bool: Bool { if case .bool(let v) = self { v } else { false } }
}

extension Dictionary where Key == String, Value == JSONValue {
    func text(_ keys: String...) -> String { for k in keys { if let s = self[k]?.string, !s.isEmpty { return s } }; return "—" }
    func num(_ keys: String...) -> Double { for k in keys { if let v = self[k], v.number != 0 { return v.number } }; return 0 }
    func flag(_ keys: String...) -> Bool { keys.contains { self[$0]?.bool == true } }
}

struct FXItem: Identifiable, Hashable {
    let id: String; let data: [String: JSONValue]
    init(_ value: JSONValue, index: Int) { data = value.object ?? [:]; id = data["id"]?.string ?? "\(index)" }
    static func == (l: FXItem, r: FXItem) -> Bool { l.id == r.id }
    func hash(into h: inout Hasher) { h.combine(id) }
}

func bytes(_ value: Double) -> String {
    let f = ByteCountFormatter(); f.allowedUnits = [.useKB,.useMB,.useGB,.useTB]; f.countStyle = .binary
    return f.string(fromByteCount: Int64(value))
}

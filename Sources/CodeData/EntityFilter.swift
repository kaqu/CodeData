import Foundation

public struct EntityFilter<Entity: AnyStorageEntity> {
    public static var all: EntityFilter{ return .init { _ in true } }

    internal let filter: (Entity) -> Bool

    public init(_ filter: @escaping (Entity) -> Bool) {
        self.filter = filter
    }

    public init(allOf filters: EntityFilter...) {
        self.filter = { data in
            filters.reduce(into: true, { result, filter in
                result = result && filter.filter(data)
            })
        }
    }

    public init(anyOf filters: EntityFilter...) {
        self.filter = { data in
            filters.reduce(into: true, { result, filter in
                result = result || filter.filter(data)
            })
        }
    }
}

internal extension EntityFilter {
    init<Value: Equatable>(_ keyPath: KeyPath<Entity, Value>, equal value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] == value
        }
    }

    init<Value: Equatable>(_ keyPath: KeyPath<Entity, Value>, notEqual value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] != value
        }
    }

    init<Value: Comparable>(_ keyPath: KeyPath<Entity, Value>, lessValuehan value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] < value
        }
    }

    init<Value: Comparable>(_ keyPath: KeyPath<Entity, Value>, lessValuehanOrEqual value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] <= value
        }
    }

    init<Value: Comparable>(_ keyPath: KeyPath<Entity, Value>, greaterValuehan value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] > value
        }
    }

    init<Value: Comparable>(_ keyPath: KeyPath<Entity, Value>, greaterValuehanOrEqual value: Value) {
        self.filter = { data in
            data[keyPath: keyPath] >= value
        }
    }
}

public extension Decodable where Self: AnyStorageEntity {
    static var allRecords: EntityFilter<Self> { return .init { _ in true } }
}

public func == <Record: Codable, Value: Equatable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, equal: rhs)
}

public func != <Record: Codable, Value: Equatable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, notEqual: rhs)
}

public func < <Record: Codable, Value: Comparable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, lessValuehan: rhs)
}

public func <= <Record: Codable, Value: Comparable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, lessValuehanOrEqual: rhs)
}

public func > <Record: Codable, Value: Comparable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, greaterValuehan: rhs)
}

public func >= <Record: Codable, Value: Comparable>(_ lhs: KeyPath<Record, Value>, _ rhs: Value) -> EntityFilter<Record> {
    return .init(lhs, greaterValuehanOrEqual: rhs)
}

public func && <Record: Codable>(_ lhs: EntityFilter<Record>, _ rhs: EntityFilter<Record>) -> EntityFilter<Record> {
    return .init(allOf: lhs, rhs)
}

public func || <Record: Codable>(_ lhs: EntityFilter<Record>, _ rhs: EntityFilter<Record>) -> EntityFilter<Record> {
    return .init(anyOf: lhs, rhs)
}

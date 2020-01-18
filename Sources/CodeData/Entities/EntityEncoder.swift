import Foundation
import CoreData

// TODO: FIXME: minimal, naive implementation
internal final class EntityEncoder: Encoder {
  
  private let context: NSManagedObjectContext
  fileprivate let managed: NSManagedObject
  private var updatesList: UpdatesList = .init()
  
  public var codingPath: [CodingKey] = []

  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  internal init(for entity: AnyStorageEntity, in context: NSManagedObjectContext, using managedObjectID: NSManagedObjectID?) {
    self.context = context
    if let managedID = managedObjectID, let managed = try? context.existingObject(with: managedID) {
      self.managed = managed
    } else {
      self.managed = NSManagedObject(entity: type(of: entity).entityDescription, insertInto: context)
      context.insert(managed)
      updatesList.append { entity.managedID.managedObjectID = self.managed.objectID }
    }
  }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(CoreDataManagedContainer(for: managed, in: context, updatesList: updatesList))
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer { fatalError() }

  public func singleValueContainer() -> SingleValueEncodingContainer { fatalError() }
  
  internal func updateManagedObjectIDs() { updatesList.execute() }
  
  deinit { updatesList.execute() }
}

fileprivate final class CoreDataManagedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
  
  private let context: NSManagedObjectContext
  private let managed: NSManagedObject
  private var updatesList: UpdatesList = .init()
  
  var codingPath: [CodingKey] = []
  
  var allKeys: [Key] = []
  
  fileprivate init(for managed: NSManagedObject, in context: NSManagedObjectContext, updatesList: UpdatesList) {
    self.context = context
    self.managed = managed
  }
  
  func encodeNil(forKey key: Key) throws {
    managed.setPrimitiveValue(nil, forKey: key.stringValue)
  }
  
  func encode(_ value: Bool, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: String, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Double, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Float, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Int, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Int8, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Int16, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Int32, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: Int64, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: UInt, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: UInt8, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: UInt16, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: UInt32, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode(_ value: UInt64, forKey key: Key) throws {
    managed.setPrimitiveValue(value, forKey: key.stringValue)
  }
  
  func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
    guard let entity = value as? AnyStorageEntity else { fatalError("TODO: Throw") }
    let encoder: EntityEncoder = .init(for: entity, in: context, using: entity.managedID.managedObjectID)
    try entity.encode(to: encoder)
    managed.setPrimitiveValue(encoder.managed, forKey: key.stringValue)
    updatesList.append { entity.managedID.managedObjectID = self.managed.objectID }
  }
  
  func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError("TODO: realtions")
  }
  
  func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError("TODO: relations/arrays?")
  }
  
  func superEncoder() -> Encoder {
    fatalError("TODO: relations?")
  }
  
  func superEncoder(forKey key: Key) -> Encoder {
    fatalError("TODO: relations?")
  }
}

fileprivate final class UpdatesList {
  private var list: [() -> Void] = .init()
  
  fileprivate init() {}
  
  fileprivate func append(_ update: @escaping () -> Void) {
    list.append(update)
  }
  
  fileprivate func execute() {
    list.forEach { $0() }
    list = .init()
  }
}

import Foundation
import CoreData

// TODO: FIXME: minimal, naive implementation
internal final class EntityDecoder: Decoder {
  
  private let context: NSManagedObjectContext
  private let managed: NSManagedObject

  public var codingPath: [CodingKey] = []
  
  public var userInfo: [CodingUserInfoKey : Any] = [:]
  
  internal init(from managed: NSManagedObject, in context: NSManagedObjectContext) {
    self.context = context
    self.managed = managed
  }
  
  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    return KeyedDecodingContainer(CoreDataManagedDecodingContainer(for: managed, in: context))
  }
  
  public func unkeyedContainer() throws -> UnkeyedDecodingContainer { fatalError("Not supported") }
  
  public func singleValueContainer() throws -> SingleValueDecodingContainer { fatalError("Not supported") }
  
}

internal final class CoreDataManagedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    private let context: NSManagedObjectContext
    private let managed: NSManagedObject
    
    var codingPath: [CodingKey] = []
    
    var allKeys: [Key] = []
    
    internal init(for managed: NSManagedObject, in context: NSManagedObjectContext) {
      self.context = context
      self.managed = managed
    }
    
    func contains(_ key: Key) -> Bool {
      managed.entity.attributesByName.keys.contains(key.stringValue)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
      return managed.primitiveValue(forKey: key.stringValue) == nil
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Bool else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? String else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Double else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Float else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Int else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Int8 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Int16 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Int32 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? Int64 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? UInt else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? UInt8 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? UInt16 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? UInt32 else { fatalError("THROW") }
      return value
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      guard let value = managed.primitiveValue(forKey: key.stringValue) as? UInt64 else { fatalError("THROW") }
      return value
    }
    
  // TODO: relationships "to many" should fall into collections decoding
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
      guard let relatedObject = managed.primitiveValue(forKey: key.stringValue) as? NSManagedObject else { fatalError("THROW") }
      guard let value = try type.init(from: EntityDecoder(from: relatedObject, in: context)) as? AnyStorageEntity else { fatalError("THROW") }
      value.managedID.managedObjectID = relatedObject.objectID
      return value as! T
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
      fatalError("TODO: relations")
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      fatalError("TODO: relations/arrays?")
    }
    
    func superDecoder() throws -> Decoder {
      fatalError("TODO: relations?")
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
      fatalError("TODO: relations?")
    }
  }

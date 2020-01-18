import CoreData

public final class ManagedID: Hashable, CustomDebugStringConvertible {
  public static func == (lhs: ManagedID, rhs: ManagedID) -> Bool {
    return lhs.managedObjectID == rhs.managedObjectID
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(managedObjectID)
  }
  
  internal var managedObjectID: NSManagedObjectID?
  
  public init() {}
  
  public var debugDescription: String { managedObjectID.debugDescription }
}
public protocol AnyStorageEntity: Codable {
  
  static var entityName: String { get }

  static var entityDescription: NSEntityDescription { get }
  
  var managedID: ManagedID { get }
}

public extension AnyStorageEntity {
  static var entityName: String {
    return .init(describing: self)
  }
}

public protocol StorageEntity: AnyStorageEntity {
  associatedtype CodingKeys: StorageEntityCodingKeys
}

public extension StorageEntity {
  
  static var entityDescription: NSEntityDescription {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    if let cachedDescription = entityDescriptionCache[entityName] {
      return cachedDescription
    } else {
      // TOOD: to check if should add something more like version support
      let description: NSEntityDescription = .init()
      description.name = Self.entityName
      Self.CodingKeys.allCases.forEach { property in
        let coreDataProperty: NSPropertyDescription = property.storageProperty.coreDataProperty
        coreDataProperty.name = property.stringValue
        description.properties.append(coreDataProperty)
      }
      entityDescriptionCache[entityName] = description
      return description
    }
  }
}

fileprivate let cacheLock: NSRecursiveLock = .init()
fileprivate var entityDescriptionCache: [String: NSEntityDescription] = .init()

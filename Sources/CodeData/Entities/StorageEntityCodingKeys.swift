import CoreData

public protocol StorageEntityCodingKeys: CodingKey, CaseIterable {
  var storageProperty: StorageEntityProperty { get }
}


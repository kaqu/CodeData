import CoreData

public struct StorageSchema {
  
  internal let managedObjectModel: NSManagedObjectModel = .init()
  
  public init(_ entityList: AnyStorageEntity.Type...) {
    managedObjectModel.entities.reserveCapacity(entityList.count)
    entityList.forEach { managedObjectModel.entities.append($0.entityDescription) }
  }
}

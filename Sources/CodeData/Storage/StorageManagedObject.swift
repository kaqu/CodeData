import CoreData

internal final class StorageManagedObject<Entity: AnyStorageEntity>: NSManagedObject {

  override class func entity() -> NSEntityDescription {
    return Entity.entityDescription
  }
}

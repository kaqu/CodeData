import CoreData

public final class Storage {
  private let context: NSManagedObjectContext
  private let schema: StorageSchema
  public enum StoreType {
    case sqlite
    case inMemory
    
    internal var coreDataType: String {
      switch self {
      case .sqlite: return NSSQLiteStoreType
      case .inMemory: return NSInMemoryStoreType
      }
    }
  }
  
  public init(name: String = "CoreDataStorage", store: StoreType = .inMemory, schema: StorageSchema) throws {
    self.schema = schema
    let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: schema.managedObjectModel)
    try storeCoordinator
      .addPersistentStore(
        ofType: store.coreDataType,
        configurationName: nil,
        at: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(name),
        options: [NSMigratePersistentStoresAutomaticallyOption: true]
    )
    context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = storeCoordinator
  }
}

public extension Storage {
  func load<Entity: StorageEntity>(_ type: Entity.Type, filter: EntityFilter<Entity> = .all) throws -> [Entity] {
    let fetchRequest: NSFetchRequest<NSManagedObject> = .init(entityName: Entity.entityName)
    fetchRequest.returnsObjectsAsFaults = false
    return try
      context
      .fetch(fetchRequest)
      .map {
        let entity
          = try Entity(
            from: EntityDecoder(
              from: $0,
              in: context))
        entity.managedID.managedObjectID = $0.objectID
        return entity
      }
      .filter(filter.filter)
  }
  
  func save<Entity: StorageEntity>(_ entity: inout Entity) throws {
    let encoder: EntityEncoder = .init(for: entity, in: context, using: entity.managedID.managedObjectID)
    do {
      try entity.encode(to: encoder)
      try context.save()
      encoder.updateManagedObjectIDs()
    } catch {
      context.rollback()
      throw error
    }
  }
  
  func delete<Entity: StorageEntity>(_ entity: inout Entity) throws {
    guard let managedObjectID = entity.managedID.managedObjectID else { fatalError("TODO: Throw") }
    try context.delete(context.existingObject(with: managedObjectID))
    do {
      try context.save()
      entity.managedID.managedObjectID = nil
    } catch {
      context.rollback()
      throw error
    }
  }
}

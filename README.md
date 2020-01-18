# CodeData

CoreData wrapper in swift - Just define a codable type and use it as core data model without any additional work!

Define the type with proper coding keys extension - description of CoreData mapping.

``` swift
struct SomeEntity: StorageEntity, Equatable {
  enum CodingKeys: StorageEntityCodingKeys {
    var storageProperty: StorageEntityProperty {
      switch self {
      case .stringField: return .primitive(String.self)
      case .boolField: return .primitive(Bool.self)
      }
    }
    case stringField
    case boolField
  }
  
  let managedID: ManagedID = .init()
  var stringField: String
  var boolField: Bool = false
}
```

Than use core data store and just save/load it! No additional schema / configuration files, it is just it.

``` swift
let storage: Storage 
= try .init(
  name: "Storage", 
  store: .inMemory, 
  schema: .init(SomeEntity.self) // list models used by this store here
)
var someEntity: SomeEntity = .init(stringField: "String Field")
try storage.save(&someEntity) // save
try storage.load(TestEntity.self , filter: \.stringField == "some specific") // load with filter
```

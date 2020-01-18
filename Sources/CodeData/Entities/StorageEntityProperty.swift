import CoreData

public enum StorageEntityProperty {
  case primitive(Any.Type)
  case relation(to: AnyStorageEntity.Type)
  case custom(NSPropertyDescription)
}

internal extension StorageEntityProperty {
  var coreDataProperty: NSPropertyDescription {
    switch self { // TODO: enable collection support both for relations (to many) and for primitives
    case let .primitive(type):
      let primitiveDescription: NSAttributeDescription = .init()
      primitiveDescription.attributeType = coreDataAttributeType(for: type)
      primitiveDescription.isOptional = type is OptionalType.Type
      primitiveDescription.isTransient = false
      primitiveDescription.allowsExternalBinaryDataStorage = primitiveDescription.attributeType == .binaryDataAttributeType
      return primitiveDescription
    case let .relation(type):
      let relationDescription: NSRelationshipDescription = .init()
      relationDescription.isOptional = type is OptionalType.Type
      relationDescription.isTransient = false
      relationDescription.destinationEntity = type.entityDescription
      relationDescription.maxCount = 1
      relationDescription.minCount = relationDescription.isOptional ? 0 : 1
      relationDescription.deleteRule = relationDescription.isOptional ? .nullifyDeleteRule : .cascadeDeleteRule//.denyDeleteRule
      return relationDescription
    case let .custom(description):
      return description
    }
  }
}

private func coreDataAttributeType(for type: Any.Type) -> NSAttributeType {
  let atributeType: Any.Type
  if let optionalType = type as? OptionalType.Type {
    atributeType = optionalType.wrappedType
  } else {
    atributeType = type
  }
  switch atributeType {
  case Bool.self: return .booleanAttributeType
  case Int16.self: return .integer16AttributeType
  case Int32.self: return .integer32AttributeType
  case Int64.self: return .integer64AttributeType
  case Int.self: return .integer64AttributeType
  case Decimal.self: return .decimalAttributeType
  case Double.self: return .doubleAttributeType
  case Float.self: return .floatAttributeType
  case String.self: return .stringAttributeType
  case Bool.self: return .booleanAttributeType
  case Date.self: return .dateAttributeType
  case Data.self: return .binaryDataAttributeType
  case _: fatalError("Type \(type) is not supported")
  }
}

fileprivate func ~=(_ lhs: Any.Type, rhs: Any.Type) -> Bool {
  return lhs == rhs
}

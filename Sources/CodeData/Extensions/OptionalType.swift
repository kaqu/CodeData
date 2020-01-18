import CoreData

internal protocol OptionalType {
  static var wrappedType: Any.Type { get }
}

extension Optional: OptionalType {
  static var wrappedType: Any.Type { return Wrapped.self }
}

//extension Optional: AnyStorageEntity where Wrapped: AnyStorageEntity {
//  // TODO: check if it is not better to fatal error on all this
//
//  public static var entityName: String {
//    return .init(describing: Wrapped.self)
//  }
//
//  public static var entityDescription: NSEntityDescription {
//    return Wrapped.entityDescription
//  }
//
//  public var managedID: Self.ManagedID {
//    get { self.map { $0.managedID } }
//    set {
//      switch self {
//      case .none: return
//      case var .some(wrapped):
//        wrapped.managedID = newValue
//        self = .some(wrapped)
//      }
//    }
//  }
//}

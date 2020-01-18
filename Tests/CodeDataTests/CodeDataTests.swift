import XCTest
@testable import CodeData

struct TestEntity: StorageEntity, Equatable {
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

struct TestRelationEntity: StorageEntity, Equatable {
  enum CodingKeys: StorageEntityCodingKeys {
    var storageProperty: StorageEntityProperty {
      switch self {
      case .optionalStringField: return .primitive(Optional<String>.self)
      case .testEntity: return .relation(to: TestEntity.self)
      }
    }
    case optionalStringField
    case testEntity
  }
  
  let managedID: ManagedID = .init()
  var optionalStringField: String?
  var testEntity: TestEntity
}

final class CodeDataTests: XCTestCase {
  
  func testSample() {
    let storage: Storage = try! .init(name: "TEST2", store: .inMemory, schema: .init(
      TestEntity.self,
      TestRelationEntity.self
    ))
    var testEntity: TestEntity = .init(stringField: "TESTFIELD2")
    try! storage.save(&testEntity)
    XCTAssertEqual(testEntity, try! storage.load(TestEntity.self).first)
    testEntity.stringField = "Changed"
    testEntity.boolField.toggle()
    try! storage.save(&testEntity)
    XCTAssertEqual(testEntity, try! storage.load(TestEntity.self).first)
    var testRelationEntity: TestRelationEntity = .init(optionalStringField: "SOME!", testEntity: testEntity)
    try! storage.save(&testRelationEntity)
    XCTAssertEqual(testRelationEntity, try! storage.load(TestRelationEntity.self).first)
    testRelationEntity.optionalStringField = nil
    testRelationEntity.testEntity.stringField = "Related"
    try! storage.save(&testRelationEntity)
    XCTAssertTrue(try! storage.load(TestRelationEntity.self).contains(testRelationEntity))
    XCTAssertEqual(testRelationEntity, try! storage.load(TestRelationEntity.self).first)
    try! storage.delete(&testRelationEntity.testEntity)
    XCTAssertEqual(testRelationEntity, try! storage.load(TestRelationEntity.self).first)
  }
}

// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "CodeData",
  platforms: [.iOS(.v11), .macOS(.v10_13)],
  products: [
    .library(
      name: "CodeData",
      targets: ["CodeData"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "CodeData",
      dependencies: []),
    .testTarget(
      name: "CodeDataTests",
      dependencies: ["CodeData"]),
  ]
)

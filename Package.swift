// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-specification-pattern",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_13),
    .watchOS(.v4),
    .tvOS(.v12),
    .visionOS(.v1)
  ],
  products: [
    .library(
      name: "SpecificationPattern",
      targets: ["SpecificationPattern"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "SpecificationPattern"
    ),
    .testTarget(
      name: "SpecificationPatternTests",
      dependencies: ["SpecificationPattern"]
    ),
  ]
)

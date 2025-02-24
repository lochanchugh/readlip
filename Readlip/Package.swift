// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Readlip",
    platforms: [
            .iOS(.v18)
        ],
    products: [
       
        .library(
            name: "Readlip",
            targets: ["Readlip"]),
    ],
    targets: [
        .target(
            name: "Readlip",
            resources: [.process("Resources/Assets.xcassets")]
        ),
    ]
)

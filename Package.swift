// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TruvideoSdkFoundation",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TruvideoSdkFoundation",
            targets: ["TruvideoSdkFoundation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Truvideo/truvideo-sdk-ios-core", from: "75.1.1-RC.135"),
    ],
    targets: Target.allTargets
)

extension Target {
    static var allTargets: [Target] {
        [
            truvideoSdkFoundationTargets(),
        ]
            .flatMap { $0 }
    }
    
    static func truvideoSdkFoundationTargets() -> [Target] {
        [
            .target(
                name: "TruvideoSdkFoundation",
                dependencies: [
                    .product(name: "TruvideoSdk", package: "truvideo-sdk-ios-core")
                ],
                path: "Sources"
            ),
            .target(
                name: "TruvideoSdkFoundationTesting",
                dependencies: [
                    "TruvideoSdkFoundation"
                ],
                path: "Testing"
            ),
            .testTarget(
                name: "TruvideoSdkFoundationTests",
                dependencies: [
                    "TruvideoSdkFoundation",
                    "TruvideoSdkFoundationTesting",                    
                ],
                path: "Tests"
            ),
        ]
    }
}

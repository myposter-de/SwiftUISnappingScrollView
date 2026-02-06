// swift-tools-version: 5.5

/**
*  SwiftUISnappingScrollView
*  Copyright (c) Ciaran O'Brien 2022
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "SwiftUISnappingScrollView",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftUISnappingScrollView",
            targets: ["SwiftUISnappingScrollView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftUISnappingScrollView",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                ])
    ]
)

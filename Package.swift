// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "KituraRequestConcurrency",
	dependencies: [
		.Package(url: "https://github.com/IBM-Swift-Sunset/Kitura-Request.git", majorVersion: 0),
		.Package(url: "https://github.com/naithar/Concurrency.git", majorVersion: 0),
		.Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 16),
	]
)

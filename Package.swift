// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Kitura-Request-Concurrency",
	dependencies: [
		.Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0),
		.Package(url: "https://github.com/naithar/Concurrency.git", majorVersion: 0),
	]
)

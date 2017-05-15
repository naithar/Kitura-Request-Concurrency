import XCTest
@testable import Kitura_Request_Concurrency

class Kitura_Request_ConcurrencyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Kitura_Request_Concurrency().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}

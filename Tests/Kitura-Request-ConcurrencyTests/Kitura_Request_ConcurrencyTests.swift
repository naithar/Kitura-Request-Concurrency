import XCTest
import SwiftyJSON
import KituraRequest
@testable import KituraRequestConcurrency

class KituraRequestConcurrencyTests: XCTestCase {
    
    func testRequest() {
        
        let e = self.expectation(description: "ex")
        KituraRequest
            .request(.get, "http://httpbin.org/ip")
            .response(with: String.self)
            .then { print("\($0)") }
            .always { _ in e.fulfill() }
        
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }


    static var allTests = [
        ("testRequest", testRequest),
    ]
}

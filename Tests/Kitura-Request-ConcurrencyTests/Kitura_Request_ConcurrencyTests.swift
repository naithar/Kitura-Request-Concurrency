import XCTest
import SwiftyJSON
import KituraRequest

@testable import KituraRequestConcurrency

class KituraRequestConcurrencyTests: XCTestCase {
    
    func testRequest() {
        
        let e = self.expectation(description: "ex")
        var value = ""
        
        KituraRequest
            .request(.get, "http://httpbin.org/ip")
            .response(with: JSON.self)
            .then { $0["origin"].string }
            .then { value = $0 ?? "" }
            .always { _ in e.fulfill() }
        
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertNotEqual("", value)
            XCTAssertEqual(4, value.components(separatedBy: ".").count)
        }
    }
    
    func testCombine() {
        
        let e1 = self.expectation(description: "e1")
        let e2 = self.expectation(description: "e2")
        
        let ip = KituraRequest
            .request(.get, "http://httpbin.org/ip")
            .response(with: JSON.self)
            .then { $0["origin"].string }
            .always { _ in e1.fulfill() }
        
        let url = KituraRequest.request(.get, "http://httpbin.org/get")
            .response(with: JSON.self)
            .then { $0["url"].string }
            .always { _ in e2.fulfill() }
        
        let value = try? [ip, url]
            .combine()
            .flatMap { $0 }
            .reduce("") { $0 + $1 }
            .then { $0 }
            .wait()
    
        
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertNotEqual("", value)
            XCTAssert(value?.hasSuffix("http://httpbin.org/get") ?? false)
            
        }
    }


    static var allTests = [
        ("testRequest", testRequest),
        ("testCombine", testCombine),
    ]
}

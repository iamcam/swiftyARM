import XCTest
@testable import readTemp

class readTempTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(readTemp().text, "Hello, World!")
    }


    static var allTests : [(String, (readTempTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}

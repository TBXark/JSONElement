import XCTest
@testable import JsonMapper


final class JsonMapperTests: XCTestCase {
    struct Human: Codable {
        let age: Int
        let name: String
        let height: Double
        let extra: JSONElement // Any?
    }
    func testExample() throws { 

        let dict = ["data": ["man": ["age": 10, "name": "Peter", "height": 180.0, "extra": [123, "123", [123], ["123": 123], true]]]]

        let json = JSONMapper(raw: dict)
        // 直接获取
        XCTAssertEqual(json["data"]["man"]["age"].intValue, 10)

        // 使用Key获取
        XCTAssertEqual(json["data"]["man"]["height"].value(type: Double.self), 180.0)

        // 使用 dynamicMemberLookup 获取
        XCTAssertEqual(json.data.man.height.value(type: Double.self), 180.0)

        // 使用Keypath获取
        XCTAssertEqual(json.value(keyPath: "data.man.name", type: String.self), "Peter")

        // 将Any解析为JSONElement
        let manDict: Any = json["data"]["man"].value()!
        let data = try JSONSerialization.data(withJSONObject: manDict, options: [])
        let man = try JSONDecoder().decode(Human.self, from: data)
        let manJSON = try JSONDecoder().decode(JSONElement.self, from: data)

        XCTAssertEqual(man.name, "Peter")
        XCTAssertEqual(manJSON[keyPath: "name"].stringValue, "Peter")
        XCTAssertEqual(man.extra.arrayValue?.first?.intValue , 123)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

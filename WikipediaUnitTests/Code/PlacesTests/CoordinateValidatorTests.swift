import XCTest
@testable import WMF

class CoordinateValidatorTests: XCTestCase {
    
    func testExtractValidCoordinates() throws {
        let dictionary: NSDictionary = ["lat": 45.0, "lon": 90.0]
        let validator = CoordinateValidator.testValue
        
        let coordinate = try validator.extract(dictionary)
        
        XCTAssertEqual(coordinate.latitude, 45.0)
        XCTAssertEqual(coordinate.longitude, 90.0)
    }
    
    func testExtractMissingKeys() {
        let dictionary: NSDictionary = ["lat": 45.0]
        let validator = CoordinateValidator.testValue
        
        XCTAssertThrowsError(try validator.extract(dictionary)) { error in
            XCTAssertEqual(error as? CoordinateValidator.ValidationError, .keyNotFound)
        }
    }
    
    func testExtractInvalidValues() {
        let dictionary: NSDictionary = ["lat": "invalid", "lon": "invalid"]
        let validator = CoordinateValidator.testValue
        
        XCTAssertThrowsError(try validator.extract(dictionary)) { error in
            XCTAssertEqual(error as? CoordinateValidator.ValidationError, .invalidDictionaryValue)
        }
    }
    
    func testLatitudeValidRange() throws {
        let validator = CoordinateValidator.testValue
        
        XCTAssertNoThrow(try validator.isLatitudeValid(45.0))
    }
    
    func testLatitudeInvalidRange() {
        let validator = CoordinateValidator.testValue
        
        XCTAssertThrowsError(try validator.isLatitudeValid(100.0)) { error in
            XCTAssertEqual(error as? CoordinateValidator.ValidationError, .invalidLatitudeRange(100.0))
        }
    }
    
    func testLongitudeValidRange() throws {
        let validator = CoordinateValidator.testValue
        
        XCTAssertNoThrow(try validator.isLongitudeValid(90.0))
    }
    
    func testLongitudeInvalidRange() {
        let validator = CoordinateValidator.testValue
        
        XCTAssertThrowsError(try validator.isLongitudeValid(200.0)) { error in
            XCTAssertEqual(error as? CoordinateValidator.ValidationError, .invalidLongitudeRange(200.0))
        }
    }
}

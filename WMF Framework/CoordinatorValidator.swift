import Foundation

public struct WPCoordinate {
    public let latitude: Double
    public let longitude: Double
}

public struct CoordinateValidator {
    public var extract: (NSDictionary) throws -> WPCoordinate
    public var isLatitudeValid: (Double) throws -> Bool
    public var isLongitudeValid: (Double) throws -> Bool
    
    public enum ValidationError: Error, CustomStringConvertible, Equatable {
        case keyNotFound
        case invalidDictionaryValue
        case invalidLatitudeRange(Double)
        case invalidLongitudeRange(Double)
        
        /// TODO: Strings can be localized
        public var description: String {
            switch self {
            case .keyNotFound:
                return "Error: Latitude or longitude key is missing."
            case .invalidDictionaryValue:
                return "Error: Latitude or longitude is not a valid number."
            case let .invalidLatitudeRange(latitude):
                return "Latitude:\(latitude) out of range!"
            case let .invalidLongitudeRange(longitude):
                return "Longitude:\(longitude) out of range!"
            }
        }
    }
}

extension CoordinateValidator {
    public static let liveValue = Self { dictionary in
        guard let latitudeValue = dictionary["lat"], let longitudeValue = dictionary["lon"] else {
            throw ValidationError.keyNotFound
        }
        
        guard let latitude = latitudeValue as? NSNumber, let longitude = longitudeValue as? NSNumber else {
            throw ValidationError.invalidDictionaryValue
        }
        
        return .init(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    } isLatitudeValid: {
        guard (-90...90).contains($0) else {
            throw ValidationError.invalidLatitudeRange($0)
        }
        return true
    } isLongitudeValid: {
        guard (-180...180).contains($0) else {
            throw ValidationError.invalidLongitudeRange($0)
        }
        return true
    }
    
    public static let testValue = liveValue
}

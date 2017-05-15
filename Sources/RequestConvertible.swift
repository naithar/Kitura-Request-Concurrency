//
//  RequestConvertible.swift
//  Kitura-Request-Concurrency
//
//  Created by Sergey Minakov on 15.05.17.
//
//

import Foundation
import SwiftyJSON

enum ConvertationError: Swift.Error {
    
    case unableToConvert
}

protocol RequestConvertible {
    
    static func convert(_ data: Data) throws -> Self
}

extension Data: RequestConvertible {
    
    static func convert(_ data: Data) throws -> Data {
        return data
    }
}

extension String: RequestConvertible {
    
    static func convert(_ data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw ConvertationError.unableToConvert
        }
        
        return string
    }
}

extension JSON: RequestConvertible {
    
    static func convert(_ data: Data) throws -> JSON {
        let json = JSON.init(data: data)
        return json
    }
}

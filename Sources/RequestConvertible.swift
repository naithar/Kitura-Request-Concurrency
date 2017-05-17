//
//  RequestConvertible.swift
//  Kitura-Request-Concurrency
//
//  Created by Sergey Minakov on 15.05.17.
//
//

import Foundation
import KituraNet
import SwiftyJSON

public enum ConvertationError: Swift.Error {
    
    case unableToConvert
}

public protocol RequestConvertible {
    
    static func convert(_ data: Data) throws -> Self
}

public protocol RequestResultable {
    
    associatedtype Element: RequestConvertible
}


public struct RequestResult<T: RequestConvertible>: RequestResultable {
    
    public typealias Element = T
    
    public weak var request: ClientRequest?
    public weak var response: ClientResponse?
    public var value: Element
}

extension Data: RequestConvertible {
    
    public static func convert(_ data: Data) throws -> Data {
        return data
    }
}

extension String: RequestConvertible {
    
    public static func convert(_ data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw ConvertationError.unableToConvert
        }
        
        return string
    }
}

extension JSON: RequestConvertible {
    
    public static func convert(_ data: Data) throws -> JSON {
        let json = JSON.init(data: data)
        return json
    }
}

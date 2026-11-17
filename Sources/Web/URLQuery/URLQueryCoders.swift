//
//  URLQueryCoders.swift
// 
//
//  Created by Mihael Isaev on 22.11.2020.
//  Credits to https://github.com/vapor/vapor
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public protocol URLQueryDecoder {
    func decode<D: Decodable>(_ decodable: D.Type, from query: String) throws -> D
}

public protocol URLQueryEncoder {
    func encode<E: Encodable>(_ encodable: E, to query: inout String) throws
}

//
//  AbortError.swift
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

public protocol AbortError: Error {
    /// The reason for this error.
    var reason: String { get }
}

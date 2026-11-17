//
//  Responder.swift
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

public protocol Responder {
    @MainActor func respond(to request: Request) throws -> AnyPageController?
}

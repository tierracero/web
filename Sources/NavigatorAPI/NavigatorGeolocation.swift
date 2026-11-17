//
//  NavigatorGeolocation.swift
//  Navigator
//
//  Created by Mihael Isaev on 17.11.2020.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public final class NavigatorGeolocation: Equatable {
    public static func == (lhs: NavigatorGeolocation, rhs: NavigatorGeolocation) -> Bool {
        true
    }
}

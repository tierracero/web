//
//  BaseActiveElement.swift
//  DOM
//
//  Created by Mihael Isaev on 18.12.2020.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import JavaScriptKit

open class BaseActiveElement: BaseContentElement, DOMEventsActiveScope {}

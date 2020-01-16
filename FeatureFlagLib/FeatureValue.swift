//
//  FeatureValue.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import Foundation


public protocol FeatureValue: CustomStringConvertible {}

extension Bool: FeatureValue {}
extension Int: FeatureValue {}
extension Float: FeatureValue {}
extension Double: FeatureValue {}
extension String: FeatureValue {}

public extension FeatureValue {

    var intValue: Int {
        return Int(doubleValue)
    }

    var floatValue: Float {
        return Float(doubleValue)
    }

    var doubleValue: Double {
        return Double(description) ?? 0.0
    }

    var boolValue: Bool {
        return self as? Bool ?? false
    }

    var stringValue: String? {
        return self as? String
    }
}

public func ==(lhs: FeatureValue, rhs: FeatureValue) -> Bool {
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    return NSNumber(featureValue: lhs) == NSNumber(featureValue: rhs)
    return lhs == rhs
}

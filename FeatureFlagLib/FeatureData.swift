//
//  FeatureData.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import Foundation

public struct FeatureData {
    
    public let feature: String
    public let value: FeatureValue
    
    public let title: String?
    public let desc: String?
    public let group: String?
    public let source: String?

    public var displayTitle: String {
        return title ?? "\(feature)"
    }
    
    private var dictionaryValue: [String : Any?] {
        get {
            return ["feature": feature,
                    "value": value,
                    "title": title,
                    "description": desc,
                    "group": group,
                    "source": source
            ]
        }
    }
    
    public init(feature: String, value: FeatureValue, title: String? = nil, description: String? = nil, group: String? = nil, source: String? = nil) {
        self.feature = feature
        self.value = value
        self.title = title
        self.desc = description
        self.group = group
        self.source = source
    }
}

extension FeatureData: CustomStringConvertible {
    
    public var description: String {
        get {
            return dictionaryValue.description
        }
    }
}

extension FeatureData: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.feature == rhs.feature &&
            lhs.value == rhs.value &&
            lhs.title == rhs.title &&
            lhs.desc == rhs.desc &&
            lhs.group == rhs.group &&
            lhs.source == rhs.source
    }
}

public extension FeatureData {

    var intValue: Int {
        return value.intValue
    }

    var floatValue: Float {
        return value.floatValue
    }

    var doubleValue: Double {
        return value.doubleValue
    }

    var boolValue: Bool {
        return value.boolValue
    }

    var stringValue: String? {
        return value.stringValue
    }
}

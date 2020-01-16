//
//  UserDefaultsConfiguration.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import Foundation

final public class UserDefaultsConfiguration {
    
    private let userDefaults: UserDefaults
    
    private static let userDefaultsKeyPrefix = "lib.featureflag.userDefaultsKey"
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsConfiguration: Configuration {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        let userDefaultsKey = keyForFeatureWithIdentifier(feature)
        return userDefaults.bool(forKey: userDefaultsKey)
    }

    public func featureData(for feature: String) -> FeatureData? {
        let userDefaultsKey = keyForFeatureWithIdentifier(feature)
        let userDefaultsValue = userDefaults.object(forKey: userDefaultsKey) as AnyObject?
        guard let value = updateUserDefaults(userDefaultsValue) else { return nil }
        return FeatureData(feature: feature,
                     value: value,
                     title: nil,
                     group: nil)
    }
}

extension UserDefaultsConfiguration: MutableConfiguration {
    
    public func set(_ value: FeatureValue, feature: String) {
        updateUserDefaults(value: value, feature: feature)
    }

    public func deleteValue(feature: String) {
        userDefaults.removeObject(forKey: keyForFeatureWithIdentifier(feature))
    }
}

extension UserDefaultsConfiguration {
    
    private func keyForFeatureWithIdentifier(_ identifier: String) -> String {
        return "\(UserDefaultsConfiguration.userDefaultsKeyPrefix).\(identifier)"
    }
    
    private func updateUserDefaults(_ object: AnyObject?) -> FeatureValue? {
        if let object = object as? String {
            return object
        }
        else if let object = object as? NSNumber {
            return object.intValue// ???
        }
        return nil
    }
        
    private func updateUserDefaults(value: FeatureValue, feature: String) {
        userDefaults.set(value, forKey: keyForFeatureWithIdentifier(feature))
        DispatchQueue.main.async {
            let notificationCenter = NotificationCenter.default
            let feature = FeatureData(feature: feature, value: value)
            let userInfo = [FeatureFlagDidChangeNotificationFeatureKey: feature]
            notificationCenter.post(name: FeatureFlagConfigurationDidChangeNotification,
                                    object: self,
                                    userInfo: userInfo)
        }
    }
}

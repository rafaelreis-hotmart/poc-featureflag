//
//  FeatureFlagManager.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import Foundation

public protocol Configuration {
    func isFeatureEnabled(_ feature: String) -> Bool
    func featureData(for: String) -> FeatureData?
}


public protocol MutableConfiguration: Configuration {
    func set(_ value: FeatureValue, feature: String)
    func deleteValue(feature: String)
}


public let FeatureFlagConfigurationDidChangeNotification = Notification.Name("FeatureFlagDidChangeNotification")
public let FeatureFlagDidChangeNotificationFeatureKey = "FeatureFlagDidChangeNotificationFeatureKey"



final public class FeatureFlagManager {
    
    var configurations: [Configuration]
    
    public var useCache: Bool = false {
        didSet {
            if useCache != oldValue {
                resetCache()
            }
        }
    }
    
    private let queue = DispatchQueue(label: "com.hotmart.featureFlagManager")
    
    private var featureCache = [String : Bool]()
    private var featureDataCache = [String : FeatureData]()
    private var experimentCache = [String : String]()
    private var observersMap = [NSObject : NSObjectProtocol]()
    
    var mutableConfiguration: MutableConfiguration? {
        return configurations.first { $0 is MutableConfiguration } as? MutableConfiguration
    }
    
    public init(configurations: [Configuration]) {
        self.configurations = configurations
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(configurationDidChange), name: FeatureFlagConfigurationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FeatureFlagManager: MutableConfiguration {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        queue.sync {
            if useCache, let cachedFeature = featureCache[feature] {
                return cachedFeature
            }
            
            var enabled = false
            for (_, configuration) in configurations.enumerated() {
                if configuration.isFeatureEnabled(feature) {
                    enabled = true
                    break
                }
            }
            if useCache {
                featureCache[feature] = enabled
            }
            return enabled
        }
    }
    
    public func featureData(for feature: String) -> FeatureData? {
        queue.sync {
            if useCache, let cachedFeature = featureDataCache[feature] {
                return cachedFeature
            }
            
            var result: FeatureData? = nil
            for (_, configuration) in configurations.enumerated() {
                if let featureValue = configuration.featureData(for: feature) {
                    result = FeatureData(feature: feature,
                                   value: featureValue.value,
                                   title: featureValue.title,
                                   group: featureValue.group,
                                   source: "\(type(of: configuration))")
                    break
                }
            }
            if let result = result {
                if useCache {
                    if let _ = featureDataCache[feature] {
                        featureDataCache[feature] = result
                    }
                }
            }
            else {
                //"Feature not found for identifier '\(feature)'", .verbose)
            }
            return result
        }
    }
    
    public func set(_ value: FeatureValue, feature: String) {
        guard let mutableConfiguration = self.mutableConfiguration else { return }
        if useCache {
            queue.sync {
                featureDataCache[feature] = nil
            }
        }
        mutableConfiguration.set(value, feature: feature)
    }

    public func deleteValue(feature: String) {
        guard let mutableConfiguration = self.mutableConfiguration else { return }
        if useCache {
            queue.sync {
                featureDataCache[feature] = nil
            }
        }
        mutableConfiguration.deleteValue(feature: feature)
    }
}

extension FeatureFlagManager {
    
    public func registerForConfigurationsUpdates(_ object: NSObject, closure: @escaping (FeatureValue) -> Void) {
        self.deregisterFromConfigurationsUpdates(object)
        queue.sync {
            let queue = OperationQueue.main
            let name = FeatureFlagConfigurationDidChangeNotification
            let notificationsCenter = NotificationCenter.default
            let observer = notificationsCenter.addObserver(forName: name, object: nil, queue: queue) { notification in
                guard let feature = notification.userInfo?[FeatureFlagDidChangeNotificationFeatureKey] as? FeatureValue else { return }
                closure(feature)
            }
            observersMap[object] = observer
        }
    }
    
    public func deregisterFromConfigurationsUpdates(_ object: NSObject) {
        queue.sync {
            guard let observer = observersMap[object] else { return }
            NotificationCenter.default.removeObserver(observer)
            observersMap.removeValue(forKey: object)
        }
    }
    
    @objc private func configurationDidChange() {
        if useCache {
            resetCache()
        }
    }
}

extension FeatureFlagManager {
    
    public func resetCache() {
        queue.sync {
            featureCache = [String : Bool]()
            featureDataCache = [String : FeatureData]()
            experimentCache = [String : String]()
        }
    }
}



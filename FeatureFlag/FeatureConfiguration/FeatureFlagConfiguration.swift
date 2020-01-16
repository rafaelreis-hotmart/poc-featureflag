//
//  Configurations.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import Foundation

enum Features {
    static let darkModeEnabled = (name: "darkModeEnabled", value: false)
    static let maxNumberOfDownloads = (name: "maxNumberOfDownloads", value: 3)
    static let paymentEnabled = (name: "purchase_feature_enable", value: false)
}

class FeatureFlagConfigurationAccessor {
    
    lazy private(set) var featureManager: FeatureFlagManager = {
        let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        let fireBaseConfiguration = FirebaseConfiguration()
        let configs: [Configuration] = [userDefaultsConfiguration, fireBaseConfiguration]
        
        return FeatureFlagManager(configurations: configs)
    }()

    var maxNumberOfDownloads: Int {
        let feature = Features.maxNumberOfDownloads
        return featureManager.featureData(for: feature.name)?.intValue ?? feature.value
    }
    
    var canShowDarkMode: Bool {
        return featureManager.isFeatureEnabled(Features.darkModeEnabled.name)
    }
    
    var paymentEnabled: Bool {
        return featureManager.isFeatureEnabled(Features.paymentEnabled.name)
    }
}

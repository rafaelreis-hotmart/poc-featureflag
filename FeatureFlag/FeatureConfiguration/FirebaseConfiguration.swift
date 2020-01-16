//
//  FirebaseConfiguration
//  Copyright © 2020 ORafaelreis. All rights reserved.
//
import FirebaseCore
import FirebaseRemoteConfig

public class FirebaseConfiguration: Configuration {
    
    public init() {
        /* DOWNLOAD THE GoogleService.plist from the Firebase dashboard */
        let googleServicePlistURL = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist")
        if let _ = googleServicePlistURL {
            firebaseAppClass.configure()
            configured = true
            fetchTweaks()
        }
        else {
            debugPrint("\(self) couldn't find a GoogleService Plist. This is required for this configuration to function. No Tweak will be returned from queries.")
        }
    }
    
    // Google dependencies
    private var configured: Bool = false
    internal lazy var firebaseAppClass: FirebaseApp.Type = {
        return FirebaseApp.self
    }()
    internal lazy var remoteConfiguration: RemoteConfig = {
        return RemoteConfig.remoteConfig()
    }()
    
    private func fetchTweaks() {
        guard configured else { return }
        remoteConfiguration.configSettings = RemoteConfigSettings()
        remoteConfiguration.fetch { [weak self] (status, error) in
            if let error = error {
                debugPrint("Error while fetching Firebase configuration => \(error)")
            }
            else {
                self?.remoteConfiguration.activate(completionHandler: nil) // You can pass a completion handler if you want the configuration to be applied immediately after being fetched; otherwise it will be applied on next launch
                let notificationCentre = NotificationCenter.default
                notificationCentre.post(name: FeatureFlagConfigurationDidChangeNotification, object: self)
            }
        }
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        let configValue = remoteConfiguration.configValue(forKey: feature)
        guard configValue.source != .static else { return false }
        return configValue.boolValue
    }
    
    
    public func featureData(for feature: String) -> FeatureData? {
        guard configured else { return nil }
        let configValue = remoteConfiguration.configValue(forKey: feature)
        guard configValue.source != .static else { return nil }
        guard let stringValue = configValue.stringValue else { return nil }
        return FeatureData(feature: feature,
                     value: stringValue,
                     title: nil,
                     group: nil)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }
}

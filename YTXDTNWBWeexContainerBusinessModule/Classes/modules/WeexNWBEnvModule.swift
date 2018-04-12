//
//  WeexNWBEnvModule.swift
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 李龙龙 on 2018/2/8.
//

//import NWBBasicProviderModule

import UIKit

public extension WeexNWBEnvModule {
    
    static let shared = WeexNWBEnvModule()
    
    public func isTest() -> NSNumber {
        return 0
    }
    
    public func getVersionName() -> String? {
        return nil
    }
    
    public func getVersionCode() -> NSNumber? {
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String {
            if let versionCode = Int(text) {
                return NSNumber(value:versionCode)
            }
        }
        return nil
    }
    
    public func getAppId() -> String? {
        return nil
    }
    
    public func getChannelId() -> String {
        return ""
    }
    
    public func getClientType() -> String {
        return "iOS"
    }
    
    public func getDeviceToken() -> String? {
        return nil
    }
    
    public func getAll() -> NSDictionary {
        let versionName : Any = getVersionName() ?? ""
        let appId : Any = getAppId() ?? ""
        let deviceToken : Any = getDeviceToken() ?? ""
        return [
            "isTest" : isTest(),
            "versionName" : versionName,
            "versionCode" : getVersionCode() ?? 0,
            "appId" : appId,
            "channelId" : getChannelId(),
            "clientType" : getClientType(),
            "deviceToken": deviceToken
            
        ]
    }
    
    public func getSdkVersion() -> Int {
        return 0
    }
}

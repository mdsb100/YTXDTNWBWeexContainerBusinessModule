//
//  YTXDTNWBWeexContainerBusinessModule.swift
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 曹俊 on 2018/1/12.
//

import YTXModule

import WeexSDK
import ReactiveCocoa

import Foundation
import UIKit



@objc public class YTXDTNWBWeexContainerBusinessModule: YTXModule {
    
    static let openAppCountKey = "NGTOpenAppCountKey"
    static let kUserDefaultGroup = "group.com.baidao.NuggetApp"
    
    static let tabBarBundleURLString = "bundle:///hometab.js"
    
    static let weexContainerViewControllerURL = "object://YTXDTNWBWeexContainerBusinessModule/WeexContainerViewController"
    static let weexTabBarViewControllerURL = "object://YTXDTNWBWeexContainerBusinessModule/WeexTabBarViewController"
    static let weexHomePageTabViewControllerURL = "object://YTXDTNWBWeexContainerBusinessModule/WeexContainerViewController_HomePageTab"
    
    @objc class func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.startWeex()
                
        return true
    }
    
     public class func loadClass() {
        YTXModule.registerAppDelegateModule(YTXDTNWBWeexContainerBusinessModule.self)
//        let shared = YTXDTNWBWeexContainerBusinessModule.shared
    YTXModule.registerURLPattern(OBJECT_URL_YTXDTNWBWeexContainerBusinessModule_WeexContainerViewController, withTarget: self, with: #selector(weexVC(param:)))
        YTXModule.registerURLPattern(weexHomePageTabViewControllerURL, withTarget: self, with: #selector(switchToTab(param:)))
        YTXModule.registerURLPattern(weexTabBarViewControllerURL, withTarget: self, with: #selector(weexTabBarViewController))
    }
    
    public class func weexTabBarViewController() -> WeexContainerViewController? {
        return weexVC(param:[YTXModuleRouterParameterUserInfo: ["weexBundleURLString" : tabBarBundleURLString]])
    }
    
    public class func weexVC(param: [AnyHashable : Any]!) -> WeexContainerViewController?
    {
        if let userInfo = param[YTXModuleRouterParameterUserInfo] as? [AnyHashable : Any] {
            var weexBundleURL : URL? = userInfo["weexBundleURL"] as? URL
            let weexBundleURLString : String? = userInfo["weexBundleURLString"] as? String
            
            if weexBundleURL == nil {
                weexBundleURL = weexBundleURLString != nil ? URL(string: weexBundleURLString!) : nil
            }
            
            if let url = weexBundleURL {
                return WeexContainerViewController(weexBundleURL:url)
            }

        }
        return nil
    }
    
    //  跳转到指定Home Page的Tab
    public class func switchToTab(param: [AnyHashable : Any]!) {
        let userInfo = param[YTXModuleRouterParameterUserInfo] as? [AnyHashable: Any]
        var window = UIApplication.shared.keyWindow;
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows;
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindowLevelNormal && tmpWin.rootViewController?.isKind(of: UITabBarController.self) == true {
                    window = tmpWin;
                    break;
                }
            }
        }
        
        guard let tabs = window?.rootViewController as? UITabBarController else {
            return
        }
        
        guard let homepageNav = tabs.viewControllers?.first as? UINavigationController else {
            return
        }
        if homepageNav.presentedViewController != nil {
            homepageNav.presentedViewController?.dismiss(animated: false, completion: nil)
            homepageNav.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        if homepageNav.viewControllers.count > 1 {
            homepageNav.popViewController(animated: false)
        }
        guard let homePageVC = homepageNav.viewControllers.first as? WeexContainerViewController else {
            return
        }
        guard let retTag = userInfo?["tagString"], let tag = retTag as? String else {
            return
        }
        var index = 0
        switch tag {
        case "exclusiveNews":
            index = 0
        case "optionalStockNews":
            index = 1
        case "HKNews":
            index = 2
        case "USNews":
            index = 3
        case "foundNews":
            index = 4
        case "sevenTimesNews":
            index = 5

        default:
            break
        }

        homePageVC.switchTabPage(paras: ["pageIndex": index])
    }
    
}

extension YTXDTNWBWeexContainerBusinessModule {
    class func startWeex() {
        // Override point for customization after application launch.
        
        self.initWeex()
        self.initDowmloadManager()
        self.registerComponent()
        self.registerModule()
        self.registerProtocol()
    }
    
    private class func initWeex() {
        WXAppConfiguration.setAppGroup("group.com.baidao.NuggetApp")
        
        let info = Bundle.main.infoDictionary!
        
        let appName = info["CFBundleDisplayName"] as! String
        let appVersion = info["CFBundleShortVersionString"] as! String
        WXAppConfiguration.setAppName(appName)
        WXAppConfiguration.setAppVersion(appVersion)
        WXSDKEngine.initSDKEnvironment()
        WXLog.setLogLevel(WXLogLevel.off)
    }
    
    private class func initDowmloadManager() {
        
    }
    
    private class func registerProtocol() {
        WXSDKEngine.registerHandler(WeexImageDownloader(), with: WXImgLoaderProtocol.self)
        
    }
    
    private class func registerComponent() {
        
    }
    
    private class func registerModule() {
        WXSDKEngine.registerModule("ytx-env", with: WeexNWBEnvModule.self)
    }
}

extension UserDefaults {
    static let nwbGroup = UserDefaults(suiteName: "KK")
}








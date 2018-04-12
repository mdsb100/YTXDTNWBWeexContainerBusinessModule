//
//  YTXDTNWBWeexUtils.swift
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 曹俊 on 2018/2/28.
//

import UIKit

public class YTXDTNWBWeexUtils: NSObject {
    
    public static let bundlePrefix = "bundle://"
    
    static let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    static var searchFromDocument: Bool = {
        let nativeVersion = WeexNWBEnvModule.shared.getVersionName()!
        guard let folders = FileManager.default.subpaths(atPath: documentPath) else {
            return false
        }
        let infoJSONs = folders.flatMap() { (folder) in
            let path = documentPath + "/" + folder + "/bundle-info.json"
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
            return nil
        }
        let infoJSON = infoJSONs.first
        guard let infoJSONPath = infoJSON else {
            return false
        }
        guard let url = URL(string: "file://" + infoJSONPath), let data = try? Data(contentsOf: url) else {
            return false
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonObject as? [String: Any] else {
            return false
        }
        guard let weexBundleAppVersion = json["appVersion"] as? String else {
            return false
        }
        return weexBundleAppVersion == nativeVersion
    }()
    
    public static func flieURLWith(bundleURl: URL?) -> URL? {
        guard let url = bundleURl else {
            return nil
        }
        if url.absoluteString.hasPrefix(YTXDTNWBWeexUtils.bundlePrefix) {
            return searchFromDocument ? documentPath(for: url) : bundlePath(for: url)
        }
        else {
            return url
        }
    }
    
    public static func bundlePath(for url: URL) -> URL? {
        let frameworkBundle = Bundle(for: WeexContainerViewController.self)
        guard frameworkBundle.resourceURL != nil else {
            return nil
        }
        let urlPath = frameworkBundle.url(forResource: url.path, withExtension: nil, subdirectory: "YTXDTNWBWeexContainerBusinessModule.bundle/weex-bundle")
        return urlPath
    }
    
    public static func documentPath(for url: URL) -> URL? {
        return URL(string: "file://" + documentPath + "/weex-bundle" + url.path)
    }

}

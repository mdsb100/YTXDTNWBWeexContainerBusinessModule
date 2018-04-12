//
//  WeexImageDownloader.swift
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 曹俊 on 2018/1/15.
//

import Kingfisher
import WeexSDK

import Foundation

enum WeexFindLocalImageError: Error {
    case NotFound(String)
}

@objc class WeexImageDownloader : NSObject, WXImgLoaderProtocol
{
    public static let kingfinsherManager : KingfisherManager = {
        //缓存7天
        ImageCache.default.maxCachePeriodInSecond = 60 * 60 * 24 * 7
        return KingfisherManager.shared
    }()

    func downloadImage(withURL url: String!, imageFrame: CGRect, userInfo options: [AnyHashable : Any]! = [:], completed completedBlock: ((UIImage?, Error?, Bool) -> Void)!) -> WXImageOperationProtocol! {
        if url == nil {
            return WeexImageDownloaderOperation()
        }
        if url.hasPrefix(YTXDTNWBWeexUtils.bundlePrefix) {
            DispatchQueue.global().async {
                var err : Error? = WeexFindLocalImageError.NotFound(url)
                if let fileURL = YTXDTNWBWeexUtils.flieURLWith(bundleURl: URL(string:url)) {
                    var image : Image?
                    do {
                        let data = try Data.init(contentsOf: fileURL)
                        
                        if let x = DefaultCacheSerializer.default.image(with: data, options: [.preloadAllAnimationData]) {
                            image = x
                            err = nil
                        }
                    } catch {
                        err = error
                    }
                    DispatchQueue.main.async {
                        completedBlock(image, err, true)
                    }
                }
            }
            return WeexImageDownloaderOperation()
        }

        if let uurl = URL(string:url) {
            //Download or get from cache
            let downloadTask = WeexImageDownloader.kingfinsherManager.retrieveImage(with: ImageResource(downloadURL: uurl), options: [.preloadAllAnimationData], progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if completedBlock != nil {
                    completedBlock(image, error, true)
                }
            })
            
            return WeexImageDownloaderOperation(downloadTask)
        }

        return WeexImageDownloaderOperation()
    }

}

@objc class WeexImageDownloaderOperation : NSObject, WXImageOperationProtocol
{
    var downloadTask : RetrieveImageTask?
    init(_ downloadTask : RetrieveImageTask? )
    {
        self.downloadTask = downloadTask
    }
    
    convenience override init() {
        self.init(nil)
    }
    
    func cancel() {
        self.downloadTask?.cancel()
    }

}

//
//  YTXDTNWBWeexContainerViewController.swift
//  YTXDTNWBWeexContainerBusinessModule
//
//  Created by 曹俊 on 2018/1/15.
//

import YTXModule
import WeexSDK

import Foundation
import UIKit


@objc public class WeexContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Property
    
    private(set) var wxInstance: WXSDKInstance?

    let weexBundleURL: URL?
    private lazy var _weexBundleURL: URL? = {
        if let url = YTXDTNWBWeexUtils.flieURLWith(bundleURl: self.weexBundleURL) {
            return url
        }
        return self.weexBundleURL
    }()
    //TODO 加载时可以loading
//    private lazy var weexContainerView: UIView = {
//        let view = UIView()
//        self.view.addSubview(view)
//        view.translatesAutoresizingMaskIntoConstraints = false
//
//        var topConstant = self.topLayoutGuide.length
//        var botttomConstant = self.bottomLayoutGuide.length
//        //意味着不是满屏作为整个vc，而是sub vc的方式
//        if self.containerFrame != nil {
//            var topConstant = 0
//            var botttomConstant = 0
//        }
//
//        let left = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0)
//        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.topLayoutGuide.length)
//        let right = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0)
//        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: self.bottomLayoutGuide.length)
//
//        self.view.addConstraints([left, top, right, bottom])
//
////        view.snp.makeConstraints({ (make) in
////            make.top.equalTo(self.view)
////            make.bottom.equalTo(self.view)
////            make.left.equalTo(self.view)
////            make.right.equalTo(self.view)
////        })
//
//        return view
//    }()
    
    var containerFrame: CGRect?
    
    private var viewDidEverAppear = 0 // 第一位表示是否viewDidAppear，第二位表示是否created WeexInstance
    private var viewWillEverAppear = 0
    
    public var currentNeedNavi : Bool = true
    public var nextNeedNavi : Bool = false

    public var viewWillAppearFunc: ((Bool) -> Void)?
    public var viewDidAppearFunc: ((Bool) -> Void)?
    public var viewWillDisappearFunc: ((Bool) -> Void)?
    public var viewDidDisappearFunc: ((Bool) -> Void)?
    public var viewDidLoadFunc: (() -> Void)?
    
    
    
    public func setupNaviWhenPushNextVC(current : Bool, next : Bool) {
        self.currentNeedNavi = current
        self.nextNeedNavi = next
    }
    
    private func setupCreateHandlerWithWeexInstance(_ instance: WXSDKInstance) {
        instance.onCreate = { [unowned self, instance] (_: UIView?) -> Void in
            let view = instance.rootView!
            self.view.addSubview(view)
        }
    }
    
    private func setupFailedHandlerWithWeexInstance(_ instance: WXSDKInstance) {
        //生产环境绝对不能远程加载，除了有延时之外，还有如果地址没有，超时时间非常长，用户体验差
        instance.onFailed = { (error: Error?) -> Void in
            //TODO降级方案
        }
    }
    
    private func setupRenderFinishHandlerWithWeexInstance(_ instance: WXSDKInstance) {
        instance.renderFinish = { [unowned self] (view: UIView?) -> Void in
            
            self.viewDidEverAppear = self.viewDidEverAppear | 1 << 1
            self.viewWillEverAppear = self.viewWillEverAppear | 1 << 1
            if (self.viewWillEverAppear & 1) == 1 {
                self.unpdateWeexInstanceStateByEvent("viewwillappear")
            }
            
            if (self.viewDidEverAppear & 1) == 1 {
                self.updateWeexInstanceState(state: .WeexInstanceAppear)
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.weexBundleURL = nil
        super.init(coder: aDecoder)
    }
    
    public init(weexBundleURL: URL, containerFrame: CGRect? = nil) {
        self.weexBundleURL = weexBundleURL
        self.containerFrame = containerFrame
        super.init(nibName: nil, bundle: nil)
        self.wxInstance = self.initWeex()
    }
    
    class public func vcWithWeexBundleURL(_ weexBundleURL: URL) -> WeexContainerViewController {
        return WeexContainerViewController(weexBundleURL: weexBundleURL)
    }
    
    // MARK: - Life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.white
        //因为我们App全局会自己设置，所以自己不需要设置
//        self.hidesBottomBarWhenPushed = true
        YTXModule.registerAppDelegateObject(self)
        
        //当你的weex导航控制器不是wxRootViewController的时候，边缘退出手势就不会有效果，当你自定义的UINavigationController的时候需要加入手势
        self.addEdgePop()
        self.automaticallyAdjustsScrollViewInsets = false
        if let containerFrame = self.containerFrame {
           self.view.frame = containerFrame
        }
        
        //为了只执行一次
        if let instance = self.wxInstance {
            instance.frame = CGRect(origin:self.view.bounds.origin, size: self.view.bounds.size)
            self.renderWeex(instance)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRefreshInstance(_:)), name: NSNotification.Name(rawValue: "RefreshInstance"), object: nil)
        
        self.viewDidLoadFunc?()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
//        self.navigationItem.title = self._weexBundleURL?.absoluteString
        super.viewWillAppear(animated)
        if !self.currentNeedNavi && self.nextNeedNavi {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        viewWillEverAppear = 1 | viewWillEverAppear
        if (viewWillEverAppear & 1 << 1) == 1 << 1{
            unpdateWeexInstanceStateByEvent("viewwillappear")
        }
        self.viewWillAppearFunc?(animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidEverAppear = 1 | viewDidEverAppear
        if (viewDidEverAppear & 1 << 1) == 1 << 1{
            updateWeexInstanceState(state: .WeexInstanceAppear)
        }
        self.viewDidAppearFunc?(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.currentNeedNavi && self.nextNeedNavi {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        unpdateWeexInstanceStateByEvent("viewwilldisappear")
        self.viewWillDisappearFunc?(animated)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.updateWeexInstanceState(state: .WeexInstanceDisappear)
        self.viewDidDisappearFunc?(animated)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let instance = self.wxInstance {
            self.setupWeexFrame(instance)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.updateWeexInstanceState(state: .WeexInstanceMemoryWarning)
    }
    
    // MARK: - Application delegate
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.updateWeexInstanceState(state: .WeexInstanceBackground)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.updateWeexInstanceState(state: .WeexInstanceForeground)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func notificationRefreshInstance(_ notification : Notification) {
        self.refreshWeex()
    }
    
    // Weex events
    
    func refreshWeex() {
       self.wxInstance = self.initWeex()
        if let instance = self.wxInstance {
            self.renderWeex(instance)
        }
    }
    
    //给子类重写机会
    func addEdgePop() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func updateWeexInstanceState(state: WXState) {
        if let instance = self.wxInstance {
            if instance.state != state {
                instance.state = state
                //onCreate触发在sendQueue创建之前，通过async使得
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        if state == .WeexInstanceAppear {
                            WXSDKManager.bridgeMgr().fireEvent(instance.instanceId, ref: WX_SDK_ROOT_REF, type: "viewappear", params: nil, domChanges: nil)
                        } else if state == .WeexInstanceDisappear {
                            WXSDKManager.bridgeMgr().fireEvent(instance.instanceId, ref: WX_SDK_ROOT_REF, type: "viewdisappear", params: nil, domChanges: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func unpdateWeexInstanceStateByEvent(_ event: String) {
        if let instance = self.wxInstance {
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    WXSDKManager.bridgeMgr().fireEvent(instance.instanceId, ref: WX_SDK_ROOT_REF, type: event, params: nil, domChanges: nil)
                }
            }
        }
    }
    
    private func initWeex() -> WXSDKInstance? {
        if let bundleURL = self._weexBundleURL {
            var instance: WXSDKInstance
            self.wxInstance?.destroy()
            
            //猜测是预加载 moudle暴露到weex的方法
            if WXPrerenderManager.isTaskReady(bundleURL.absoluteString) {
                instance = WXPrerenderManager.instance(fromUrl: bundleURL.absoluteString) as! WXSDKInstance
            }
            else {
                instance = WXSDKInstance()
            }
            
            instance.pageObject = self
            instance.pageName = bundleURL.absoluteString
            instance.viewController = self
            
            self.setupCreateHandlerWithWeexInstance(instance)
            self.setupFailedHandlerWithWeexInstance(instance)
            self.setupRenderFinishHandlerWithWeexInstance(instance)
            
            return instance
        }

        return nil
    }
    
    private func renderWeex(_ instance: WXSDKInstance) {
        if let bundleURL = self._weexBundleURL {
            
            let para = bundleURL.absoluteString.range(of: "?") != nil ? "&random=" : "?random="
            let newURL: String = "\(bundleURL.absoluteString)\(para)\(arc4random())"
            
            //猜测是预加载 moudle暴露到weex的方法
            if WXPrerenderManager.isTaskReady(bundleURL.absoluteString) {
                WXMonitor.performancePoint(WXPTJSDownload, willStartWith: instance)
                WXMonitor.performancePoint(WXPTJSDownload, didEndWith: instance)
                WXMonitor.performancePoint(WXPTFirstScreenRender, willStartWith: instance)
                WXMonitor.performancePoint(WXPTAllRender, willStartWith: instance)
                //                WX_MONITOR_INSTANCE_PERF_START(WXPTJSDownload, _instance);
                //                WX_MONITOR_INSTANCE_PERF_END(WXPTJSDownload, _instance);
                //                WX_MONITOR_INSTANCE_PERF_START(WXPTFirstScreenRender, _instance);
                //                WX_MONITOR_INSTANCE_PERF_START(WXPTAllRender, _instance);
                WXPrerenderManager.render(fromCache: bundleURL.absoluteString)
            }
            else {
                instance.render(with: URL(string: newURL), options: [ "bundleUrl": bundleURL.absoluteString ], data: nil)
            }
        }
    }
    
    private func setupWeexFrame (_ instance: WXSDKInstance) {
        //当frame修改则修改wxInstance.frame
        if instance.rootView != nil && !instance.frame.equalTo(self.view.bounds) {
            instance.frame = CGRect(origin:self.view.bounds.origin, size: self.view.bounds.size)
        }
    }
    
    /// 切换至指定Tab，参数{"pageIndex": 0}
    @objc public func switchTabPage(paras: NSDictionary!) {
        WXSDKManager.bridgeMgr().fireEvent(wxInstance?.instanceId, ref: WX_SDK_ROOT_REF, type: "switchTabPage", params: paras as! [String: AnyObject], domChanges: nil)
    }
    
    @objc public func tabBarIndexChanged(_ title: NSString) {
        WXSDKManager.bridgeMgr().fireEvent(wxInstance?.instanceId, ref: WX_SDK_ROOT_REF, type: "switchTabIndex", params: ["tabTag": title], domChanges: nil)
    }
    
    deinit {
        YTXModule.unregisterAppDelegateObject(self)
        self.wxInstance?.destroy()
        NotificationCenter.default.removeObserver(self)
    }
}

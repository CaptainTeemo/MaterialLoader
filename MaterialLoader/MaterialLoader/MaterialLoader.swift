//
//  MaterialLoader.swift
//  MaterialLoader
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import Foundation
import UIKit

private let radius: CGFloat = 25
private let containerRatio: CGFloat = 2
private let scrollViewLoadingHeight: CGFloat = 100

public class MaterialLoader: UIView {
    private let loaderLayer = CAShapeLayer()
    
    private var lineWidth: CGFloat {
        return radius / 10
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        
        let shadowLayer = CALayer()
        shadowLayer.frame = CGRect(
            x: frame.width / 2 - radius * containerRatio / 2,
            y: frame.height / 2 - radius * containerRatio / 2,
            width: radius * containerRatio,
            height: radius * containerRatio
        )
        
        shadowLayer.shadowOffset = CGSize(width: 0, height: 5)
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.4).CGColor
        shadowLayer.shadowOpacity = 1
        layer.addSublayer(shadowLayer)
        
        let containerView = UIView()
        containerView.backgroundColor = .whiteColor()
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: radius * containerRatio,
            height: radius * containerRatio
        )
        containerView.center = center
        addSubview(containerView)
        
        let maskPath = UIBezierPath(ovalInRect: containerView.bounds)
        shadowLayer.shadowPath = maskPath.CGPath

        let containerMask = CAShapeLayer()
        containerMask.path = maskPath.CGPath
        containerView.layer.mask = containerMask
        
        loaderLayer.fillColor = nil
        loaderLayer.strokeColor = UIColor.redColor().CGColor
        loaderLayer.lineWidth = lineWidth
        loaderLayer.frame = CGRect(
            x: containerView.frame.width / 2 - radius / 2,
            y: containerView.frame.height / 2 - radius / 2,
            width: radius,
            height: radius
        )
        containerView.layer.addSublayer(loaderLayer)
        
        let path = UIBezierPath(ovalInRect: loaderLayer.bounds)
        loaderLayer.path = path.CGPath
        loaderLayer.strokeEnd = 1
    }
    
    private func startAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * M_PI
        rotation.duration = 0.8
        rotation.repeatCount = .infinity
        loaderLayer.addAnimation(rotation, forKey: "rotation")
        
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.repeatCount = Float.infinity
        strokeStart.duration = 1.2
        strokeStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        strokeStart.fromValue = 0.2
        strokeStart.toValue = 0.9
        strokeStart.autoreverses = true
        loaderLayer.addAnimation(strokeStart, forKey: "strokeStart")
    }
    
    // MARK: Public
    
    public class func showInView(view: UIView, loaderColor: UIColor = .redColor()) -> MaterialLoader {
        let loader = MaterialLoader(frame: view.bounds)
        loader.backgroundColor = UIColor(white: 0, alpha: 0)
        loader.center = view.center
        loader.loaderLayer.strokeColor = loaderColor.CGColor
        view.addSubview(loader)
        view.bringSubviewToFront(loader)
        
        loader.startAnimation()
        
        return loader
    }
    
    public class func addRefreshHeader(scrollView: UIScrollView, loaderColor: UIColor = .redColor(), action: () -> Void) {
        let loader = MaterialLoader(frame: CGRect(x: 0, y: 0, width: radius * containerRatio + 20, height: radius * containerRatio + 20))
        loader.loaderLayer.strokeColor = loaderColor.CGColor
        loader.center.x = UIScreen.mainScreen().bounds.size.width / 2
        let pullToRefresh = PullToRefresh(refreshView: loader, animator: loader)
        scrollView.addPullToRefresh(pullToRefresh, action: action)
    }
    
    public func dismiss() {
        removeFromSuperview()
    }
}

extension MaterialLoader: RefreshViewAnimator {
    func animateState(state: State) {
        switch state {
        case .Inital, .Finished:
            loaderLayer.removeAllAnimations()
        case .Loading:
            startAnimation()
        case .Releasing(let progress):
            loaderLayer.strokeEnd = progress
        }
    }
}


// This PullToRefresh stuff is copied from https://github.com/Yalantis/PullToRefresh

// MARK: Pull to refresh stuff

protocol RefreshViewAnimator {
    func animateState(state: State)
}

class PullToRefresh: NSObject {
    
    var hideDelay: NSTimeInterval = 0
    
    let refreshView: UIView
    var action: (() -> ())?
    
    private let animator: RefreshViewAnimator
    
    // MARK: - ScrollView & Observing
    
    private var scrollViewDefaultInsets = UIEdgeInsetsZero
    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving()
        }
        didSet {
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                addScrollViewObserving()
            }
        }
    }
    
    private func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
    }
    
    private func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    // MARK: - State
    
    var state: State = .Inital {
        didSet {
            animator.animateState(state)
            switch state {
            case .Loading:
                if let scrollView = scrollView where (oldValue != .Loading) {
                    scrollView.contentOffset = previousScrollViewOffset
                    scrollView.bounces = false
                    UIView.animateWithDuration(0.3, animations: {
                        let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets)
                        }, completion: { finished in
                            scrollView.bounces = true
                    })
                    
                    action?()
                }
            case .Finished:
                removeScrollViewObserving()
                UIView.animateWithDuration(1, delay: hideDelay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveLinear, animations: {
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                    }, completion: { finished in
                        self.addScrollViewObserving()
                        self.state = .Inital
                })
            default: break
            }
        }
    }
    
    // MARK: - Initialization
    
    init(refreshView: UIView, animator: RefreshViewAnimator) {
        self.refreshView = refreshView
        self.animator = animator
    }
    
    deinit {
        removeScrollViewObserving()
    }
    
    // MARK: KVO
    
    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override  func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.height
            
            switch offset {
            case 0 where (state != .Loading): state = .Inital
            case -refreshViewHeight...0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.Releasing(progress: 1) && scrollView?.dragging == false {
                    state = .Loading
                } else if state != State.Loading && state != State.Finished {
                    state = .Releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    // MARK: - Start/End Refreshing
    
    func startRefreshing() {
        if self.state != State.Inital {
            return
        }
        
        scrollView?.setContentOffset(CGPointMake(0, -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.27 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.state = State.Loading
        })
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
}

// MARK: - State enumeration

enum State:Equatable, CustomStringConvertible {
    case Inital, Loading, Finished
    case Releasing(progress: CGFloat)
    
    var description: String {
        switch self {
        case .Inital: return "Inital"
        case .Releasing(let progress): return "Releasing:\(progress)"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        }
    }
}

func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.Inital, .Inital): return true
    case (.Loading, .Loading): return true
    case (.Finished, .Finished): return true
    case (.Releasing, .Releasing): return true
    default: return false
    }
}


private var associatedObjectHandle: UInt8 = 0

extension UIScrollView {
    private(set) var pullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectHandle) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addPullToRefresh(pullToRefresh: PullToRefresh, action:()->()) {
        if self.pullToRefresh != nil {
            self.removePullToRefresh(self.pullToRefresh!)
        }
        
        self.pullToRefresh = pullToRefresh
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        //        view.frame = CGRectMake(0, -view.frame.size.height, self.frame.size.width, view.frame.size.height)
        view.frame.origin.y = -view.frame.height
        self.addSubview(view)
        self.sendSubviewToBack(view)
    }
    
    func removePullToRefresh(pullToRefresh: PullToRefresh) {
        self.pullToRefresh?.refreshView.removeFromSuperview()
        self.pullToRefresh = nil
    }
    
    public func startRefreshing() {
        pullToRefresh?.startRefreshing()
    }
    
    public func endRefreshing() {
        pullToRefresh?.endRefreshing()
    }
}

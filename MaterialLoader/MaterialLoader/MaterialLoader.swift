//
//  MaterialLoader.swift
//  MaterialLoader
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import Foundation
import UIKit

private let diameter: CGFloat = 25
private let containerRatio: CGFloat = 2
private let scrollViewLoadingHeight: CGFloat = 100

private let animationDuration: Double = 0.75
private let maxStroke: CGFloat = 0.75
private let minStroke: CGFloat = 0.05

private let numberOfArcs: CGFloat = 20

public final class MaterialLoader: UIView {
    private let loaderLayer = CAShapeLayer()
    private let containerView = UIView()
    
    private let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    private lazy var indeterminateAnimationGroup: CAAnimationGroup = {
        var animations = [CAAnimation]()
        var startValue: CGFloat = 0
        var startTime: Double = 0
        
        let valueScale = 1.0 / numberOfArcs
        
        repeat {
            animations += self.indeterminateAnimation(startValue, startTime: startTime, valueScale: valueScale)
            
            let delta = valueScale * (maxStroke + minStroke)
            startValue += (delta)
            startTime += animationDuration * 2
        } while fmod(floor(startValue * 1000), 1000) > 0
        
        let group = CAAnimationGroup()
        group.animations = animations
        group.duration = startTime
        group.repeatCount = .infinity
        group.removedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        
        return group
    }()
    
    private var lineWidth: CGFloat {
        return diameter / 10
    }
    
    private var progress: CGFloat = 0 {
        didSet {
            loaderLayer.strokeEnd = 1 / numberOfArcs * progress
            loaderLayer.transform = CATransform3DMakeRotation(progress * 3 * CGFloat(M_PI_2), 0, 0, 1)
        }
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
            x: frame.width / 2 - diameter * containerRatio / 2,
            y: frame.height / 2 - diameter * containerRatio / 2,
            width: diameter * containerRatio,
            height: diameter * containerRatio
        )
        
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2.5)
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.4).CGColor
        shadowLayer.shadowOpacity = 1
        layer.addSublayer(shadowLayer)
        
        containerView.backgroundColor = .whiteColor()
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: diameter * containerRatio,
            height: diameter * containerRatio
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
            x: containerView.frame.width / 2 - diameter / 2,
            y: containerView.frame.height / 2 - diameter / 2,
            width: diameter,
            height: diameter
        )
        
        containerView.layer.addSublayer(loaderLayer)
        
        let startAngle: CGFloat = 0
        let endAngle = CGFloat(numberOfArcs) * 6 + 1.5 * CGFloat(M_PI)
        
        let path = UIBezierPath(arcCenter: CGPoint(x: loaderLayer.bounds.midX, y: loaderLayer.bounds.midY), radius: diameter / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        loaderLayer.path = path.CGPath
        loaderLayer.strokeStart = 0
        loaderLayer.strokeEnd = 0.5
    }
    
    private func startAnimation() {
        
        let loopDuration: Double = 2
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * M_PI
        rotation.duration = loopDuration
        rotation.removedOnCompletion = false
        rotation.fillMode = kCAFillModeForwards
        rotation.repeatCount = .infinity
        containerView.layer.addAnimation(rotation, forKey: "rotation")
        
//        let start = CABasicAnimation(keyPath: "strokeStart")
//        start.duration = 0.4
//        start.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        start.fromValue = 0.1
//        start.toValue = 0.9
//        start.beginTime = 0.4
//        start.fillMode = kCAFillModeForwards
//        
//        let end = CABasicAnimation(keyPath: "strokeEnd")
//        end.duration = 0.4
//        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        end.fromValue = 0
//        end.toValue = 1
//        end.beginTime = 0
//        end.fillMode = kCAFillModeForwards
        
//        let group = CAAnimationGroup()
//        group.animations = [start, end, rotation]
//        group.repeatCount = .infinity
//        group.duration = loopDuration
//        group.removedOnCompletion = false
//        group.fillMode = kCAFillModeForwards
//        loaderLayer.addAnimation(group, forKey: "group")
        
        loaderLayer.addAnimation(indeterminateAnimationGroup, forKey: "group")
    }
    
    private func indeterminateAnimation(startValue: CGFloat, startTime: Double, valueScale: CGFloat) -> [CAAnimation] {
        let startHead = CABasicAnimation(keyPath: "strokeEnd")
        startHead.duration = animationDuration
        startHead.beginTime = startTime
        startHead.fromValue = startValue
        startHead.toValue = startValue + valueScale * (maxStroke + minStroke)
        startHead.timingFunction = timingFunction
        
        let startTail = CABasicAnimation(keyPath: "strokeStart")
        startTail.duration = animationDuration
        startTail.beginTime = startTime
        startTail.fromValue = startValue - valueScale * minStroke
        startTail.toValue = startValue
        startTail.timingFunction = timingFunction
        
        let endHead = CABasicAnimation(keyPath: "strokeEnd")
        endHead.duration = animationDuration
        endHead.beginTime = startTime + animationDuration
        endHead.fromValue = startValue + valueScale * (maxStroke + minStroke)
        endHead.toValue = startValue + valueScale * (maxStroke + minStroke)
        endHead.timingFunction = timingFunction
        
        let endTail = CABasicAnimation(keyPath: "strokeStart")
        endTail.duration = animationDuration
        endTail.beginTime = startTime + animationDuration
        endTail.fromValue = startValue
        endTail.toValue = startValue + valueScale * maxStroke
        endTail.timingFunction = timingFunction
        
        return [startHead, startTail, endHead, endTail]
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
        let loader = MaterialLoader(frame: CGRect(x: 0, y: 0, width: diameter * containerRatio + 20, height: diameter * containerRatio + 20))
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
            self.progress = progress
        }
    }
}


// This PullToRefresh stuff is stolen from https://github.com/Yalantis/PullToRefresh

// MARK: Pull to refresh stuff

protocol RefreshViewAnimator {
    func animateState(state: State)
}

public final class PullToRefresh: NSObject {
    
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
    
    override  public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
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
    
    public func addPullToRefresh(pullToRefresh: PullToRefresh, action:()->()) {
        if let pull = self.pullToRefresh {
            removePullToRefresh(pull)
        }
        
        self.pullToRefresh = pullToRefresh
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        view.frame.origin.y = -view.frame.height
        self.addSubview(view)
        self.sendSubviewToBack(view)
    }
    
    public func removePullToRefresh(pullToRefresh: PullToRefresh) {
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

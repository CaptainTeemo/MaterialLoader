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
    fileprivate let loaderLayer = CAShapeLayer()
    fileprivate let containerView = UIView()
    
    fileprivate let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    fileprivate lazy var indeterminateAnimationGroup: CAAnimationGroup = {
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
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        
        return group
    }()
    
    fileprivate var lineWidth: CGFloat {
        return diameter / 10
    }
    
    fileprivate var progress: CGFloat = 0 {
        didSet {
            loaderLayer.strokeEnd = 1 / numberOfArcs * progress
            loaderLayer.transform = CATransform3DMakeRotation(progress * 3 * CGFloat(M_PI_2), 0, 0, 1)
        }
    }
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        let shadowLayer = CALayer()
        shadowLayer.frame = CGRect(
            x: frame.width / 2 - diameter * containerRatio / 2,
            y: frame.height / 2 - diameter * containerRatio / 2,
            width: diameter * containerRatio,
            height: diameter * containerRatio
        )
        
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2.5)
        shadowLayer.shadowRadius = 3
        shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.4).cgColor
        shadowLayer.shadowOpacity = 1
        layer.addSublayer(shadowLayer)
        
        containerView.backgroundColor = .white
        containerView.frame = CGRect(
            x: 0,
            y: 0,
            width: diameter * containerRatio,
            height: diameter * containerRatio
        )
        containerView.center = center
        addSubview(containerView)
        
        let maskPath = UIBezierPath(ovalIn: containerView.bounds)
        shadowLayer.shadowPath = maskPath.cgPath

        let containerMask = CAShapeLayer()
        containerMask.path = maskPath.cgPath
        containerView.layer.mask = containerMask
        
        loaderLayer.fillColor = nil
        loaderLayer.strokeColor = UIColor.red.cgColor
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
        
        loaderLayer.path = path.cgPath
        loaderLayer.strokeStart = 0
        loaderLayer.strokeEnd = 0.5
    }
    
    fileprivate func startAnimation() {
        
        let loopDuration: Double = 2
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * M_PI
        rotation.duration = loopDuration
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = kCAFillModeForwards
        rotation.repeatCount = .infinity
        containerView.layer.add(rotation, forKey: "rotation")
        
        loaderLayer.add(indeterminateAnimationGroup, forKey: "group")
    }
    
    fileprivate func indeterminateAnimation(_ startValue: CGFloat, startTime: Double, valueScale: CGFloat) -> [CAAnimation] {
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
    
    public class func showInView(_ view: UIView, loaderColor: UIColor = .red) -> MaterialLoader {
        let loader = MaterialLoader(frame: view.bounds)
        loader.backgroundColor = UIColor(white: 0, alpha: 0)
        loader.center = view.center
        loader.loaderLayer.strokeColor = loaderColor.cgColor
        view.addSubview(loader)
        view.bringSubview(toFront: loader)
        
        loader.startAnimation()
        
        return loader
    }
    
    public class func addRefreshHeader(_ scrollView: UIScrollView, loaderColor: UIColor = .red, action: @escaping () -> Void) {
        let loader = MaterialLoader(frame: CGRect(x: 0, y: 0, width: diameter * containerRatio + 20, height: diameter * containerRatio + 20))
        loader.loaderLayer.strokeColor = loaderColor.cgColor
        loader.center.x = UIScreen.main.bounds.size.width / 2
        let pullToRefresh = PullToRefresh(refreshView: loader, animator: loader)
        scrollView.addPullToRefresh(pullToRefresh, action: action)
    }
    
    public func dismiss() {
        removeFromSuperview()
    }
}

extension MaterialLoader: RefreshViewAnimator {
    func animateState(_ state: State) {
        switch state {
        case .inital, .finished:
            loaderLayer.removeAllAnimations()
        case .loading:
            startAnimation()
        case .releasing(let progress):
            self.progress = progress
        }
    }
}


// This PullToRefresh stuff is stolen from https://github.com/Yalantis/PullToRefresh

// MARK: Pull to refresh stuff

protocol RefreshViewAnimator {
    func animateState(_ state: State)
}

public final class PullToRefresh: NSObject {
    
    var hideDelay: TimeInterval = 0
    
    let refreshView: UIView
    var action: (() -> ()) = {}
    
    fileprivate let animator: RefreshViewAnimator
    
    // MARK: - ScrollView & Observing
    
    fileprivate var scrollViewDefaultInsets = UIEdgeInsets.zero
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
    
    fileprivate func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &KVOContext)
    }
    
    fileprivate func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    // MARK: - State
    
    var state: State = .inital {
        didSet {
            animator.animateState(state)
            switch state {
            case .loading:
                if let scrollView = scrollView , (oldValue != .loading) {
                    scrollView.contentOffset = previousScrollViewOffset
                    scrollView.bounces = false
                    UIView.animate(withDuration: 0.3, animations: {
                        let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        
                        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets)
                        }, completion: { finished in
                            scrollView.bounces = true
                    })
                    
                    action()
                }
            case .finished:
                removeScrollViewObserving()
                UIView.animate(withDuration: 1, delay: hideDelay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                    }, completion: { finished in
                        self.addScrollViewObserving()
                        self.state = .inital
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
    
    fileprivate var KVOContext = "PullToRefreshKVOContext"
    fileprivate let contentOffsetKeyPath = "contentOffset"
    fileprivate var previousScrollViewOffset: CGPoint = CGPoint.zero
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.height
            
            switch offset {
            case 0 where (state != .loading): state = .inital
            case -refreshViewHeight...0 where (state != .loading && state != .finished):
                state = .releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.releasing(progress: 1) && scrollView?.isDragging == false {
                    state = .loading
                } else if state != State.loading && state != State.finished {
                    state = .releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    // MARK: - Start/End Refreshing
    
    func startRefreshing() {
        if self.state != State.inital {
            return
        }
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.27 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.state = State.loading
        })
    }
    
    func endRefreshing() {
        if state == .loading {
            state = .finished
        }
    }
}

// MARK: - State enumeration

enum State:Equatable, CustomStringConvertible {
    case inital, loading, finished
    case releasing(progress: CGFloat)
    
    var description: String {
        switch self {
        case .inital: return "Inital"
        case .releasing(let progress): return "Releasing:\(progress)"
        case .loading: return "Loading"
        case .finished: return "Finished"
        }
    }
}

func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.inital, .inital): return true
    case (.loading, .loading): return true
    case (.finished, .finished): return true
    case (.releasing, .releasing): return true
    default: return false
    }
}


private var associatedObjectHandle: UInt8 = 0

extension UIScrollView {
    fileprivate(set) var pullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectHandle) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addPullToRefresh(_ pullToRefresh: PullToRefresh, action:@escaping ()->()) {
        if let pull = self.pullToRefresh {
            removePullToRefresh(pull)
        }
        
        self.pullToRefresh = pullToRefresh
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        view.frame.origin.y = -view.frame.height
        self.addSubview(view)
        self.sendSubview(toBack: view)
    }
    
    public func removePullToRefresh(_ pullToRefresh: PullToRefresh) {
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

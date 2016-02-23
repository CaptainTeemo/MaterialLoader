//
//  MaterialLoader.swift
//  MaterialLoader
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import Foundation
import UIKit

public class MaterialLoader: UIView, UIScrollViewDelegate {
    private let loaderLayer = CAShapeLayer()
    private let containerView = UIView()
    private var scrollView:UIScrollView?
    private var animating: Bool = false
    public var delegate: MaterialLoaderDelegate?
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        let radius: CGFloat = 25
        let lineWidth: CGFloat = radius / 10
        let containerRatio: CGFloat = 2
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        containerView.backgroundColor = .whiteColor()
        containerView.frame = CGRect(x: 0, y: 0, width: radius * containerRatio, height: radius * containerRatio)
        containerView.center = center
        addSubview(containerView)
        
        let maskPath = UIBezierPath(ovalInRect: containerView.bounds)
        let containerMask = CAShapeLayer()
        containerMask.path = maskPath.CGPath
        containerView.layer.mask = containerMask
        
        loaderLayer.fillColor = nil
        loaderLayer.strokeColor = UIColor.redColor().CGColor
        loaderLayer.lineWidth = lineWidth
        loaderLayer.frame = CGRect(x: containerView.frame.width / 2 - radius / 2, y: containerView.frame.height / 2 - radius / 2, width: radius, height: radius)
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
        strokeStart.duration = 0.8
        strokeStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        strokeStart.fromValue = 0.4
        strokeStart.toValue = 0.9
        strokeStart.autoreverses = true
        loaderLayer.addAnimation(strokeStart, forKey: "strokeStart")
    }
    
    // MARK: Scroll View Delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let percent = (scrollView.contentOffset.y / -120)
        
        if !animating {
            self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            loaderLayer.strokeEnd = percent
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if (scrollView.contentOffset.y / -120) > 1 && !animating {
            
            self.delegate?.handleRefresh(self)
            
            animating = true
            self.startAnimation()
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                self.center = CGPointMake(self.superview!.frame.size.width / 2, 70)
                }, completion: {(bla) -> () in
                    
            })
        }
    }
    
    // MARK: Public
    
    public convenience init(scrollView: UIScrollView, delegate: MaterialLoaderDelegate) {
        
        self.init(frame: scrollView.frame)
        
        self.delegate = delegate
        
        self.center = CGPointMake(scrollView.frame.size.width / 2, -50)
        self.loaderLayer.strokeColor = UIColor.redColor().CGColor
        
        self.scrollView = scrollView
        self.scrollView?.delegate = self
        self.scrollView?.addSubview(self)
        self.scrollView?.bringSubviewToFront(self)
        
    }
    
    public class func showInView(view: UIView, loaderColor: UIColor = .redColor()) -> MaterialLoader {
        let loader = MaterialLoader(frame: view.bounds)
        loader.center = view.center
        loader.loaderLayer.strokeColor = loaderColor.CGColor
        view.addSubview(loader)
        view.bringSubviewToFront(loader)
        
        loader.startAnimation()
        
        return loader
    }
    
    public func dismiss() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.center = CGPointMake(self.superview!.frame.size.width / 2, -100)
            }) { (bla) -> Void in
                self.removeFromSuperview()
                self.animating = false
        }
    }
}

public protocol MaterialLoaderDelegate {
    func handleRefresh(loader: MaterialLoader)
}


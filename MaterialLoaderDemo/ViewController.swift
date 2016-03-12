//
//  ViewController.swift
//  MaterialLoaderDemo
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import UIKit
import MaterialLoader

func dispatchAfter(seconds: Double, action: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * Int64(seconds)), dispatch_get_main_queue(), action)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MaterialLoader.addRefreshHeader(scrollView) { () -> Void in
            dispatchAfter(3, action: { () -> Void in
                self.scrollView.endRefreshing()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showHud(sender: UIButton) {
        let loader = MaterialLoader.showInView(view, loaderColor: UIColor.greenColor())
        dispatchAfter(3, action: { () -> Void in
            loader.dismiss()
        })
    }

}


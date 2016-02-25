//
//  ViewController.swift
//  MaterialLoaderDemo
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import UIKit
import MaterialLoader

class ViewController: UIViewController, MaterialLoaderDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.frame = self.view.frame
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, 10000)
        
        let _ = MaterialLoader(scrollView: scrollView, delegate: self)
    
    }
    
    func handleRefresh(loader: MaterialLoader) {
        // do something
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            loader.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


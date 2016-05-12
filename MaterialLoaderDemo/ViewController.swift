//
//  ViewController.swift
//  MaterialLoaderDemo
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import UIKit
import MaterialLoader

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loader = MaterialLoader.showInView(view)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5)), dispatch_get_main_queue()) { () -> Void in
//            loader.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ViewController.swift
//  MaterialLoaderDemo
//
//  Created by CaptainTeemo on 1/11/16.
//  Copyright © 2016 CaptainTeemo. All rights reserved.
//

import UIKit
import MaterialLoader

func after(_ seconds: Double, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(seconds)) / Double(NSEC_PER_SEC), execute: action)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MaterialLoader.addRefreshHeader(scrollView) { () -> Void in
            after(5, action: { () -> Void in
                self.scrollView.endRefreshing()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showHud(_ sender: UIButton) {
        let loader = MaterialLoader.showInView(view)
        after(5, action: { () -> Void in
            loader.dismiss()
        })
    }

}


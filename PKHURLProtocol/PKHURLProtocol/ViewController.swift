//
//  ViewController.swift
//  PKHURLProtocol
//
//  Created by 潘柯宏 on 2019/8/26.
//  Copyright © 2019 潘柯宏. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    lazy var webView: UIWebView = {
        let webView = UIWebView(frame: UIScreen.main.bounds)
        self.view.addSubview(webView)
        webView.delegate = self
        return webView
    }()
    
    deinit {
        PKHRegisterURLProtocol.stopMonitor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        PKHRegisterURLProtocol.startMonitor()
        
        if let url = URL(string: "https://www.baidu.com") {
            webView.loadRequest(URLRequest(url: url))
        }
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
    }

}

extension ViewController: UIWebViewDelegate {
    
}


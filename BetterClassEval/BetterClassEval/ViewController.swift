//
//  ViewController.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/21/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController, WKUIDelegate {
    
    var webView = WKWebView()
    
    override func loadView() {
        
//        let screenSize = UIScreen.main.bounds
//        let screenWidth = screenSize.width
//        let screenHeight = screenSize.height
        
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.uiDelegate = self
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let target = URL(string: "https://weblogin.washington.edu/")!
        let request = URLRequest(url: target)
        webView.load(request)
    }
    
}

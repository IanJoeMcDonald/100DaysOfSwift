//
//  DetailViewController.swift
//  Project16
//
//  Created by Masipack Eletronica on 09/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var capital: Capital?

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let address = capital?.address {
            let url = URL(string: address)!
            webView.load(URLRequest(url:url))
            webView.allowsBackForwardNavigationGestures = false
        }
        
        title = capital?.title
    }
}

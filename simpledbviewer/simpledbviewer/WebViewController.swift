//
//  WebViewController.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/31/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit
import WebKit

enum PageType: String {
    typealias RawValue = String
    
    case license = "License"
    case disclaimer = "Disclaimer"
}

class WebViewController: UIViewController {

    private var webView: UIWebView?
    
    private var webKitView:WKWebView?
    
    private var activityIndicator : UIActivityIndicatorView?
    
    private let pages = [
        PageType.license: "https://raw.githubusercontent.com/maysamsh/simpledbviewer-ios/master/LICENSE",
        PageType.disclaimer : "https://raw.githubusercontent.com/aws/aws-sdk-ios/master/LICENSE"]
    
    var pageType: PageType = .disclaimer
    
    private func configureActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = .whiteLarge
        activityIndicator?.color = UIColor.gray
        activityIndicator?.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator!)
        self.view.bringSubviewToFront(activityIndicator!)
    }
    
    private func startActivityIndicatior(){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }
    }
    private func stopActivityIndicatior(){
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = pageType.rawValue
        
        if #available(iOS 11.0, *) {
            let _webKitView = WKWebView(frame: CGRect.zero)
            webKitView = _webKitView
            webKitView?.uiDelegate = self
            webKitView?.navigationDelegate = self
            if let webKit = webKitView {
                self.view.addSubview(webKit)
                webKit.translatesAutoresizingMaskIntoConstraints = false
                let topAdjust = self.topLayoutGuide.length
                webKit.topAnchor.constraint(equalTo: view.topAnchor, constant: topAdjust).isActive = true
                webKit.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                webKit.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                webKit.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                if let _pageURL =  pages[pageType] {
                    let url = URL(string: _pageURL)!
                    webKit.load(URLRequest(url: url))
                }
            }
            
        }else{
            
        }
        
        configureActivityIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopActivityIndicatior()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
       startActivityIndicatior()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopActivityIndicatior()
    }
}

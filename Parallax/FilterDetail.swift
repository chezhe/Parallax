//
//  FilterDetail.swift
//  Parallax
//
//  Created by 王亮 on 2020/2/16.
//  Copyright © 2020 王亮. All rights reserved.
//

import UIKit
import WebKit

class FilterDetail: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var filterName = "schindlers-list"
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let rightSideOptionButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "share"), style: .plain, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
        let url = URL(string: "https://parallax.chezhe.dev/filter?name=" + self.filterName)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    @objc func share(_ sender: Any) {
        let url = "https://parallax.chezhe.dev/filter?name=" + self.filterName
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
        self.navigationController?.present(activityController, animated: true, completion: nil)
    }
}

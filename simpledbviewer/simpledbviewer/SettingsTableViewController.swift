//
//  SettingsTableViewController.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/30/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private var webViewPageType = PageType.license
    
    private var statusBarShouldBeHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func configureUI(){
        self.navigationItem.title = "Settings"
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1,0):
            webViewPageType = .license
            performSegue(withIdentifier: "Show Web Page", sender: self)
        case (1,1):
            webViewPageType = .disclaimer
            performSegue(withIdentifier: "Show Web Page", sender: self)
        case (1,2):
            openHomepage()
        default:
            break
        }
    }

    private func openHomepage(){
        if let url = URL(string: "https://maysamsh.github.io/simpledbviewer-ios/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Web Page" {
            if let controller = segue.destination as? WebViewController {
                controller.pageType = webViewPageType
            }
        }
    }
 

}

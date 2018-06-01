//
//  MasterViewController.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/21/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    
    private var activityIndicator : UIActivityIndicatorView?
    
    private var domains:[String] = []
    
    private var isLoadingDomains = false
    
    private var statusBarShouldBeHidden = false
    
    fileprivate var container:NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDomains), name: NSNotification.Name(NotificationKeys.SetNewCredential.rawValue), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        activityIndicator?.center = self.tableView.center
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc private func handleRefresh(){
        loadDomainsList {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func refreshDomains(){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.loadDomainsList {
                self.stopActivityIndicatior()
            }
        }
    }
    
    private func configureUI(){
        self.navigationItem.title = "Home"
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.tableView.tableFooterView = UIView()
        configureActivityIndicator()
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        loadDomainsList()
    }
    
    private func configureActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle = .whiteLarge
        activityIndicator?.color = UIColor.gray
        activityIndicator?.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator!)
    }
    
    private func stopActivityIndicatior(){
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
    }
    
    private func realoadTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadDomainsList(completion: @escaping ()->() = {}){
        activityIndicator?.startAnimating()
        self.isLoadingDomains = true
        // Get credentials from CoreData
        container?.performBackgroundTask{ context in
            if let _credentials = AWSAccessInfo.get(context: context) {
                if let secret = _credentials.secret,
                    let key = _credentials.key,
                    let region = _credentials.region {
                    
                    let credential = Credential(secret: secret, key: key, region: region)
                    DispatchQueue.main.async {
                        // Config AWSSimpleDB with the saved credentials
                        SimpleDBHelper.setCredentials(with: credential, completion: { (valid, error) in
                            if valid {
                                SimpleDBHelper.listDomains { (domains, error) in
                                    self.stopActivityIndicatior()
                                    self.isLoadingDomains = false
                                    completion()
                                    if error == nil {
                                        self.domains.removeAll()
                                        self.domains = domains
                                        self.realoadTableView()
                                    }else{
                                        print(error?.localizedDescription ?? "error")
                                    }
                                }
                            }else{
                                // Invalid credentials
                                self.stopActivityIndicatior()
                                self.isLoadingDomains = false
                                completion()
                                if let _error = error {
                                    print(_error.localizedDescription)
                                }
                            }
                        })
                    }
                }
                
            }else{
                // First time launch
                DispatchQueue.main.async {
                    self.stopActivityIndicatior()
                    self.isLoadingDomains = false
                    completion()
                    self.statusBarShouldBeHidden = false
                    UIView.animate(withDuration: 0.25) {
                        self.setNeedsStatusBarAppearanceUpdate()
                    }
                    self.performSegue(withIdentifier: "Enter AWS Keys", sender: MasterViewController.self)
                }
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let index = tableView.indexPathForSelectedRow {
                if let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController {
                    controller.domain = domains[index.row]
                }
            }
        }else if segue.identifier == "Enter AWS Keys" {
            if let controller = segue.destination as? AWSKeysViewController {
                controller.delegate = self
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if domains.count == 0 {
            if isLoadingDomains {
                // Don't show the message while the list of domains is being downloaded
                tableView.setEmptyMessage("")
            }else{
                tableView.setEmptyMessage("There is no domain in this region.")
            }
        }else{
            tableView.restore()
        }
        return domains.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .blue
        cell.textLabel?.text = domains[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.sizeToFit()
        header.textLabel?.text = section == 0 ? "Domains" : nil
        return header
    }
}

extension MasterViewController: AWSCredentialCheck {
    func validated(valid: Bool, withCredential: Credential?) {
        container?.performBackgroundTask { context in
            if let credential = withCredential {
                AWSAccessInfo.add(info: credential, context: context)
            }
        }
        
        DispatchQueue.main.async {
            SimpleDBHelper.listDomains { (domains, error) in
                self.stopActivityIndicatior()
                if error == nil {
                    self.domains.removeAll()
                    self.domains = domains
                    self.realoadTableView()
                }else{
                    print(error?.localizedDescription ?? "error")
                }
            }
        }
    }
}


extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
    func changeStatusBar(alpha: CGFloat) {
        statusBarView?.alpha = alpha
    }
    
    func hideStatusBar() {
        UIView.animate(withDuration: 0.4) {
            self.statusBarView?.alpha = 0
        }
    }
    
    func showStatusBar() {
        UIView.animate(withDuration: 0.4) {
            self.statusBarView?.alpha = 1
        }
    }
}


//
//  DetailViewController.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/21/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit
import AWSSimpleDB

class DetailViewController: UIViewController {
    
    fileprivate var tableView = UITableView()
    
    fileprivate var domainItems = [AWSSimpleDBItem]()
    
    private var activityIndicator : UIActivityIndicatorView?
    
    private var sections = 0
    
    private var imageView = UIImageView()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var domain: String? {
        didSet {
            configureView()
        }
    }
    
    private  var selectedText = "xxxx"
    
    func configureView() {
        self.navigationItem.title = "Loading..."
        
        if let _domain = domain {
            getItems(inDomain: _domain)
        }
    }
    
    func getItems(inDomain: String){
        SimpleDBHelper.viewDomainContents(domain: inDomain) { (items, error) in
            self.stopActivityIndicatior()
            if let _items = items {
                self.sections = 1
                self.domainItems = _items
                DispatchQueue.main.async {
                    self.navigationItem.title = self.domain
                    self.tableView.reloadData()
                }
            }else{
                if error == nil {
                    DispatchQueue.main.async {
                        self.navigationItem.title = self.domain
                    }
                }else{
                    self.navigationItem.title = "Failed to load!"
                    print(error ?? "ERROR IN GET ITEMS")
                }
            }
        }
    }
    
    func createTableView(){
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor.white
        tableView.register(SimpleDBTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double(Float.leastNormalMagnitude)))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let topAdjust = self.topLayoutGuide.length
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAdjust).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func configureActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle = .whiteLarge
        activityIndicator?.color = UIColor.gray
        activityIndicator?.center = self.tableView.center
        self.view.addSubview(activityIndicator!)
    }
    
    private func stopActivityIndicatior(){
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.view.bringSubview(toFront: self.tableView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        activityIndicator?.center = self.tableView.center
        imageView.center = self.tableView.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        createTableView()
        configureActivityIndicator()
        if domain != nil {
            activityIndicator?.startAnimating()
        }else{
            self.navigationItem.title = "Select a domain"
        }
        
        let _width = self.view.bounds.width * 0.45
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: _width, height: _width))
        imageView.image = #imageLiteral(resourceName: "logo")
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        imageView.center = self.tableView.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return domainItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SimpleDBTableViewCell {
            cell.setup(items: domainItems[indexPath.row], numberOfRow: indexPath.row, highlight: (indexPath.row % 2) == 0)
            cell.isUserInteractionEnabled = true
            let longprss : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target:
                self, action: #selector(displayMenu(gesture:)))
            cell.addGestureRecognizer(longprss)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let cell = tableView.cellForRow(at: indexPath) as? SimpleDBTableViewCell {
            selectedText = cell.getText() 
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.sizeToFit()
        header.textLabel?.text = (section == 0) ? "Showing \(domainItems.count) items" : nil
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func copy(_ sender: Any?) {
        if sender != nil {
            UIPasteboard.general.string = selectedText
        }
    }
    
    @objc func displayMenu(gesture: UILongPressGestureRecognizer)
    {
        if gesture.state == UIGestureRecognizerState.began {
            self.becomeFirstResponder()
            let menu = UIMenuController.shared
            let position = gesture.location(ofTouch: 0, in: self.tableView)
            menu.setTargetRect(CGRect(x: position.x, y: position.y, width: 0, height: 0), in: self.tableView)
            menu.setMenuVisible(true, animated: true)
            self.view.setNeedsDisplay()
        }
        
    }
}

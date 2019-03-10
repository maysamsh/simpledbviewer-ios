//
//  AWSKeysViewController.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/29/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import UIKit
import AWSCore

protocol AWSCredentialCheck{
    func validated(valid: Bool, withCredential: Credential?)
}

class AWSKeysViewController: UIViewController, UITextFieldDelegate {
    var delegate: AWSCredentialCheck?
    
    var regions: AWSRegionType?
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var picker: UIPickerView!
    
    @IBOutlet var keyID: UITextField!
    
    @IBOutlet var secretKey: UITextField!
    
    private var statusBarShouldBeHidden = true
    
    private var activityIndicator : UIActivityIndicatorView?
    
    fileprivate var container:NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func configureActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = .whiteLarge
        activityIndicator?.color = UIColor.gray
        activityIndicator?.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
        self.view.addSubview(activityIndicator!)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
 
    
    private func stopActivityIndicatior(){
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.saveButton.isEnabled = true
        }
    }
    
    private func checkCredentialsAgainsUserInput(){
        activityIndicator?.startAnimating()
        saveButton.isEnabled = false
        let _secret  = secretKey.text
        let _access = keyID.text
        let _region = AWSRegionType.allRegions()[picker.selectedRow(inComponent: 0)]
        guard _secret != nil && _access != nil  else {return}
        let _credential = Credential(secret: _secret!, key: _access!, region: _region)
        SimpleDBHelper.setCredentials(with: _credential) { (successful, error) in
            self.stopActivityIndicatior()
            if successful {
                if let delegate = self.delegate {
                    // For the first time
                    delegate.validated(valid: true, withCredential: _credential)
                }else{
                    // From the settings
                    self.container?.performBackgroundTask { context in
                        AWSAccessInfo.update(info: _credential, context: context)
                        NotificationHelper.post(withKey: .SetNewCredential)
                    }
                }
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }else{
                var message = error?.localizedDescription ?? "Contact the developer"
                if (message.containsIgnoringCase(find: "com.amazonaws.AWSServiceErrorDomain")) {
                    message = "Check your Access Key and Secret Key"
                }
                if (message.containsIgnoringCase(find: "An SSL error has occurred and a secure connection to the server cannot be made")) {
                    message = "Did you select the right region?"
                }
                
                let alertController = UIAlertController(title: "Failed to get domains", message:
                    message, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        keyID.delegate = self
        secretKey.delegate = self
        configureActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.changeStatusBar(alpha: 0)
        
        self.statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        activityIndicator?.center = self.view.center
    }
    
    @IBAction func checkCredentials(_ sender: UIButton) {
        checkCredentialsAgainsUserInput()
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: - UIPickerView Delegate
extension AWSKeysViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AWSRegionType.allRegions().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let regions = AWSRegionType.allRegions()
        return regions[row]
    }
}

//MARK: UITextField Delegate
extension AWSKeysViewController {
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

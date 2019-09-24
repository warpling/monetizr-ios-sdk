//
//  ViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 13/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, ActivityIndicatorPresenter {
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var firstBlock: UIView!
    @IBOutlet var secondBlock: UIView!
    
    @IBOutlet var tokenField: UITextField!
    @IBOutlet var merchTagField: UITextField!
    @IBOutlet var textLabel: UILabel!
    
    @IBOutlet var openButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        tokenField.text = "4D2E54389EB489966658DDD83E2D1"
        merchTagField.text = "monetizr-sample-t-shirt" //"30-credits", "1794883780674"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func buttonTap(sender: UIButton) {
        if sender == openButton {
            self.showActivityIndicator()
            // Open product here
            textLabel.text = "Product loading..."
            Monetizr.shared.token = tokenField.text!
            var presentationStyle = UIModalPresentationStyle.overCurrentContext
            if UIDevice.current.userInterfaceIdiom == .pad {
                presentationStyle = UIModalPresentationStyle.formSheet
            }
            Monetizr.shared.getProductForTag(tag: merchTagField.text!, presenter: self, presentationStyle: presentationStyle) { success, error, product  in
                self.hideActivityIndicator()
                // Show some error if needed
                if success {
                    self.textLabel.text = "Product was loaded"
                }
                else {
                    //self.textLabel.text = "Some error received - developer should look for error"
                    self.textLabel.text = error?.localizedDescription
                }
            }
        }
    }

}

// Extension to dismiss keyboard when tapped in blank space
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//
//  ViewController.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 13/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit
import McPicker

class ViewController: UIViewController, UITextFieldDelegate, ActivityIndicatorPresenter {
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var firstBlock: UIView!
    @IBOutlet var secondBlock: UIView!
    
    @IBOutlet var tokenField: UITextField!
    @IBOutlet var merchTagField: UITextField!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var themeLabel: UILabel!
    @IBOutlet var langCodeLabel: UILabel!
    
    @IBOutlet var openButton: UIButton!
    @IBOutlet var tshirtButton: UIButton!
    @IBOutlet var pinButton: UIButton!
    @IBOutlet var giftcardButton: UIButton!
    @IBOutlet var changeThemeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        tokenField.text = "4D2E54389EB489966658DDD83E2D1" //"3adca63cc172c5ae919e5a2529f4f2a8" //"4D2E54389EB489966658DDD83E2D1"
        merchTagField.text = ""
        // Test tags - "free_t_shirt", "Sample pin", "Sample shirt", "blackbox_alt_socks",
        
        // Show device locale
        langCodeLabel.text = Monetizr.shared.localeCodeString
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
            showProductWithTag(tag: merchTagField.text!)
        }
        if sender == tshirtButton {
            showProductWithTag(tag: "T-shirt")
        }
        if sender == pinButton {
            showProductWithTag(tag: "Pin")
        }
        if sender == giftcardButton {
            showProductWithTag(tag: "Gift_Card")
        }
        if sender == changeThemeButton {
            self.pickTheme()
        }
    }
    
    func showProductWithTag(tag: String) {
        self.showActivityIndicator()
        // Open product here
        textLabel.text = "Product loading..."
        Monetizr.shared.token = tokenField.text!
        var presentationStyle = UIModalPresentationStyle.overCurrentContext
        if #available(iOS 13.0, *) {
            presentationStyle = UIModalPresentationStyle.automatic
        }
        
        Monetizr.shared.showProduct(tag: tag, playerID: "Test Player", presenter: self, presentationStyle: presentationStyle) { success, error, product  in
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
    
    func pickTheme() {
        let data: [[String]] = [
            ["Default theme", "Black theme"]
        ]
        let mcPicker = McPicker(data: data)
        if #available(iOS 13.0, *) {
            mcPicker.pickerBackgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            mcPicker.pickerBackgroundColor = .white
        }
        mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.themeLabel.text = name
                if name == "Default theme" {
                    Monetizr.shared.setTheme(theme: .system)
                }
                if name == "Black theme" {
                    Monetizr.shared.setTheme(theme: .black)
                }
            }
        }, cancelHandler: {
           
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
            
        })
    }
}


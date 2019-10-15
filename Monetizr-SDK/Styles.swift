//
//  Styles.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 15/10/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

// Styles
extension UIView {
    func backgroundViewStyle() {
        if Monetizr.shared.chosenTheme == .Black {
            self.backgroundColor = UIColor(hex: 0x121212)
        }
        else {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    func variantOptionsContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear //UIColor(hex: 0x231f20)
        self.addBlurEffect(style: .dark)
    }
    
    func imageCarouselContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        if Monetizr.shared.chosenTheme == .Black {
            self.backgroundColor = UIColor(hex: 0xc1c1c1)
        }
        else {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    func descriptionContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
}

extension UIStackView {
    // Styles
    func checkoutButtonBackgroundViewStyle() {
        self.axis = NSLayoutConstraint.Axis.horizontal
        self.distribution = UIStackView.Distribution.fillEqually
        self.alignment = UIStackView.Alignment.leading
        self.spacing = 10.0
        self.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.isLayoutMarginsRelativeArrangement = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIButton {
    
    // Styles
    func closeProductButtonStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.setTitle("✕", for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    func checkoutProductButtonStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(NSLocalizedString("Checkout", comment: "Checkout"), for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.height(constant: 50)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
  
        if Monetizr.shared.chosenTheme == .Black {
            self.backgroundColor = UIColor(hex: 0x121212)
            self.layer.borderColor = UIColor.white.cgColor
            self.setTitleColor(UIColor.white, for: .normal)
        }
        else {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.systemBackground
                self.layer.borderColor = UIColor.label.cgColor
                self.setTitleColor(UIColor.label, for: .normal)
            } else {
                // Fallback on earlier versions
                self.backgroundColor = UIColor.white
                self.layer.borderColor = UIColor.globalTint.cgColor
                self.setTitleColor(UIColor.globalTint, for: .normal)
            }
        }
    }
}

extension UILabel {
    func optionNameStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 14, weight: UIFont.Weight.light)
        self.text = self.text?.uppercased()
        self.numberOfLines = 1
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func optionValueStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .white //UIColor(hex: 0x007aff)
        self.font = .systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        self.numberOfLines = 1
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func priceLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        self.numberOfLines = 1
        self.textAlignment = .right
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
        
        if Monetizr.shared.chosenTheme == .Black {
            self.textColor = UIColor(hex: 0xE0093B)
        }
        else {
            if #available(iOS 13.0, *) {
                self.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                self.textColor = .globalTint
            }
        }
    }
    
    func discountPriceLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .lightGray
        self.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        self.numberOfLines = 1
        self.textAlignment = .right
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func titleLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
        
        if Monetizr.shared.chosenTheme == .Black {
            self.textColor = .white
        }
        else {
            if #available(iOS 13.0, *) {
                self.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                self.textColor = UIColor.black
            }
        }
    }
}

extension UITextView {
    func descriptionTextViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.font = .systemFont(ofSize: 16, weight: UIFont.Weight.light)
        self.isSelectable = false
        self.isEditable = false
        self.isScrollEnabled = false
        
        if Monetizr.shared.chosenTheme == .Black {
            self.textColor = .white
        }
        else {
            if #available(iOS 13.0, *) {
                self.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                self.textColor = UIColor.black
            }
        }
    }
}

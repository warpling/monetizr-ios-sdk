//
//  Extensions.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 21/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    
    // Styles
    func checkoutButtonBackgroundViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
    }
    
    func variantOptionsContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(hex: 0x231f20)
    }
}

extension UIButton {
    
    // Styles
    
    func closeProductButtonStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.setTitle("✕", for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
        self.setTitleColor(UIColor.black, for: .normal)
    }
    
    func checkoutProductButtonStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        self.setTitle(NSLocalizedString("Checkout", comment: "Checkout"), for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = 5
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}

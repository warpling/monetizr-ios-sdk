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
    
    // Safe area
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
    
    // Size
    
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }
    
    func width(constant: CGFloat) {
        setConstraint(value: constant, attribute: .width)
    }
    
    func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }
    
    func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        let constraint =
            NSLayoutConstraint(item: self,
                               attribute: attribute,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: value)
        self.addConstraint(constraint)
    }
    
    // Styles
    func variantOptionsContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear //UIColor(hex: 0x231f20)
        self.addBlurEffect(style: .dark)
    }
    
    func imageCarouselContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(hex: 0xc1c1c1)
    }
    
    func descriptionContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    func addBlurEffect(style: UIBlurEffect.Style)
    {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
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
        self.backgroundColor = UIColor(hex: 0x121212) //UIColor(hex: 0x007aff)
        self.setTitle(NSLocalizedString("Checkout", comment: "Checkout"), for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        self.height(constant: 50)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
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

extension UILabel {
    func optionNameStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
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
        self.font = .systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        self.numberOfLines = 1
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func priceLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = UIColor(hex: 0xE0093B) //UIColor(hex: 0x007aff)
        self.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        self.numberOfLines = 1
        self.textAlignment = .right
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func titleLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .white
        self.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
}

extension UITextView {
    func descriptionTextViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = .white
        self.font = .systemFont(ofSize: 16)
        self.isSelectable = false
        self.isEditable = false
        self.isScrollEnabled = false
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UIImage {
    
    class func disclosureIndicator() -> UIImage? {
        let disclosureCell = UITableViewCell()
        disclosureCell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        for view in disclosureCell.subviews {
            if let button = view as? UIButton {
                if let image = button.backgroundImage(for: UIControl.State.normal) {
                    return image
                }
            }
        }
        return nil
    }
}

extension String {
    func priceFormat(currency:String)->String{
        let convertPrice = NSNumber(value: Double(self)!)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        let convertedPrice = formatter.string(from: convertPrice)
        return convertedPrice!
    }
}

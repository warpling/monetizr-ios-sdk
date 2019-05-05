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
    
    func imageCarouselContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(hex: 0xc1c1c1)
    }
    
    func descriptionContainerViewStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
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
        self.backgroundColor = UIColor(hex: 0x007aff)
        self.setTitle(NSLocalizedString("Checkout", comment: "Checkout"), for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
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

extension UILabel {
    func priceLabelStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.textColor = UIColor(hex: 0x007aff)
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
        self.numberOfLines = 1
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func optionNameStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        self.textColor = .lightGray
        self.backgroundColor = .clear
        self.numberOfLines = 1
        self.textAlignment = .left
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.7
    }
    
    func optionValueStyle() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        self.textColor = UIColor(hex: 0x007aff)
        self.backgroundColor = .clear
        self.numberOfLines = 1
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

extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0
        
        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font!], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth
        
        return contentSize
    }
    
    func sizeForOptionName() {
        //self.sizeToFit()
        self.padding = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        self.frame.size.width = self.frame.size.width+self.padding!.left+self.padding!.right
        self.frame.size.height = self.frame.size.height+self.padding!.top+self.padding!.bottom
    }
    
    func sizeForOptionValue() {
        //self.sizeToFit()
        self.padding = UIEdgeInsets(top: 27, left: 10, bottom: 0, right: 10)
        self.frame.size.width = self.frame.size.width+self.padding!.left+self.padding!.right
        self.frame.size.height = self.frame.size.height+self.padding!.top+self.padding!.bottom
    }
}

//
//  ActivityIndicatorPresenter.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 06/05/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

/// Used for ViewControllers that need to present an activity indicator when loading data.
public protocol ActivityIndicatorPresenter {
    
    /// The activity indicator
    var activityIndicator: UIActivityIndicatorView { get }
    
    /// Show the activity indicator in the view
    func showActivityIndicator()
    
    /// Hide the activity indicator in the view
    func hideActivityIndicator()
}

public extension ActivityIndicatorPresenter where Self: UIViewController {
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            
            if #available(iOS 13.0, *) {
                self.activityIndicator.style = .large
            } else {
                // Fallback on earlier versions
                self.activityIndicator.style = .whiteLarge
            }
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80) //or whatever size you would like
            self.activityIndicator.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.height / 2)
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
}

//
//  ProductDescriptionScrollView.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 22/09/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

class ProductDescriptionScrollView: UIScrollView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < 0 || point.x < 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func scrollToTop(animated: Bool) {
        //if self.contentSize.height < self.bounds.size.height { return }
        let desiredOffset = CGPoint(x: 0, y: 0)
        setContentOffset(desiredOffset, animated: false)
    }
}

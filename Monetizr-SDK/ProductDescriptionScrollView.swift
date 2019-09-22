//
//  ProductDescriptionScrollView.swift
//  Monetizr-v3-sample-app
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
}

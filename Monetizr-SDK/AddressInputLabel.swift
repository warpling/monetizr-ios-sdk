//
//  AddressInputLabel.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 12/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import UIKit

class AddressInputLabel: UILabel {

   override func drawText(in rect: CGRect) {
       let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
       super.drawText(in: rect.inset(by: insets))
   }
}

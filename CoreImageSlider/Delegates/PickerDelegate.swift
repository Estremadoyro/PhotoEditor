//
//  PickerDelegate.swift
//  CoreImageSlider
//
//  Created by Leonardo  on 20/01/22.
//

import UIKit

protocol PickerDelegate: AnyObject {
  func didSelectPicture(picture: UIImage)
}

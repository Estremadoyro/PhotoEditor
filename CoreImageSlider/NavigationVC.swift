//
//  NavigationVC.swift
//  CoreImageSlider
//
//  Created by Leonardo  on 20/01/22.
//

import UIKit

class NavigationVC: UINavigationController {
  let rootVC: UIViewController = {
    let vc = MainVC()
    return vc
  }()

  init() {
    super.init(rootViewController: rootVC)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

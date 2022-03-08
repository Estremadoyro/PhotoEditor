//
//  PHPicker.swift
//  CoreImageSlider
//
//  Created by Leonardo  on 20/01/22.
//

import Foundation
import PhotosUI

class PHPicker: PHPickerViewControllerDelegate {
  weak var pickerDelegate: PickerDelegate?

  lazy var photoPickerVC: PHPickerViewController = {
    let picker = PHPickerViewController(configuration: config())
    picker.modalPresentationStyle = .fullScreen
    picker.delegate = self
    print("picker configured")
    return picker
  }()

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true, completion: nil)
    let itemProvider = results.first?.itemProvider

    if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
        guard let image = reading as? UIImage, error == nil else { return }
        DispatchQueue.main.async { [weak self] in
          self?.pickerDelegate?.didSelectPicture(picture: image)
        }
      }
    }
  }

  private func config() -> PHPickerConfiguration {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.selectionLimit = 1
    config.filter = .images
    return config
  }

  deinit {
    print("deinit \(self)")
  }
}

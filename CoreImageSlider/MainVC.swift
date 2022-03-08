//
//  ViewController.swift
//  CoreImageSlider
//
//  Created by Leonardo  on 19/01/22.
//

import CoreImage
import UIKit

enum Sliders: String {
  case intensitySlider = "intensity-slider"
  case radiusSlider = "radius-slider"
}

class MainVC: UIViewController {
  private var picker: PHPicker?
  private let radiusAvailableFilters: [String] = [kCIInputRadiusKey]
  private let intensityAvailableFilters: [String] = [kCIInputIntensityKey, kCIInputScaleKey, kCIInputCenterKey]
  var context: CIContext!

  var currentFilter: CIFilter? {
    didSet {
      intensitySlider.isUserInteractionEnabled = validateSlider(sliderAvailableFilters: intensityAvailableFilters)
      radiusSlider.isUserInteractionEnabled = validateSlider(sliderAvailableFilters: radiusAvailableFilters)
      intensitySlider.value = 0.1
      radiusSlider.value = 0.1
      print(intensitySlider.isUserInteractionEnabled)
      print(radiusSlider.isUserInteractionEnabled)
    }
  }

  var currentPicture: UIImage? {
    didSet {
      imageView.image = currentPicture
      imageView.alpha = 0
      intensitySlider.isUserInteractionEnabled = validatePicture(photo: imageView.image)
      radiusSlider.isUserInteractionEnabled = validatePicture(photo: imageView.image)
      intensitySlider.value = 0.1
      radiusSlider.value = 0.1
    }
  }

  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.distribution = .equalCentering
    stack.addArrangedSubview(imageContainerView)
    stack.addArrangedSubview(intensityStackView)
    stack.addArrangedSubview(radiusStackView)
    stack.addArrangedSubview(buttonsStackView)
    return stack
  }()

  private lazy var imageContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.systemGray5
    view.addSubview(imageView)
    return view
  }()

  private let imageView: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = UIImage(systemName: "photo")
    image.tintColor = UIColor.systemBlue.withAlphaComponent(0.2)
    image.contentMode = .scaleAspectFit
    image.clipsToBounds = true
    return image
  }()

  private lazy var intensityStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .fill
    stack.addArrangedSubview(intensityLabel)
    stack.addArrangedSubview(intensitySlider)
    return stack
  }()

  private lazy var intensitySlider: UISlider = {
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumValue = 0.1
    slider.maximumValue = 1
    slider.isContinuous = true
    slider.accessibilityIdentifier = Sliders.intensitySlider.rawValue
    slider.isUserInteractionEnabled = validatePicture(photo: imageView.image)
    slider.addTarget(self, action: #selector(effectSliderDidChange), for: .valueChanged)
    return slider
  }()

  private let intensityLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Intensity"
    label.textColor = UIColor.white
    label.font = UIFont.boldSystemFont(ofSize: 22)
    return label
  }()

  private lazy var radiusStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .fill
    stack.addArrangedSubview(radiusLabel)
    stack.addArrangedSubview(radiusSlider)
    return stack
  }()

  private lazy var radiusSlider: UISlider = {
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumValue = 0.00
    slider.maximumValue = 200
    slider.isContinuous = true
    slider.accessibilityIdentifier = Sliders.radiusSlider.rawValue
    slider.isUserInteractionEnabled = validatePicture(photo: imageView.image)
    slider.addTarget(self, action: #selector(effectSliderDidChange), for: .valueChanged)
    return slider
  }()

  private let radiusLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Radius"
    label.textColor = UIColor.white
    label.font = UIFont.boldSystemFont(ofSize: 22)
    return label
  }()

  private lazy var buttonsStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .fill
    stack.spacing = 10
    stack.addArrangedSubview(changeFilterBtn)
    stack.addArrangedSubview(saveBtn)
    return stack
  }()

  private let changeFilterBtn: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Select Filter", for: .normal)
    btn.setTitleColor(UIColor.systemBlue, for: .normal)
    btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
    btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    btn.addTarget(self, action: #selector(changeFilter), for: .touchUpInside)
    return btn
  }()

  private let saveBtn: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("Save", for: .normal)
    btn.setTitleColor(UIColor.systemBlue, for: .normal)
    btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
    btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    btn.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
    return btn
  }()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemGray6
    intensitySlider.isUserInteractionEnabled = validateSlider(sliderAvailableFilters: intensityAvailableFilters)
    radiusSlider.isUserInteractionEnabled = validateSlider(sliderAvailableFilters: radiusAvailableFilters)
    configNavbar()
    setupSubViews()
    setupConstraints()
    configCI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if picker != nil { picker = nil }
  }
}

extension MainVC {
  private func configNavbar() {
    title = "Photo Editor"
    let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    navigationItem.rightBarButtonItems = [addBtn]
  }

  private func setupSubViews() {
    view.addSubview(mainStackView)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

      imageContainerView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.7),
      intensityStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.1),
      radiusStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.1),
      buttonsStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.1),

      intensityLabel.widthAnchor.constraint(equalTo: intensityStackView.widthAnchor, multiplier: 0.25),
      intensitySlider.widthAnchor.constraint(equalTo: intensityStackView.widthAnchor, multiplier: 0.75),

      radiusLabel.widthAnchor.constraint(equalTo: radiusStackView.widthAnchor, multiplier: 0.25),
      radiusSlider.widthAnchor.constraint(equalTo: radiusStackView.widthAnchor, multiplier: 0.75),

      changeFilterBtn.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, multiplier: 0.5, constant: -5),
      saveBtn.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, multiplier: 0.5, constant: -5),

      imageView.topAnchor.constraint(equalTo: imageContainerView.layoutMarginsGuide.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: imageContainerView.layoutMarginsGuide.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: imageContainerView.layoutMarginsGuide.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: imageContainerView.layoutMarginsGuide.trailingAnchor),
    ])
  }
}

extension MainVC {
  @objc private func effectSliderDidChange(_ sender: UISlider!) {
    guard validatePicture(photo: imageView.image) else { return }

    guard let currentSlider = Sliders(rawValue: sender.accessibilityIdentifier!) else { return }
    applyProcessing(currentSlider: currentSlider)
    print("slider value: \(sender.value)")
  }
}

extension MainVC: PickerDelegate {
  @objc private func importPicture() {
    picker = PHPicker()
    picker?.pickerDelegate = self
    let pickerVC = picker?.photoPickerVC
    guard let pickerVC = pickerVC else { return }
    present(pickerVC, animated: true, completion: nil)
  }

  func didSelectPicture(picture: UIImage) {
    // Deallocating PHPicker after picture has been selected
    picker = nil
    currentPicture = picture
    UIView.animate(withDuration: 1, delay: 0, options: [], animations: { self.imageView.alpha = 1 }, completion: nil)
    if currentFilter == nil {
      currentFilter = CIFilter(name: "CISepiaTone")
      changeFilterBtn.setTitle(currentFilter?.name, for: .normal)
    }
    intensitySlider.value = 0
    print("picture: \(picture)")
    guard let currentPicture = self.currentPicture else { return }
    let beginImage = CIImage(image: currentPicture)
    currentFilter?.setValue(beginImage, forKey: kCIInputImageKey)
  }
}

extension MainVC {
  private func configCI() {
    // Creating context is computational expensive
//    currentFilter = CIFilter(name: "CISepiaTone")
    context = CIContext()
  }

  private func applyProcessing(currentSlider: Sliders) {
    guard let ciImage = currentFilter?.outputImage else { return }
    // all available filter input parameters
    guard let inputKeys = currentFilter?.inputKeys else { return }
    // Filters support different settings, not all of them support Intensity
    switch currentSlider {
      case Sliders.intensitySlider:
        if inputKeys.contains(kCIInputIntensityKey) {
          currentFilter?.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
          currentFilter?.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
          currentFilter?.setValue(CIVector(x: currentPicture!.size.width / 2, y: currentPicture!.size.height / 2), forKey: kCIInputCenterKey)
        }
      case Sliders.radiusSlider:
        if inputKeys.contains(kCIInputRadiusKey) {
          currentFilter?.setValue(radiusSlider.value * 200, forKey: kCIInputRadiusKey)
        }
    }
    createUIImageFromCGImage(ciImage: ciImage)
  }

  private func createUIImageFromCGImage(ciImage: CIImage) {
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
      let processedImage = UIImage(cgImage: cgImage)
      imageView.image = processedImage
    }
  }

  @objc
  private func changeFilter(_ sender: UIButton) {
    guard validatePicture(photo: imageView.image) else { noPictureSelectedAC(); return }
    let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    // iPad support
    if let popoverController = ac.popoverPresentationController {
      popoverController.sourceView = sender
      popoverController.sourceRect = sender.bounds
    }
    present(ac, animated: true, completion: { [weak self] in
      self?.imageView.image = self?.currentPicture
    })
  }

  private func setFilter(action: UIAlertAction) {
    // Make sure there is a valid picture
    guard let currentPicture = self.currentPicture else { noPictureSelectedAC(); return }
    // Read alert action's title
    guard let actionTitle = action.title else { return }
    // Set new title
    currentFilter = CIFilter(name: actionTitle)
    changeFilterBtn.setTitle(currentFilter?.name, for: .normal)

    // Set UIImage to CIImage
    let ciImage = CIImage(image: currentPicture)
    currentFilter?.setValue(ciImage, forKey: kCIInputImageKey) // key to use the input image
//    applyProcessing()
  }

  private func validatePicture(photo: UIImage?) -> Bool {
    guard let picture = photo else { return false }
    return picture != UIImage(systemName: "photo")
  }

  private func validateSlider(sliderAvailableFilters: [String]) -> Bool {
    guard let inputKeys = currentFilter?.inputKeys else { return false }
    let filtersEnabled = sliderAvailableFilters.filter { inputKeys.contains($0) }
    print("Slider \(sliderAvailableFilters.count)")
    print("Available filters: \(sliderAvailableFilters)")
    print("Input keys: \(inputKeys)")
    return !filtersEnabled.isEmpty
  }

  private func noPictureSelectedAC() {
    let ac = UIAlertController(title: "Error", message: "No image selected", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    present(ac, animated: true)
  }

  @objc
  private func saveImage() {
    let picture = imageView.image
    guard validatePicture(photo: picture) else {
      noPictureSelectedAC(); return
    }
    // Save image to photos album
    UIImageWriteToSavedPhotosAlbum(picture!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc
  private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    var alertTitle = "Success"
    var alertMessage = "Edited picture saved to library"
    if let error = error {
      alertTitle = "Error"
      alertMessage = "\(error.localizedDescription)"
    }
    let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
    present(ac, animated: true, completion: nil)
  }
}

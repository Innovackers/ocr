import UIKit
import Foundation
import TesseractOCR

class ViewController: UIViewController {
  
  
    
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // IBAction methods
  @IBAction func backgroundTapped(_ sender: Any) {
    view.endEditing(true)
  }
  
 
  
  @IBAction func takePhoto(_ sender: Any) {
    presentImagePicker()
  }
  
  @IBAction func sharePoem(_ sender: Any) {
  }
  
 
  func performImageRecognition(_ image: UIImage) {
    if let tesseract = G8Tesseract(language: "eng") {
      tesseract.engineMode = .tesseractCubeCombined
      tesseract.pageSegmentationMode = .auto
      tesseract.image = image.g8_blackAndWhite()
      
      tesseract.recognize()
      textView.text = tesseract.recognizedText
    }
    activityIndicator.stopAnimating()
  }
  
  
  func moveViewUp() {
    if topMarginConstraint.constant != 0 {
      return
    }
    topMarginConstraint.constant -= 135
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func moveViewDown() {
    if topMarginConstraint.constant == 0 {
      return
    }
    topMarginConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
}


extension ViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    moveViewUp()
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    moveViewDown()
  }
}

extension ViewController: UINavigationControllerDelegate {
}

extension ViewController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
    
      let imagePickerActionSheet = UIAlertController(title: "Capture",
                                                     message: nil, preferredStyle: .actionSheet)
    
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        let cameraButton = UIAlertAction(title: "Take Photo",
                                         style: .default) { (alert) -> Void in
                                          let imagePicker = UIImagePickerController()
                                          imagePicker.delegate = self
                                          imagePicker.sourceType = .camera
                                          self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(cameraButton)
      }
      let libraryButton = UIAlertAction(title: "Choose Existing",
                                        style: .default) { (alert) -> Void in
                                          let imagePicker = UIImagePickerController()
                                          imagePicker.delegate = self
                                          imagePicker.sourceType = .photoLibrary
                                          self.present(imagePicker, animated: true)
      }
      imagePickerActionSheet.addAction(libraryButton)
      
      let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
      imagePickerActionSheet.addAction(cancelButton)
      
      present(imagePickerActionSheet, animated: true)
    
    }
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
   
    if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
      let scaledImage = selectedPhoto.scaleImage(640) {
    
      activityIndicator.startAnimating()
    
      dismiss(animated: true, completion: {
        self.performImageRecognition(scaledImage)
      })
    }
  }
}

extension UIImage {
  func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    
    if size.width > size.height {
      let scaleFactor = size.height / size.width
      scaledSize.height = scaledSize.width * scaleFactor
    } else {
      let scaleFactor = size.width / size.height
      scaledSize.width = scaledSize.height * scaleFactor
    }
    
    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
}

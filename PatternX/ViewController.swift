//
//  ViewController.swift
//  PatternX
//
//  Created by Smit Patel on 3/15/18.
//  Copyright © 2018 devsmitp. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var ResultLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      detectImage()
        
    }
    
    func detectImage() {
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            fatalError("Failed to load")
        }
        
      
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
       
            DispatchQueue.main.async { [weak self] in
                self?.ResultLbl.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence!"
            }
        }
        
        guard let ciImage = CIImage(image: self.photoView.image!)
            else { fatalError("Cant create Image") }
        

        let handle = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handle.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
  
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
   
    
    
    
    @IBAction func chooseImageFromLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoView.contentMode = .scaleToFill
            photoView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImage()
    }
    
}


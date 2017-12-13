//
//  ViewController.swift
//  WhatFlower
//
//  Created by Chad Rutherford on 12/12/17.
//  Copyright © 2017 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    let wikiURL = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let userPickedImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        guard let ciImage  = CIImage(image: userPickedImage) else { fatalError("Cannot convert to CIImage") }
        detect(image: ciImage)
        imageView.image = userPickedImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Cannot import model.") }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else { fatalError("Could not classify image.") }
            self.navigationItem.title = classification.identifier.capitalized
            self.getFlowerInfo(flowerName: classification.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func getFlowerInfo(flowerName: String) {
        let parameters: [String:String] = [
            "format":"json",
            "action":"query",
            "prop":"extracts",
            "exintro":"",
            "explaintext":"",
            "titles":flowerName,
            "indexpageids":"",
            "redirects":"1"
            
        ]
        
        Alamofire.request(wikiURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let flowerJSON: JSON = JSON(response.result.value!)
                let pageId = flowerJSON["query"]["pageids"][0].stringValue
                let flowerDesc = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                
                self.label.text = flowerDesc
            }
        }
    }
    
    @IBAction func cameraBtnPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}


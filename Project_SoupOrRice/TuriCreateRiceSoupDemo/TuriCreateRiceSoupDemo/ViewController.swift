//
//  ViewController.swift
//  TuriCreateRiceSoupDemo
//
//  Created by Moon on 2018/8/6.
//  Copyright © 2018年 Moon. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var importImageView: UIImageView!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    let mlModel = RiceSoupClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemLabel.text = "分辨湯或飯"
    }
    
    @IBAction func importButtonTapped(_ sender: UIButton) {
     
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func importFromPhotoLibraryButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
}

extension ViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            importImageView.image = image
            
            // buffer size 只能調 224 x 224
            if let buffer = image.buffer(with: CGSize(width: 224, height: 224)),
                let prediction = try? mlModel.prediction(image: buffer),
                let confidence = prediction.foodTypeProbability[prediction.foodType] {
                    let confidenceString = String(format: "%.2f", confidence)
                    itemLabel.text = "type: \(prediction.foodType), 信心:\(confidenceString)"
                }
            }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
    



extension UIImage {
    func buffer(with size:CGSize) -> CVPixelBuffer? {
        if let image = self.cgImage {
            let frameSize = size
            var pixelBuffer:CVPixelBuffer? = nil
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
            if status != kCVReturnSuccess {
                return nil
            }
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
            let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
            context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            return pixelBuffer
        }else{
            return nil
        }
    }
}

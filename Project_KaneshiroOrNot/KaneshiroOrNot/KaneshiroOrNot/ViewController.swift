//
//  ViewController.swift
//  KaneshiroOrNot
//
//  Created by Moon on 2018/8/6.
//  Copyright © 2018年 Moon. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var importImageView: UIImageView!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    let mlModel = kaneshiro()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemLabel.text = "你是不是金城武"
        
    }
    
    func judgeKaneshiro(image: UIImage) {
        importImageView.image = image
        
        // buffer size 只能調 224 x 224
        if let buffer = image.buffer(with: CGSize(width: 224, height: 224)),
            let prediction = try? mlModel.prediction(image: buffer) {
            let kaneshiroOrNot = prediction.kaneshiroOrNot
            guard let confidence = prediction.kaneshiroOrNotProbability[kaneshiroOrNot] else { return }
            let confidenceString = String(format: "%.2f", confidence)
            
            var target: String?
            if kaneshiroOrNot == "Kaneshiro" {
                target = "是金城武"
                itemLabel.textColor = .green
            }
            else
            {
                target = "不是金城武"
                itemLabel.textColor = .red
            }
            
            guard let unwrapTarget = target else { return }
            
            itemLabel.text = "分析結果: 這張照片\(unwrapTarget),信心: \(confidenceString)"
        }
    }
    
    @IBAction func importGalleryTapped(_ sender: UIButton) {
        
        let sampleGalleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SampleGalleryVC")
        
        self.navigationController?.pushViewController(sampleGalleryVC, animated: true)
        
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
    
    @IBAction func importFromLibraryButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
}


extension ViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            judgeKaneshiro(image: image)
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

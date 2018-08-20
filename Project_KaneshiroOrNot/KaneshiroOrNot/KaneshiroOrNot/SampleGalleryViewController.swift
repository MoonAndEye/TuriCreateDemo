//
//  SampleGalleryViewController.swift
//  KaneshiroOrNot
//
//  Created by Moon on 2018/8/20.
//  Copyright © 2018年 Moon. All rights reserved.
//

import UIKit

class SampleGalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let imageNameArray: [String] = ["kaneshiro_1", "kaneshiro_2", "kaneshiro_3", "kaneshiro_4", "kaneshiro_5", "Andy_1", "Jay_1", "Jacky_1", "JackyWu_1", "Koo_1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = UIScreen.main.bounds.width
        
        let cellSize = CGSize(width: screenWidth / 4, height: screenWidth / 4)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.reloadData()
        
    }

}


extension SampleGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let viewControllers = navigationController?.viewControllers, let image = UIImage(named: imageNameArray[indexPath.row]) else { return }
        
        for vc in viewControllers {
            if vc is ViewController {
                let kaneshiroVC = vc as! ViewController   //這是範例,請避免使用 as!
                kaneshiroVC.judgeKaneshiro(image: image)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! SampleCollectionViewCell
        
        cell.avatarImageView.image = UIImage(named: imageNameArray[indexPath.row])
        
        return cell
    }
}

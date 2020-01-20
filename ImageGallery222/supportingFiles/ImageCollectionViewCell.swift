//
//  ImageCollectionViewCell.swift
//  ImageGallery222
//
//  Created by AHMED GAMAL  on 12/17/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var imageView: UIImageView!
    var image : UIImage? {
        get{
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

//

    var url : URL? {
        didSet{
            if url != nil  && (oldValue != url){
                fetchImage(imageUrl: url!)
          }
       }
    }

    weak var errorHandler : ErrorHandlerForImageGallery?
//
    private func fetchImage(imageUrl : URL) {
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            if let dataContents = try? Data(contentsOf: imageUrl){
                DispatchQueue.main.async {
                    if let fetchedImage = UIImage(data: dataContents){

                        self?.imageView?.image = fetchedImage
                    }
                    else{
                       self?.errorHandler?.noImageData(for: self!)
                    }
                 }
              }
            else{
                if self != nil{
                    DispatchQueue.main.async {
                        self?.errorHandler?.noImageData(for: self!)
                        print("errorHandler was summoned")
                   }
               }
           }
        }
   }
    
}
    
  
    
  

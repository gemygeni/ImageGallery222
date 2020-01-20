//
//  imageGalleryTableViewCell.swift
//  ImageGallery222
//
//  Created by AHMED GAMAL  on 12/26/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

class imageGalleryTableViewCell: UITableViewCell , UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!{
        didSet{
            textField.delegate = self
            textField.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            textField.resignFirstResponder()
            textField.isUserInteractionEnabled = false
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubletap(_:)))
            tapRecognizer.numberOfTouchesRequired = 2
            textField.addGestureRecognizer(tapRecognizer)
        }
    }
    
    @objc func doubletap (_ sender : UITapGestureRecognizer){
        
        if sender.state == .ended{
           textField.becomeFirstResponder()
            textField.isUserInteractionEnabled = true
        }
    }

 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     textField.resignFirstResponder()
     textField.isUserInteractionEnabled = false
     return true
 }
    

}

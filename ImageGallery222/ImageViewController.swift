//
//  ImageViewController.swift
//  ImageGallery222
//
//  Created by AHMED GAMAL  on 12/29/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    
    
    var imageView = UIImageView()
    
  weak var fetchedImage : UIImage?
    var image : UIImage?{
        get{
            return imageView.image
        }
        set {
            scrollView?.zoomScale = 1.0
            imageView.image = newValue
            
            let size = newValue?.size ?? CGSize.zero
            imageView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewWidth?.constant = size.width
            scrollViewHeight?.constant = size.height
            //??????????????????why
            let safeZoneBounds = view.bounds.inset(by: view.safeAreaInsets)
            if size.width >= 0 , size.height >= 0 {
            scrollView?.zoomScale = max(safeZoneBounds.width / size.width, safeZoneBounds.height / size.height)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        image = fetchedImage
        navigationItem.rightBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.maximumZoomScale = 5.0
            scrollView.minimumZoomScale = 0.1
            scrollView.addSubview(imageView)
        }
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    

}

//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery222
//
//  Created by AHMED GAMAL  on 12/30/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit
private let reuseIdentifier = "ImageCell"
protocol ErrorHandlerForImageGallery : class {
    func noImageData(for cell : UICollectionViewCell)
}

class ImageGalleryCollectionViewController: UIViewController , DataForImageGallery, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout, ErrorHandlerForImageGallery, UIDropInteractionDelegate
{
 
     weak var imageGallery : ImageGallery! {
      didSet{
          collectionView?.reloadData()
         }
      }
    
    func noImageData(for cell: UICollectionViewCell) {
        if let indexpath  = collectionView.indexPath(for: cell){
            imageGallery.images.remove(at: indexpath.item)
            collectionView.deleteItems(at: [indexpath])
        }
    }
   
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            if let collectionLayOut = collectionView.collectionViewLayout as?   UICollectionViewFlowLayout{
            collectionLayOut.minimumInteritemSpacing = 1
            collectionLayOut.minimumLineSpacing = 1
               }
            collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleCollectionViewCell(with: ))))
         }
    }
 private var scaleForCollectionViewCell : CGFloat = 1.0
    @objc func scaleCollectionViewCell (with recognizer : UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed , .ended:
             scaleForCollectionViewCell *= recognizer.scale
                   collectionView.collectionViewLayout.invalidateLayout()//You can call this method at any time to update the layout information.
                   recognizer.scale = 1.0
        default:
            break
        }
    }
    
    
    @IBOutlet weak var trashButton: UIBarButtonItem!{
        didSet{
            navigationController?.navigationBar.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    var trashButtonView : UIView {
            return (trashButton.value(forKey: "view") as? UIView) ?? UIView()
    }
    
    
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropPoint = session.location(in: trashButtonView)
        let width = trashButtonView.bounds.width
        let height = trashButtonView.bounds.height
        if abs(dropPoint.x) < width/2 && (dropPoint.y) < height{
        return UIDropProposal(operation: .move)
    }
        else{
            return UIDropProposal(operation: .cancel)
        }
    }
    
   private var indexpathsForDragging : [IndexPath] = []
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for indexpath in indexpathsForDragging.sorted().reversed() {
            imageGallery.images.remove(at: indexpath.item)
            collectionView.deleteItems(at: [indexpath])
        }
        indexpathsForDragging = []
    }
    
    override func viewDidLoad() {
           navigationItem.title = "imageGallery \(imageGallery?.name ?? "untiteled")"
           navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
           navigationItem.leftItemsSupplementBackButton = true
       }
  
    // MARK: -Navigation methods
       override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           if  let cell = sender as? ImageCollectionViewCell{
           return cell.image != nil
       }
       return false
       }
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           guard let imageVC = segue.destination.contents as? ImageViewController else{return}
           if let cell = sender as? ImageCollectionViewCell{
               imageVC.fetchedImage = cell.image
           }
       }
    
   // MARK: UICollectionViewDataSource
    func  numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery != nil ?  imageGallery.images.count : 0
       }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }
   
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? ImageCollectionViewCell {
            cell.image = imageGallery.images[indexPath.item].image
            cell.url = imageGallery.images[indexPath.item].url
            cell.errorHandler = self
        }
        return cell
       }
     // You must implement this method to support the reordering of items within the collection view. If you do not implement this method, the collection view ignores any attempts to reorder items
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
           let imageData = imageGallery.images.remove(at: sourceIndexPath.item)
           imageGallery.images.insert(imageData, at: destinationIndexPath.item)
       }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let aspectRatio = imageGallery.images[indexPath.item].aspectRatio
       let cellHeigth: CGFloat = 200 * scaleForCollectionViewCell / aspectRatio
       return CGSize(width: 200 * scaleForCollectionViewCell, height: cellHeigth)
    }
    
    
    
    
    
// MARK: -Drag delegate methods
       func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItem(at : indexPath)
       }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
    session.localContext = collectionView//The optional custom data that you attach to a drag session, visible only to the app in which the drag activity begins
        return dragItem(at : indexPath)
    }
    
    
    func dragItem(at indexpath : IndexPath   ) -> [UIDragItem]{
        if let cell = collectionView.cellForItem(at: indexpath) as? ImageCollectionViewCell, let image = cell.image{
            indexpathsForDragging += [indexpath]
            let dragItemData = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItemData.localObject = image//The localObject property gives you the option to associate a custom object, such as a model object, with the drag item. The local object is available only to the app that initiates the drag activity.
            return [dragItemData]
        }
        return []
    }
    
    // MARK:  Drop delegate methods
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isLocalSession = session.localDragSession != nil //The local drag session is nil if the drag activity started in a different app.
        return (session.canLoadObjects(ofClass: UIImage.self)) && (session.canLoadObjects(ofClass: NSURL.self) || isLocalSession )
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isLocalSession = session.localDragSession != nil //return true if dragitem is local
        
        return UICollectionViewDropProposal(operation: isLocalSession ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
       func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexpath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)
        
        for item in coordinator.items{
            
            
            if let sourseIndexpath = item.sourceIndexPath{//local drop
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [sourseIndexpath])
                collectionView.insertItems(at: [destinationIndexpath])
                let imageData = imageGallery.images[sourseIndexpath.item]
                imageGallery.images.remove(at: sourseIndexpath.item)
                imageGallery.images.insert(imageData, at: destinationIndexpath.item)
                
            })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexpath)
        }
            
            else{//external drop
                let placeholderContext : UICollectionViewDropPlaceholderContext? = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexpath, reuseIdentifier: "DropPlaceHolderCell"))
                // create struct of imageDate to receive data and then append to imageallery's images
                
                var imageDataForCell = ImageGallery.ImageData()
                
                //load image
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler:{
                    (provider , error) in
                    if let image = provider as? UIImage{
                        imageDataForCell.image = image
                        
                                            }
                    else{return}
                } )
                //load url
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: {  [weak self] (provider, error) in
                                    
                                        DispatchQueue.main.async {
                                            if let imageURL = (provider as? URL)?.imageURL {
                                                placeholderContext?.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                                    imageDataForCell.url = imageURL
                                                    self?.imageGallery?.images.insert(imageDataForCell, at: insertionIndexPath.item)
                                                })
                                            
                                        }
                                            else{placeholderContext?.deletePlaceholder()}
                                    }
                                })
                            }
                        }
                    }
                }

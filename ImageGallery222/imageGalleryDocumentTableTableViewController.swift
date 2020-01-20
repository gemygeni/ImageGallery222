//
//  imageGalleryDocumentTableTableViewController.swift
//  ImageGallery222
//
//  Created by AHMED GAMAL  on 12/30/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

//newwwwwwww
class ImageGallery {
    var name: String = ""
    
    struct ImageData{
   
        var url: URL?
        weak var image: UIImage?
        var aspectRatio: CGFloat {
            return image != nil ? (image!.size.width / image!.size.height) : 1
        }
    }
    
    var images: [ImageData] = []
}
    protocol DataForImageGallery : class {
        var imageGallery: ImageGallery! { get  set }
    }






class imageGalleryDocumentTableTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
        let indexpath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexpath, animated: true, scrollPosition: UITableView.ScrollPosition(rawValue: 0)!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    var activeImageGalleries : [ImageGallery] = {
        var ImageGalleries : [ImageGallery] = []
        
        for name in ["1","2", "3"] {
            var imageGallery = ImageGallery()
            imageGallery.name = name
            ImageGalleries.append(imageGallery)
        }
        return ImageGalleries
    }()
    
    var deletedImageGalleries : [ImageGallery] = []
    
    var totalImageGalleries : [[ImageGallery]] {
      return  [activeImageGalleries , deletedImageGalleries]
        }
    
    
    
    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return totalImageGalleries.count
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        totalImageGalleries [section].count
    }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return   section == 1 ?  "recently deleted " : nil
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageGalleryNameCell", for: indexPath)

        if let cell = cell as? imageGalleryTableViewCell{
            cell.textField.text = totalImageGalleries[indexPath.section][indexPath.row].name
        }
        return cell
    }
    
    //Tells the delegate that a specified row is about to be deselected.
       func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
           if let cell = tableView.cellForRow(at: indexPath) as? imageGalleryTableViewCell{
               cell.textField?.resignFirstResponder()
               cell.textField?.isUserInteractionEnabled = false
           }
           return indexPath
       }
   
    // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   

    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0{
                 let imageGallery = totalImageGalleries[indexPath.section][indexPath.row]
                activeImageGalleries.remove(at: indexPath.row)
                deletedImageGalleries.append(imageGallery)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
            }
            else{
                deletedImageGalleries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1 else {return nil}
        
        let restoreAction = UIContextualAction(style: .destructive, title: "Restore" ){
            [weak self]
            (   action : UIContextualAction, view : UIView,  closure : (Bool) -> Void) in
            if let imageGallery = self?.totalImageGalleries[indexPath.section][indexPath.row]{
                self?.deletedImageGalleries.remove(at: indexPath.row)
            self?.activeImageGalleries.insert(imageGallery, at: 0)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
        }
        restoreAction.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        return UISwipeActionsConfiguration(actions: [restoreAction])
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    
    // MARK: - Navigation
    private var indexPathRowForSegue: Int?
       override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
               if indexPath.section == 0 {
                   indexPathRowForSegue = indexPath.row
                   return true
               }
           }
           return false
       }
       
      
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let dataForImageGalleryVC = segue.destination.contents as? ImageGalleryCollectionViewController {
               let index = indexPathRowForSegue ?? 0
               dataForImageGalleryVC.imageGallery = activeImageGalleries[index]
           }
           indexPathRowForSegue = nil
       }
    @IBAction func addGallery(_ sender: UIBarButtonItem) {
        let newImageGallery = ImageGallery()
        let newName = "untiteled".madeUnique(withRespectTo: activeImageGalleries.map{$0.name})
        newImageGallery.name = newName
        activeImageGalleries.append(newImageGallery)
        let indexpath = IndexPath(row: activeImageGalleries.count - 1, section: 0)
        tableView.insertRows(at: [indexpath], with: .automatic)
       // tableView.reloadData()
    }
}

extension imageGalleryDocumentTableTableViewController : UISplitViewControllerDelegate{
    
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
        switch svc.displayMode {
        case .allVisible: return .primaryHidden
        case  . primaryHidden :  return  .allVisible
        default:
          return  .primaryOverlay
        }
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        if let indexpath = tableView.indexPathForSelectedRow ,let cell = tableView.cellForRow(at: indexpath) as? imageGalleryTableViewCell{
            cell.textField?.resignFirstResponder()
            cell.textField?.isUserInteractionEnabled = false
        }
    }

}

extension UIViewController {
    var Contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}
   


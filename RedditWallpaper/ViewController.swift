//
//  ViewController.swift
//  RedditWallpaper
//
//  Created by Douwe Homans on 12/3/15.
//  Copyright © 2015 Douwe Homans. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage

class ImageTableViewCell : UITableViewCell {
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var wallpaperImageView: UIImageView!
    
    var wallpaper: Wallpaper? {
        didSet {
            let newValue = wallpaper
            self.wallpaperImageView?.image = nil
            wallpaper?.loadImage({ (image) -> Void in
                // Only update image if this cell's wallpaper didn't change in the meantime.
                if (self.wallpaper == newValue) {
                    self.wallpaperImageView?.contentMode = .ScaleAspectFill
                    self.wallpaperImageView?.image = image
                }
            })
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource {

    let ImageCellIdentifier = "ImageCellIdentifier"
    var dataStore = [Wallpaper]()
    var refreshControl:UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    func addWallpaper(name: String){
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        // Check if we already have this url
        let urlPredicate = NSPredicate(format: "remoteUrl == %@", argumentArray: [name])
        let fetchRequest = NSFetchRequest(entityName: "Wallpaper")
        fetchRequest.predicate = urlPredicate
        
        //3
        do {
            let preExistingWallpapers =
            try managedContext.executeFetchRequest(fetchRequest)
            if (preExistingWallpapers.count > 0){
                return
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //2
        let entity =  NSEntityDescription.entityForName("Wallpaper",
            inManagedObjectContext:managedContext)
        
        let wallpaper = Wallpaper(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        wallpaper.setValue(name, forKey: "remoteUrl")
        
        //4
        do {
            try managedContext.save()
            //5
            dataStore.append(wallpaper)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(ImageCellIdentifier) as! ImageTableViewCell
        let wallpaper = dataStore[indexPath.item]
        cell.wallpaper = wallpaper
        return cell;
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataStore.count
    }
    
    
    // MARK: - ViewController Lifecycle -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        fetchDataFromReddit()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        reloadDataStore()
    }    
    
    func refresh(sender:AnyObject)
    {
        fetchDataFromReddit {
            self.refreshControl?.endRefreshing()
        }
        reloadDataStore()
    }
    
    func reloadDataStore()
    {
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Wallpaper")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            dataStore = results as! [Wallpaper]
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetchDataFromReddit()
    {
        // Call fetchDataFromReddit with empty callback
        fetchDataFromReddit {}
    }
    
    func fetchDataFromReddit(callback: ()->Void)
    {
        // Create GET fetch request.
        Alamofire.request(.GET, "https://www.reddit.com/r/wallpapers.json", parameters: ["foo": "bar"])
            .responseJSON { response in
                
            // Get all 'data.children' objects (if there is JSON data)
            if let JSON = response.result.value,
                data = JSON.valueForKey("data") as? NSDictionary,
                children = data.valueForKey("children") as? [NSDictionary] {

                // In every 'child' there should be a 'data.preview.images' array
                    let imageArrays = children.map({ (child: NSDictionary) -> [NSDictionary] in
                    if let data = child["data"] as? NSDictionary,
                        preview = data["preview"] as? NSDictionary,
                        images = preview["images"] as? [NSDictionary] {
                            return images
                    } else {
                        return []
                    }
                })
                
                // Flatten imageArrays
                let images = imageArrays.reduce([],combine: {$0 + $1})
                    
                // Extract 'source' objects
                let sources = images.map{ $0["source"] }
                
                // Filter out sources smaller then 1024
                let filteredSources = sources.filter{ $0?["width"] as? Int > 1024 }
                
                // Extract urls
                let urls = filteredSources.map{ $0?["url"] as? String}
                
                // Store wallpaperURL in dataStore
                urls.forEach{
                    if let url = $0 {
                        self.addWallpaper(url)
                    }
                }
                    
                // Call the callback
                callback()
    
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            if let wallpaperVC = segue.destinationViewController as? WallpaperViewController,
                let originatingCell = sender as? ImageTableViewCell {
               wallpaperVC.wallpaper = sender?.wallpaper
            }
        }
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue)
    {
    
    }
}


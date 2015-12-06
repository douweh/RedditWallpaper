//
//  WallpaperViewController.swift
//  RedditWallpaper
//
//  Created by Douwe Homans on 12/4/15.
//  Copyright © 2015 Douwe Homans. All rights reserved.
//

import UIKit
import Alamofire

class WallpaperViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image : UIImage?
    
    var wallpaper: Wallpaper? {
        didSet {
            wallpaper?.loadImage({ (image) -> Void in
                self.image = image
                self.imageView?.image = self.image
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .ScaleAspectFill
        imageView.image = self.image
    }
}

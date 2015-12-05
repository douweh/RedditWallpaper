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

    var imageUrl: String = "" {
        didSet {
            Alamofire.request(.GET, imageUrl)
                .responseImage { response in
                    self.imageView?.contentMode = .ScaleAspectFill
                    self.imageView?.image = response.result.value
                }
        }
    }
}

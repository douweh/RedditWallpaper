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
    
    // MARK: - ViewController Lifecycle -
    override func viewDidLoad()
    {
        print("ViewDidLoad: \(self)")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        print("ViewWillAppear: \(self)")
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("ViewDidAppear: \(self)")
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        print("ViewWillDisappear: \(self)")
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        print("ViewDidDisappear: \(self)")
        super.viewDidDisappear(animated)
    }
    
    deinit
    {
        print("Deinit: \(self)")
    }
}

//
//  Wallpaper.swift
//  
//
//  Created by Douwe Homans on 12/6/15.
//
//

import Foundation
import CoreData
import UIKit
import Alamofire


class Wallpaper: NSManagedObject {

    func loadImage(callback: (image: UIImage) -> Void){
        
        // Check if we have a local path
        if let localPath = path, let localImage = UIImage(contentsOfFile: localPath) {
            print("returning local image")
            callback(image: localImage)
            return
        }
        // else download from server
        else {
            print("trying to fetch from server")
            Alamofire.request(.GET, remoteUrl!)
                .responseImage { response in
                    
                    print("On main thread? \(NSThread.isMainThread())")
        
                    let localImage = response.result.value!
                    
                    // callback with the downloaded image
                    callback(image:localImage)
                    
                    // store file locally
                    let fileManager = NSFileManager();

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        print("Saving: On main thread? \(NSThread.isMainThread())")
                        do {
                            let cacheDir = try fileManager.URLForDirectory(NSSearchPathDirectory.CachesDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
                            let uuid = NSUUID().UUIDString
                            let filename = cacheDir.URLByAppendingPathComponent(uuid)
                            let localImageData = UIImagePNGRepresentation(localImage)
                            let saveCall = try localImageData?.writeToURL(filename, atomically: true)
                            
                            // Let save happen on mainthread
                            dispatch_async(dispatch_get_main_queue(), {
                                do {
                                    if let _ = saveCall {
                                        self.path = filename.path
                                        try self.managedObjectContext?.save()
                                    }
                                } catch {
                                    print(error)
                                }
                            });
                        } catch {
                            print(error)
                        }

                    })
                }
            return
        }

        // else callback with new empty UIImage
        callback(image: UIImage())
    }

}

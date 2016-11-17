//
//  ViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var croppingEnabled: Bool = false
    var libraryEnabled: Bool = true
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openCamera(_ sender: AnyObject) {
        let cameraViewController = CameraViewController(allowsLibraryAccess: libraryEnabled, maxImageSize: 1024.0) { [weak self] image in
          
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
            print("finished")
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func openLibrary(_ sender: AnyObject) {
        let libraryViewController = CameraViewController.imagePickerViewController(maxImageSize: 1024.0) { image in
         
            self.imageView.image = image
            self.dismiss(animated: true, completion: nil)
            print("finished")
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func libraryChanged(_ sender: AnyObject) {
        libraryEnabled = !libraryEnabled
    }
    
    @IBAction func croppingChanged(_ sender: AnyObject) {
        croppingEnabled = !croppingEnabled
    }
}


//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public class ConfirmViewController: UIViewController {
    
    let imageView = UIImageView()
    
    let paintView = ImagePaintView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    let cancelButton = UIButton(type: .custom)
    let confirmButton = UIButton(type: .custom)
    
   
   
    
    let redButton = UIButton(type: .custom)
    let greenButton = UIButton(type: .custom)
    let blueButton = UIButton(type: .custom)

    var maxImageSize: CGFloat = 1024.0
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    public var onComplete: CameraViewCompletion?
    
    var asset: PHAsset!
    
    var image: UIImage!
    
    var chosenImage: UIImage!
    
    public init(asset: PHAsset, maxImageSize:CGFloat) {

        self.maxImageSize = maxImageSize
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }

    public init(image: UIImage, maxImageSize:CGFloat) {
        
        
        self.maxImageSize = maxImageSize
        
        super.init(nibName: nil, bundle: nil)
        
        self.image = self.scaleImageToMaxSize(image: image, maxSize: self.maxImageSize)
        
        
    }

    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    deinit {
        print("confirm deinit")
        
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        
       self.view.addSubview(imageView)
        
        self.view.addSubview(paintView)
        
        paintView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        imageView.contentMode = .scaleAspectFit
        
        confirmButton.setImage(UIImage(named: "confirmButton",
                                              in: CameraGlobals.shared.bundle,
                                              compatibleWith: nil),
                                      for: .normal)
        
        cancelButton.setImage(UIImage(named: "retakeButton",
                                       in: CameraGlobals.shared.bundle,
                                       compatibleWith: nil),
                               for: .normal)
        

        
        
        
        
        redButton.setTitleColor(.red, for: .normal)
        redButton.setTitle("◉", for: .normal)
        redButton.titleLabel?.font = UIFont(name: (redButton.titleLabel?.font.fontName)!, size: 30)
        redButton.tintColor = .red
        
        
        greenButton.setTitleColor(.green, for: .normal)
        greenButton.setTitle("●", for: .normal)
        greenButton.titleLabel?.font = UIFont(name: (redButton.titleLabel?.font.fontName)!, size: 30)
        greenButton.tintColor = .green
        
        
        blueButton.setTitleColor(.blue, for: .normal)
        blueButton.setTitle("●", for: .normal)
        blueButton.titleLabel?.font = UIFont(name: (redButton.titleLabel?.font.fontName)!, size: 30)
        blueButton.tintColor = .blue
        
        
        
        
        
        self.view.addSubview(confirmButton)
        self.view.addSubview(cancelButton)


        self.view.addSubview(redButton)
        self.view.addSubview(greenButton)
        self.view.addSubview(blueButton)
        
       
        
        guard let asset = asset else {
            
            
            if self.image != nil {
            
                self.configureWithImage(self.image)
                self.enable()
            }
            
            
            return
        }
        
        let spinner = showSpinner()
        
        disable()

        _ = SingleImageFetcher()
            .setAsset(asset)
            .setTargetSize(largestPhotoSize())
            .onSuccess { image in
                self.configureWithImage(self.scaleImageToMaxSize(image: image, maxSize: self.maxImageSize))
                self.hideSpinner(spinner)
                self.enable()
            }
            .onFailure { error in
                self.hideSpinner(spinner)
            }
            .fetch()
    }
    

    
    private func redButtonPressed() {
        
        // set color in paintview
        
        paintView.color = .red
        
        redButton.setTitle("◉", for: .normal) // active
        greenButton.setTitle("●", for: .normal)
        blueButton.setTitle("●", for: .normal)
        
    }
    
    private func blueButtonPressed() {
        
        // set color in paintview
        
        paintView.color = .blue
        
        redButton.setTitle("●", for: .normal)
        greenButton.setTitle("●", for: .normal)
        blueButton.setTitle("◉", for: .normal) // active
    }
    
    private func greenButtonPressed() {
        
        // set color in paintview
        
        paintView.color = .green
        
        redButton.setTitle("●", for: .normal)
        greenButton.setTitle("◉", for: .normal) // active
        blueButton.setTitle("●", for: .normal)
    }
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        
        let buttonWidth: CGFloat = 80.0
        
        
        
        
        //
        
        
       
        let toolWidth: CGFloat = (self.view.bounds.size.width-buttonWidth-buttonWidth)/CGFloat(3.0)
        let toolsY = self.view.bounds.size.height-buttonWidth

        cancelButton.frame = CGRect(x: 0, y: toolsY, width: buttonWidth, height: buttonWidth)
        redButton.frame = CGRect(x: CGFloat(0) * toolWidth+buttonWidth, y: toolsY, width: toolWidth, height: buttonWidth)
        greenButton.frame = CGRect(x: CGFloat(1) * toolWidth+buttonWidth, y: toolsY, width: toolWidth, height: buttonWidth)
        blueButton.frame = CGRect(x: CGFloat(2) * toolWidth+buttonWidth, y: toolsY, width: toolWidth, height: buttonWidth)
        confirmButton.frame = CGRect(x: self.view.bounds.size.width-CGFloat(buttonWidth), y: toolsY, width: buttonWidth, height: buttonWidth)
        
        imageView.backgroundColor = .black
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height-buttonWidth))
        
        if(imageView.image != nil) {
            
            let imageSize = imageView.image!.size
            
            let scaledWidth = CGFloat(imageView.bounds.size.width)/CGFloat(imageSize.width)
            let scaledHeight = CGFloat(imageView.bounds.size.height)/CGFloat(imageSize.height)
            
            let imageScale = fminf(Float(scaledWidth), Float(scaledHeight))
            
            
            let scaledImageSize = CGSize(width: imageSize.width*CGFloat(imageScale), height: imageSize.height*CGFloat(imageScale))
            
            let imageFrameX = CGFloat(roundf(Float(0.5)*Float(imageView.bounds.size.width-scaledImageSize.width)))
            let imageFrameY = CGFloat(roundf(Float(0.5)*Float(imageView.bounds.size.height-scaledImageSize.height)))
            
            let imageFrame = CGRect(x:imageFrameX , y: imageFrameY, width: CGFloat(roundf(Float(scaledImageSize.width))), height: CGFloat(roundf(Float(scaledImageSize.height))))
            
            paintView.frame = imageFrame
            
        }
            
        
        
        
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
       
        var frame = view.bounds
        
        
        frame.size = size
       
        coordinator.animate(alongsideTransition: { context in

            }, completion: nil)
    }
    
    func scaleImageToMaxSize(image: UIImage, maxSize: CGFloat) -> UIImage {
        
   
        
        var scaledImageRect = CGRect.zero
        
        
   
            let ratio: CGFloat = image.size.width/image.size.height;
            if (ratio > 1.0) {
                scaledImageRect.size.width = maxSize;
                scaledImageRect.size.height = CGFloat(roundf(Float(scaledImageRect.size.width / ratio)));
            }
            else {
                scaledImageRect.size.height = maxSize;
                scaledImageRect.size.width = CGFloat(roundf(Float(scaledImageRect.size.height * ratio)));
            }
        

        let newSize: CGSize = scaledImageRect.size
        
        let aspectWidth = newSize.width/image.size.width
        let aspectheight = newSize.height/image.size.height
        
        let aspectRatio = min(aspectWidth, aspectheight)
        
        scaledImageRect.size.width = image.size.width * aspectRatio;
        scaledImageRect.size.height = image.size.height * aspectRatio;
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    private func configureWithImage(_ image: UIImage) {

        self.image = image
        buttonActions()
        imageView.image = image
        imageView.sizeToFit()
        view.setNeedsLayout()
    }
    
    private func calculateMinimumScale(_ size: CGSize) -> CGFloat {
        let _size = size
        
    
        guard let image = imageView.image else {
            return 1
        }
        
        let scaleWidth = _size.width / image.size.width
        let scaleHeight = _size.height / image.size.height
        
        var scale: CGFloat
        

        scale = min(scaleWidth, scaleHeight)
    
        
        return scale
    }
    


    
    private func buttonActions() {
        confirmButton.action = { [weak self] in self?.confirmPhoto() }
        cancelButton.action = { [weak self] in self?.cancel() }
        
        redButton.action = { [weak self] in self?.redButtonPressed() }
        greenButton.action = { [weak self] in self?.greenButtonPressed() }
        blueButton.action = { [weak self] in self?.blueButtonPressed() }
    }
    
    internal func cancel() {
        
        if(paintView.hasPainting) {
            
            paintView.clearDrawing()
            //redButtonPressed()
            
        }else {
            onComplete?(nil)
        }
            
        
        
    }
    
    internal func processImages() {
        
        chosenImage = self.image
        
        let secondImage = paintView.paintedImage()
        
        if(secondImage != nil) {
            
            print("has painting")
            
            let newImageSize = CGSize(width: chosenImage.size.width, height: chosenImage.size.height)
            
            UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
            
            chosenImage.draw(in: CGRect(x: 0, y: 0, width: newImageSize.width, height: newImageSize.height))
            secondImage!.draw(in: CGRect(x: 0, y: 0, width: newImageSize.width, height: newImageSize.height))
            
            chosenImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        
        
    }
    
    internal func confirmPhoto() {
        
        disable()
        
       
        
        //imageView.isHidden = true
        paintView.isUserInteractionEnabled = false
        
        let spinner = showSpinner()

       
//            self.processImages()
//self.onComplete?(self.chosenImage)
//        self.hideSpinner(spinner)
        
            DispatchQueue.global(qos: .background).async { [weak self]
                () -> Void in
 
                print("processing images")
                
                    self?.processImages()
                print("image size \(self?.chosenImage.size)")
                            DispatchQueue.main.async {
                                () -> Void in
                                self?.hideSpinner(spinner)
                                print("done processing")
                                self?.onComplete?(self?.chosenImage)
                                
                                
                                
                            }

                
            }
        

            
            
            
        
            
        
        
    }
    

    
    func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.center = self.view.center//CGPoint(x: self.view.bounds.size.width/CGFloat(2.0), y: 40)
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubview(toFront: spinner)
        
        return spinner
    }
    
    func hideSpinner(_ spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func disable() {
        confirmButton.isEnabled = false
        
        redButton.isEnabled = false
        greenButton.isEnabled = false
        blueButton.isEnabled = false
        paintView.isUserInteractionEnabled = false
    }
    
    func enable() {
        confirmButton.isEnabled = true
        
        redButton.isEnabled = true
        greenButton.isEnabled = true
        blueButton.isEnabled = true
        paintView.isUserInteractionEnabled = true
    }
    
    func showNoImageScreen(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let desc = localizedString("error.cant-fetch-photo.description")
        
        permissionsView.configureInView(view, title: error.localizedDescription, descriptiom: desc, completion: cancel)
    }
    
}

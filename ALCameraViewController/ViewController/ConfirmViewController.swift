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
    
    let clearButton = UIButton(type: .custom)
    let earseButton = UIButton(type: .custom)
    
    let redButton = UIButton(type: .custom)
    let greenButton = UIButton(type: .custom)
    let blueButton = UIButton(type: .custom)

    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    public var onComplete: CameraViewCompletion?
    
    var asset: PHAsset!
    
    var chosenImage: UIImage!
    
    public init(asset: PHAsset) {

        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        
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
        
        clearButton.tintColor = .white
        clearButton.setImage(UIImage(named: "clearButton",
                                                  in: CameraGlobals.shared.bundle,
                                                  compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
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

        self.view.addSubview(clearButton)
        self.view.addSubview(redButton)
        self.view.addSubview(greenButton)
        self.view.addSubview(blueButton)
        
       
        
        guard let asset = asset else {
            return
        }
        
        let spinner = showSpinner()
        
        disable()

        _ = SingleImageFetcher()
            .setAsset(asset)
            .setTargetSize(largestPhotoSize())
            .onSuccess { image in
                self.configureWithImage(image)
                self.hideSpinner(spinner)
                self.enable()
            }
            .onFailure { error in
                self.hideSpinner(spinner)
            }
            .fetch()
    }
    
    private func clearButtonPressed() {
        
        // clear drawing in paintview
        
        paintView.clearDrawing()
        
        redButtonPressed()
        
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
        
        cancelButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        confirmButton.frame = CGRect(x: self.view.bounds.size.width-CGFloat(buttonWidth), y: 0, width: buttonWidth, height: buttonWidth)
        
        //
        
        
        let bottomToolsHeight: CGFloat = 50
        let toolWidth: CGFloat = self.view.bounds.size.width/CGFloat(5.0)
        let toolsY = self.view.bounds.size.height-bottomToolsHeight

        clearButton.frame = CGRect(x: CGFloat(0) * toolWidth, y: toolsY, width: toolWidth, height: bottomToolsHeight)
        redButton.frame = CGRect(x: CGFloat(1) * toolWidth, y: toolsY, width: toolWidth, height: bottomToolsHeight)
        greenButton.frame = CGRect(x: CGFloat(2) * toolWidth, y: toolsY, width: toolWidth, height: bottomToolsHeight)
        blueButton.frame = CGRect(x: CGFloat(3) * toolWidth, y: toolsY, width: toolWidth, height: bottomToolsHeight)
        
        
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: buttonWidth), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height-buttonWidth-bottomToolsHeight))
        
        if(imageView.image != nil) {
            
            let imageSize = imageView.image!.size
            
            let scaledWidth = CGFloat(imageView.bounds.size.width)/CGFloat(imageSize.width)
            let scaledHeight = CGFloat(imageView.bounds.size.height)/CGFloat(imageSize.height)
            
            let imageScale = fminf(Float(scaledWidth), Float(scaledHeight))
            
            
            let scaledImageSize = CGSize(width: imageSize.width*CGFloat(imageScale), height: imageSize.height*CGFloat(imageScale))
            
            let imageFrameX = CGFloat(roundf(Float(0.5)*Float(imageView.bounds.size.width-scaledImageSize.width)))
            let imageFrameY = CGFloat(roundf(Float(0.5)*Float(imageView.bounds.size.height-scaledImageSize.height))+Float(80))
            
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
    
    private func configureWithImage(_ image: UIImage) {
  
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
        clearButton.action = { [weak self] in self?.clearButtonPressed() }
        redButton.action = { [weak self] in self?.redButtonPressed() }
        greenButton.action = { [weak self] in self?.greenButtonPressed() }
        blueButton.action = { [weak self] in self?.blueButtonPressed() }
    }
    
    internal func cancel() {
        onComplete?(nil, nil)
    }
    
    internal func processImages() {
        
        let firstImage = imageView.image!
        let secondImage = paintView.paintedImage()!
        
        let newImageSize = CGSize(width: firstImage.size.width, height: firstImage.size.height)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        firstImage.draw(in: CGRect(x: 0, y: 0, width: newImageSize.width, height: newImageSize.height))
        secondImage.draw(in: CGRect(x: 0, y: 0, width: newImageSize.width, height: newImageSize.height))
        
        chosenImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    internal func confirmPhoto() {
        
        disable()
        
        imageView.isHidden = true
        paintView.isHidden = true
        
        let spinner = showSpinner()

        if(paintView.hasPainting) {
        }else {
            
        }
            
        
        var fetcher = SingleImageFetcher()
            .onSuccess { image in
                self.onComplete?(image, self.asset)
                self.hideSpinner(spinner)
                self.enable()
           }
            .onFailure { error in            
                self.hideSpinner(spinner)
                self.showNoImageScreen(error)
            }
            .setAsset(asset)
        

        
        fetcher = fetcher.fetch()
    }
    

    
    func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .white
        spinner.center = view.center
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
        clearButton.isEnabled = false
        redButton.isEnabled = false
        greenButton.isEnabled = false
        blueButton.isEnabled = false
    }
    
    func enable() {
        confirmButton.isEnabled = true
        clearButton.isEnabled = true
        redButton.isEnabled = true
        greenButton.isEnabled = true
        blueButton.isEnabled = true
    }
    
    func showNoImageScreen(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let desc = localizedString("error.cant-fetch-photo.description")
        
        permissionsView.configureInView(view, title: error.localizedDescription, descriptiom: desc, completion: cancel)
    }
    
}

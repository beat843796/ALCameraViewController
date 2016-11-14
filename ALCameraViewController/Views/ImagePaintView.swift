//
//  ImagePaintView.swift
//  ALCameraViewController
//
//  Created by Clemens Hammerl on 09.11.16.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit

class ImagePaintView: UIView{

    public var erasing : Bool = false
    public var color : UIColor
    public var hasPainting: Bool = false
    
    private let strokeSize: CGFloat = 10.0
    
    private var cacheContext: CGContext?
    
    private var point0: CGPoint = CGPoint(x: -1, y: -1)
    private var point1: CGPoint = CGPoint(x: -1, y: -1)
    private var point2: CGPoint = CGPoint(x: -1, y: -1)
    private var point3: CGPoint = CGPoint(x: -1, y: -1)
    
    
    override init(frame: CGRect) {
        
        self.color = UIColor.red
        self.erasing = false
        
        self.hasPainting = false
        
        
        super.init(frame: frame)
        
        isOpaque = false
        alpha = 1.0
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func paintedImage() -> UIImage? {
        
        //var context = UIGraphicsGetCurrentContext();
        let cacheImage =  cacheContext?.makeImage()
        let image = UIImage.init(cgImage: cacheImage!, scale: 1.0, orientation: UIImageOrientation.downMirrored)
        
        return image;
        
        
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let bytesPerRow = bounds.size.width*CGFloat(4)
        
        cacheContext = CGContext.init(data: nil, width: Int(bounds.size.width), height: Int(bounds.size.height), bitsPerComponent: 8, bytesPerRow: Int(bytesPerRow), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)!
        
    }
    
    public func clearDrawing() {
        
        cacheContext?.clear(self.bounds)
        self.setNeedsDisplay(self.bounds)
        
        hasPainting = false
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        let cacheImage = cacheContext?.makeImage()
        
        context?.draw(cacheImage!, in: self.bounds)
        
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        point0 = CGPoint(x: -1, y: -1)
        point1 = CGPoint(x: -1, y: -1)
        point2 = CGPoint(x: -1, y: -1)
        point3 = touch!.location(in: self)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touches moved")
        
        let touch = touches.first
        
        point0 = point1
        point1 = point2
        point2 = point3
        point3 = touch!.location(in: self)
        
        drawToCache()
        
        
    }
    
    private func drawToCache() {

        
        
        if !erasing {
            
            // DRAW
            
            if(point1.x > -1) {
            
            cacheContext?.setStrokeColor(color.cgColor)
            cacheContext?.setLineCap(.round)
            cacheContext?.setLineWidth(strokeSize)
            
            let x0 = (point0.x > CGFloat(-1)) ? point0.x : point1.x
            let y0 = (point0.y > CGFloat(-1)) ? point0.y : point1.y
            
            let x1 = point1.x
            let y1 = point1.y
            
            let x2 = point2.x
            let y2 = point2.y
            
            let x3 = point3.x
            let y3 = point3.y
            
            let xc1 = (x0 + x1) / 2.0
            let yc1 = (y0 + y1) / 2.0
            let xc2 = (x1 + x2) / 2.0
            let yc2 = (y1 + y2) / 2.0
            let xc3 = (x2 + x3) / 2.0
            let yc3 = (y2 + y3) / 2.0
            
            let len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0))
            let len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1))
            let len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2))
            
            let k1 = len1 / (len1 + len2)
            let k2 = len2 / (len2 + len3)
            
            let xm1 = xc1 + (xc2 - xc1) * k1
            let ym1 = yc1 + (yc2 - yc1) * k1
            
            let xm2 = xc2 + (xc3 - xc2) * k2
            let ym2 = yc2 + (yc3 - yc2) * k2
            
            let smoothValue : CGFloat = 0.9
            
            let ctrl1x = xm1 + (xc2 - xm1) * smoothValue + x1 - xm1
            let ctrl1y = ym1 + (yc2 - ym1) * smoothValue + y1 - ym1
            
            let ctrl2x = xm2 + (xc2 - xm2) * smoothValue + x2 - xm2
            let ctrl2y = ym2 + (yc2 - ym2) * smoothValue + y2 - ym2
            
            
            cacheContext?.move(to: point1)
            cacheContext?.addCurve(to: point2, control1: CGPoint(x:ctrl2x,y:ctrl2y), control2: CGPoint(x:ctrl1x,y:ctrl1y))
            cacheContext?.strokePath()
            
            let dirtyPoint1 = CGRect(origin: CGPoint(x:point1.x-CGFloat(15), y:point1.y-CGFloat(15)), size: CGSize(width: 30, height: 30))
            let dirtyPoint2 = CGRect(origin: CGPoint(x:point2.x-CGFloat(15), y:point2.y-CGFloat(15)), size: CGSize(width: 30, height: 30))
            self.setNeedsDisplay(dirtyPoint1.union(dirtyPoint2))
            
            }
            
        }else {
            
            // ERASE
            
            cacheContext?.clear(CGRect(x: point3.x-CGFloat(35), y: point3.y-CGFloat(35), width: 70, height: 70))
            self.setNeedsDisplay(CGRect(x: point3.x-CGFloat(35), y: point3.y-CGFloat(35), width: 70, height: 70))
            
            
        }
        
        hasPainting = true
        
    }
    
    

    
}

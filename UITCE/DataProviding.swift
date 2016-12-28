//
//  DataProviding.swift
//  UITCE
//
//  Created by Lee Hoa on 12/20/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import Foundation
import UIKit

class DataProviding {
    
    struct PixelData {
        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = CGFloat(image.size.height) * scale
        UIGraphicsBeginImageContext(CGSize(newWidth, newHeight))
        image.draw(in: CGRect(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return (pixelValues, width, height)
    }
    
    
    static func intensityValuesFromImage2(image: UIImage?, value: UInt8) -> (data: [UInt8]?, pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        var pixelValues1: [UInt8]?
        if (image != nil) {
            let imageRef = image!.cgImage
            width = imageRef!.width
            height = imageRef!.height
            
            let bytesPerPixel = 1
            
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let totalBytes = width * height * bytesPerPixel
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            pixelValues = [UInt8](repeating: 0, count: totalBytes)
            
            pixelValues1 = [UInt8](repeating: 0, count: (width * height)/8)
            
            let contextRef = CGContext(data: &pixelValues!, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef!, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
//            CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), imageRef)
        }
        
        for i in 0..<Int((pixelValues?.count)!) {
            
            let byteIndex = i >> 3; // devide by 8
            let bitShift = i & 7;   // i modulo 8
            
            if pixelValues![i] < value {
                                pixelValues![i] = 0
                let mask: UInt8 = (0x01 << UInt8(bitShift))
                pixelValues1![byteIndex] = pixelValues1![byteIndex] | mask
            } else {
                                pixelValues![i] = 1
                
                let mask: UInt8 = (~(0x01 << UInt8(bitShift)))// (0xFE << bitShift);
                pixelValues1![byteIndex] = (pixelValues1![byteIndex] & mask)
            }
        }
        
        return (pixelValues1, pixelValues, width, height)
    }
    
    static func imageFromARGB32Bitmap(pixels:[PixelData], width: Int, height: Int)-> UIImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        assert(pixels.count == width * height)
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProvider(
            data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
        )
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * Int(MemoryLayout<PixelData>.size),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        return UIImage(cgImage: cgim!)
    }
    
    static func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        assert(width > 0)
        
        assert(height > 0)
        
        let pixelDataSize = MemoryLayout<PixelData>.size
        assert(pixelDataSize == 4)
        
        assert(pixels.count == Int(width * height))
        
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
    
    static func takeSnapshotOfView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(view.frame.size.width, view.frame.size.height))
        view.drawHierarchy(in: CGRect(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func blackAndWhiteImage(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: image)!
        
        // Set image color to b/w
        let bwFilter = CIFilter(name: "CIColorControls")!
        bwFilter.setValuesForKeys([kCIInputImageKey:ciImage, kCIInputBrightnessKey:NSNumber(value: 0.0), kCIInputContrastKey:NSNumber(value: 1.1), kCIInputSaturationKey:NSNumber(value: 0.0)])
        let bwFilterOutput = (bwFilter.outputImage)!
        
        // Adjust exposure
        let exposureFilter = CIFilter(name: "CIExposureAdjust")!
        exposureFilter.setValuesForKeys([kCIInputImageKey:bwFilterOutput, kCIInputEVKey:NSNumber(value: 0.7)])
        let exposureFilterOutput = (exposureFilter.outputImage)!
        
        // Create UIImage from context
        let bwCGIImage = context.createCGImage(exposureFilterOutput, from: ciImage.extent)
        let resultImage = UIImage(cgImage: bwCGIImage!, scale: 1.0, orientation: image.imageOrientation)
        
        return resultImage
    }
    
    static func SendSuccess(viewController: UIViewController) {
        let refreshAlert = UIAlertController(title: "Congatulate", message: "Sent success!", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        viewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    
    static func SendFail(viewController: UIViewController) {
        let refreshAlert = UIAlertController(title: "Failed", message: "Sorry, Please connect to Server and try again!", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        viewController.present(refreshAlert, animated: true, completion: nil)
    }
    
    /*Have before send socket*/
    static let start : [UInt8] = [0x40, 0x00]
    static let chksm: [UInt8] = [0x00, 0x00]
    static let begin: [UInt8] = [0x42, 0x00]
    static let size : [UInt8] = [0x00, sizeBytes] //8 byte
    
    static func sendData(foo : [UInt8]) -> Bool {
        var isSuccess: Bool = false
        socketTCP?.send(data: start)
        socketTCP?.send(data: chksm)
        socketTCP?.send(data: begin)
        socketTCP?.send(data: size)
        // usleep(1) // co
        if socketTCP?.send(data: foo).0 == true {
            isSuccess = true
        }
        socketTCP?.send(data: chksm)
        return isSuccess
    }
    
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage!
    }
}

//
//  ClockViewController.swift
//  UITCE
//
//  Created by Lee Hoa on 12/21/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import BEMAnalogClock

class ClockViewController: UIViewController {

    @IBOutlet weak var myClock: BEMAnalogClockView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var status: UIButton!
   
    var rHours: String = ""
    var rMinutes: String = ""
    var rSeconds: String = ""
   
    var choiceStatus: Bool = true
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myClock.realTime = true
        self.myClock.currentTime = true
        self.myClock.setClockToCurrentTime(animated: true)
        // Do any additional setup after loading the view.
        self.myClock.delegate = self
        self.myClock.startRealTime()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.myClock.stopRealTime()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateTimer() {
        
        if self.isViewLoaded && (self.view.window != nil) {
            // viewController is visible
            pixels = []
            var image1 = UIImage()
            
            if choiceStatus == true {
                image1 = DataProviding.takeSnapshotOfView(view: myClock)
            } else {
                image1 = DataProviding.takeSnapshotOfView(view: timeLabel)
            }
            
            let image2 = DataProviding.resizeImage(image: image1,newWidth: CGFloat(valueVanNumber))
            
            let result = DataProviding.intensityValuesFromImage2(image: image2,value: UInt8(valueThreshold))
            for i in 0..<Int((result.pixelValues?.count)!) {
                if result.pixelValues![i] == 1 {
                    pixels.append(white)
                } else {
                    pixels.append(black)
                }
            }
//            let newString = (result.pixelValues?.description)!
//            let data = newString.stringByReplacingOccurrencesOfString(", ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            let data2 = data.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//            let data3 = data2.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            //            DataProviding.sendMessage(data)
            
//            for k in 0..<data3.characters.count/self.vanNumber {
//                socketTCP?.send(str: data3[k*self.vanNumber...k*self.vanNumber+self.vanNumber-1] + "\n")
//            }
            
            timeImage.image = DataProviding.imageFromARGB32Bitmap(pixels: pixels, width: valueVanNumber, height: result.height)
        }
    }

    @IBAction func status(_ sender: Any) {
    }
 
    @IBAction func send(_ sender: Any) {
        updateTimer()
    }

}

extension ClockViewController: BEMAnalogClockDelegate {
    @objc(currentTimeOnClock:Hours:Minutes:Seconds:)
    func currentTime(onClock clock: BEMAnalogClockView!, hours: String!, minutes: String!, seconds: String!) {
        if Int(hours)! <= 9 {
            rHours = "0" + hours
        } else {
            rHours = hours
        }
        if Int(minutes)! <= 9 {
            rMinutes = "0" + minutes
        } else {
            rMinutes = minutes
        }
        if Int(seconds)! <= 9 {
            rSeconds = "0" + seconds
        } else {
            rSeconds = seconds
        }
        self.timeLabel.text = rHours+":"+rMinutes+":"+rSeconds
    }
}

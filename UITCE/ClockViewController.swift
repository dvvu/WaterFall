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
    @IBOutlet weak var signal: UIButton!
   
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
        self.myClock.delegate = self
        self.myClock.startRealTime()
        if isConnected == true {
            signal.setImage(UIImage(named: "on"), for: .normal)
        } else {
            signal.setImage(UIImage(named: "off"), for: .normal)
        }
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
            timeImage.image = DataProviding.imageFromARGB32Bitmap(pixels: pixels, width: valueVanNumber, height: result.height)
            
            let height = (result.data!.count)/(valueVanNumber/8)     
            if isConnected == true {
                for j in 0..<height {
                    var dataArray: [UInt8] = []
                    dataArray = [UInt8](repeating: 0, count: (valueVanNumber/8))
                    for i in 0..<(valueVanNumber/8) {
                        dataArray[i] = result.data![i + (height - 1 - j)*(valueVanNumber/8)]
                    }
                    
                    if DataProviding.sendData(foo: dataArray) == true {
                        DataProviding.SendSuccess(viewController: self)
                        signal.setImage(UIImage(named: "on"), for: .normal)
                        isConnected = true
                    } else {
                        DataProviding.SendFail(viewController: self)
                        signal.setImage(UIImage(named: "off"), for: .normal)
                        isConnected = false
                    }
                    let delay = valueRowDelay*1000
                    usleep(useconds_t(delay))
                    
                }
                DataProviding.SendSuccess(viewController: self)
            } else {
                DataProviding.SendFail(viewController: self)
            }
            
        }
    }

    @IBAction func status(_ sender: Any) {
        if choiceStatus == true {
            choiceStatus = false
            status.setTitle("DIGITAL", for: .normal)
        } else {
            choiceStatus = true
             status.setTitle("ANALOG", for: .normal)
        }
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

//
//  ViewController.swift
//  UITCE
//
//  Created by Lee Hoa on 12/19/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

var valueVanNumber: Int = 192
var valueThreshold: Int = 127
var valueRowDelay: Int = 100
var isConnected: Bool = false
var sizeBytes: UInt8 = 0x08
class ViewController: UIViewController {
    
    var imagesDirectoryPath:String!
    override func viewDidLoad() {
        super.viewDidLoad()
//        SD.deleteTable(table: "ImageData")
        createTable()
    }
    
//    func conditionSQLite() {
//        /*Condition to have path*/
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        // Get the Document directory path
//        let documentDirectorPath:String = paths[0]
//        // Create a new path for the new images folder
//        imagesDirectoryPath = documentDirectorPath.stringByAppendingPathExtension(ext: "/ImagePicker")
//        //documentDirectorPath.stringByAppendingString("/ImagePicker")
//        
//        var objcBool:ObjCBool = true
//        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
//        // If the folder with the given path doesn't exist already, create it
//        if isExist == false{
//            do{
//                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
//            }catch{
//                print("Something went wrong while creating a new folder")
//            }
//        }
//    }
    
    func createTable() {
        /*Table image*/
        if let _ = SD.createTable(table: "ImageData", withColumnNamesAndTypes: ["Path": .StringVal]) {
            print("Error: Do it again!")
        }
        /*Table setting*/
        if let _ = SD.createTable(table: "Setting", withColumnNamesAndTypes: ["Van": .IntVal, "DRow": .IntVal, "DImage": .IntVal, "Value": .IntVal, "IP": .StringVal, "Port": .IntVal]) {
            getSetting()
            print("Error: Do it again!")
        } else {
            if let _ = SD.executeChange(sqlStr: "INSERT INTO Setting (Van, DRow, DImage, Value, IP, Port) VALUES (?, ?, ?, ?, ?, ?)", withArgs: [192 as AnyObject,500 as AnyObject,1000 as AnyObject,127 as AnyObject,"192.168.1.1" as AnyObject,90 as AnyObject]) {
            }
        }
        
        if let _ = SD.createTable(table: "ListImageData", withColumnNamesAndTypes: ["Path": .StringVal]) {
            print("Error: Do it again!")
        }
    }
    
    func getSetting() {
        let (resultSet, err) = SD.executeQuery(sqlStr: "SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            valueVanNumber = (resultSet[0]["Van"]?.asInt())!
            valueThreshold = (resultSet[0]["Value"]?.asInt())!
            valueRowDelay = (resultSet[0]["DRow"]?.asInt())!
            
            switch valueVanNumber {
            case 192:
                sizeBytes = 0x18
            case 128:
                sizeBytes = 0x10
            case 96:
                sizeBytes = 0x0C
            case 64:
                sizeBytes = 0x08
            case 32:
                sizeBytes = 0x04
            default:
                sizeBytes = 0x08
            }
            
//            vans.text = resultSet[0]["Van"]?.asInt()?.description
//            rDelay.text = resultSet[0]["DRow"]?.asInt()?.description
//            iDelay.text = resultSet[0]["DImage"]?.asInt()?.description
//            threshold.text = resultSet[0]["Value"]?.asInt()?.description
//            ip.text = resultSet[0]["IP"]?.asString()
//            port.text = resultSet[0]["Port"]?.asInt()?.description
        }
    }

    func InssertData() {
         SD.executeQuery(sqlStr: "UPDATE Setting SET Van = '\(192)',DRow = '\(200)', DImage = '\(300)', Value = '\(120)', IP = '\("192.168.0.0")', Port = '\(9922)'")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


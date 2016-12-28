//
//  DisplayTextViewController.swift
//  UITCE
//
//  Created by Lee Hoa on 12/21/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class DisplayTextViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var enterText: UITextField!
    @IBOutlet weak var labelImage: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var font: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var signal: UIButton!
   
    var imagesDirectoryPath:String!
    var pickerDataSize:[Int] = []
    var pickerDataFont:[String] = ["Arial",
                                   "Arial-BoldMT",
                                   "Arial-ItalicMT",
                                   "Arial-BoldItalicMT",
                                   "Georgia",
                                   "Georgia-Bold",
                                   "Georgia-Italic",
                                   "Georgia-BoldItalic",
                                   ]
    /*
     "Arial",
     "HelveticaNeue-Bold",
     "HelveticaNeue-Thin",
     "AvenirNext-HeavyItalic",
     Arial-BoldItalicMT
     */
    var isSelected: Bool?
    var fontSize: CGFloat = 14
    
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        pickerView.delegate = self
        pickerView.dataSource = self
        tapSettingLabel()
        
        for i in 14...100 {
            pickerDataSize.append(i)
        }
        
        if isConnected == true {
            signal.setImage(UIImage(named: "on"), for: .normal)
        } else {
            signal.setImage(UIImage(named: "off"), for: .normal)
        }
    }
    
    func tapSettingLabel() {
        let fontGesture = UITapGestureRecognizer(target: self, action: #selector(DisplayTextViewController.viewTapped(sender:)))
        self.view.addGestureRecognizer(fontGesture)
        
        size.isUserInteractionEnabled = true
        let tapSize: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnSize))
        size.addGestureRecognizer(tapSize)
        
        font.isUserInteractionEnabled = true
        let tapFont: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnFont))
        font.addGestureRecognizer(tapFont)
    }
    
    
    func tapOnSize() {
        if let tf = enterText {
            tf.resignFirstResponder()
        }
        isSelected = true
        pickerView.reloadAllComponents()
        pickerView.isHidden = false
    }
    
    func tapOnFont() {
        if let tf = enterText {
            tf.resignFirstResponder()
        }
        isSelected = false
        pickerView.reloadAllComponents()
        pickerView.isHidden = false
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Comfirm", message: "Would you like to save image?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            let image = UIImage.imageWithLabel(label: self.labelImage)
            var imagePath = NSDate().description
            imagePath = imagePath.replacingOccurrences(of: " ", with: "")
            imagePath = self.imagesDirectoryPath.appending("/\(imagePath).png")
            let data = UIImagePNGRepresentation(image)
            let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
            self.insertData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
            do{
                let titles = try FileManager.default.contentsOfDirectory(atPath: self.imagesDirectoryPath)
                    /*Remove in directory when user don't save*/
                    do {
                        try FileManager.default.removeItem(atPath: self.imagesDirectoryPath + "/" + "/\(titles[titles.count-1])")
                        print("old image has been removed")
                    } catch {
                        print("an error during a removing")
                    }
                
            }catch{
                print("Error")
            }

        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: Any) {
        
        if isConnected == true {
            let image = UIImage.imageWithLabel(label: self.labelImage)
            let image2 = DataProviding.resizeImage(image: image, newWidth: CGFloat(valueVanNumber))
            let result = DataProviding.intensityValuesFromImage2(image: image2, value: UInt8(valueThreshold))
        
            let height = (result.data!.count)/(valueVanNumber/8)
            var Array: [[UInt8]] = [[]]
            
            for j in 0..<height {
                var dataArray: [UInt8] = []
                dataArray = [UInt8](repeating: 0, count: (valueVanNumber/8))
                for i in 0..<(valueVanNumber/8) {
                    dataArray[i] = result.data![i + (height - 1 - j)*(valueVanNumber/8)]
                }
                Array.append(dataArray)
            }
            
            for a in Array {
                if DataProviding.sendData(foo: a) == true {
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
            
//            let newString = (result.pixelValues?.description)!
//            let newString2 = newString.replacingOccurrences(of: ", ", with: "", options: .literal, range: nil)
//            let newString3 = newString2.replacingOccurrences(of: "[", with: "", options: .literal, range: nil)
//            let data = newString3.replacingOccurrences(of: "]", with: "", options: .literal, range: nil)
            
//            if socketTCP?.send(str: data + "\n").0 == true {
//                DataProviding.SendSuccess(viewController: self)
//                signal.setImage(UIImage(named: "on"), for: .normal)
//                isConnected = true
//            } else {
//                DataProviding.SendFail(viewController: self)
//                signal.setImage(UIImage(named: "off"), for: .normal)
//                isConnected = false
//            }
            
        } else {
            DataProviding.SendFail(viewController: self)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textStr:NSString = textField.text as String! as NSString
        
        textStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let textStrMutable:NSMutableString = NSMutableString(string:textStr)
        if string == "" {
            if textStr.length > 0 {
                textStrMutable.deleteCharacters(in: NSMakeRange(textStrMutable.length - 1, 1))
            }
        } else {
            if string != " " {
                textStrMutable.append(string)
            }
        }
        
        let trimmedString:NSString = textStrMutable.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
            ) as NSString
        
        self.labelImage.text = trimmedString as String
        return true
    }
    
    func viewTapped(sender: UITapGestureRecognizer? = nil) {
        if let tf = enterText {
            tf.resignFirstResponder()
        }
        pickerView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case enterText:
            textField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true;
    }
    
    func insertData() {
        do{
            let titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            if let err = SD.executeChange(sqlStr: "INSERT INTO ImageData (Path) VALUES (?)", withArgs: ["/\(titles[titles.count-1])" as AnyObject]){
                //there was an error inserting the new row, handle it here
            }
        }catch{
            print("Error")
        }
    }
    
    func conditionSQLite() {
        /*Condition to have path*/
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker")
        //documentDirectorPath.stringByAppendingString("/ImagePicker")
        
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
    }
}

extension DisplayTextViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isSelected == true {
            return pickerDataSize.count
        } else {
            return pickerDataFont.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isSelected == true {
            return pickerDataSize[row].description
        } else {
            return pickerDataFont[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if isSelected == true {
             size.text = pickerDataSize[row].description + "▼"
             labelImage.font = labelImage.font.withSize(CGFloat(pickerDataSize[row]))
             fontSize = CGFloat(pickerDataSize[row])
        } else {
             font.text = pickerDataFont[row] + "▼"
             labelImage.font = UIFont.init(name: pickerDataFont[row], size: fontSize)
        }

        pickerView.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.view.frame.width-20
    }
}



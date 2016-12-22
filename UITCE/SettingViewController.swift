//
//  SettingViewController.swift
//  UITCE
//
//  Created by Lee Hoa on 12/21/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var vans: UILabel!
    @IBOutlet weak var dImage: UITextField!
    @IBOutlet weak var dRow: UITextField!
    @IBOutlet weak var threshold: UITextField!
    @IBOutlet weak var ip: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet var backgroundView: UIView!
    
    var pickerData = ["192","164","128", "96", "64", "32"]
    var textField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heightScrollView.constant  = self.view.frame.size.height
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingViewController.viewTapped(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.keyboardShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        loadingSetting()
        pickerView.dataSource = self
        pickerView.delegate = self
        vans.isUserInteractionEnabled = true
        let tapOnImage: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewPicker))
        vans.addGestureRecognizer(tapOnImage)
    }
    
    func viewPicker() {
        if let tf = textField {
            tf.resignFirstResponder()
        }
        self.pickerView.isHidden = false
        heightScrollView.constant = self.view.frame.height
    }
    
    func loadingSetting() {
        let (resultSet, err) = SD.executeQuery(sqlStr: "SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            vans.text = resultSet[0]["Van"]?.asInt()?.description
            dRow.text = resultSet[0]["DRow"]?.asInt()?.description
            dImage.text = resultSet[0]["DImage"]?.asInt()?.description
            threshold.text = resultSet[0]["Value"]?.asInt()?.description
            ip.text = resultSet[0]["IP"]?.asString()
            port.text = resultSet[0]["Port"]?.asInt()?.description
        }
    }

    @IBAction func save(_ sender: Any) {
        let (_, err) = SD.executeQuery(sqlStr: "SELECT * FROM Setting")
        if err != nil {
        } else {
            let van =  Int(vans.text!)
            let dRow = Int(self.dRow.text!)
            let dImage = Int(self.dImage.text!)
            let value = Int(threshold.text!)
            let iP = ip.text!
            let port = Int(self.port.text!)
            
            if van! > 0 && dRow! > 0 && dImage! > 0 && value! > 0 && iP != "" && port! > 0 {
                SD.executeQuery(sqlStr: "UPDATE Setting SET Van = '\(van!.description)',DRow = '\(dRow!.description)', DImage = '\(dImage!.description)', Value = '\(value!.description)', IP = '\(iP)', Port = '\(port!.description)'")
            }
        }
        
        let refreshAlert = UIAlertController(title: "Infomation", message: "Setting is changed.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
   
    @IBAction func connnect(_ sender: Any) {
    }
    
    @IBAction func `default`(_ sender: Any) {
        SD.executeQuery(sqlStr: "UPDATE Setting SET Van = '192',DRow = '200', DImage = '1000', Value = '127', IP = '192.168.0.1', Port = '8080'")
        vans.text = "192"
        dRow.text = "200"
        dImage.text = "1000"
        threshold.text = "127"
        ip.text = "192.168.0.1"
        port.text = "8080"
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewTapped(sender: UITapGestureRecognizer? = nil) {
        if let tf = textField {
            tf.resignFirstResponder()
            self.pickerView.isHidden = true
            heightScrollView.constant = self.view.frame.height
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = (value as AnyObject).cgRectValue
        let keyboarFrame = view.convert(rawFrame!, from: nil)
        
        if let tf = textField {
            heightScrollView.constant = self.view.frame.size.height - keyboarFrame.size.height - 59
        }
    }

}

extension SettingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textStr:NSString = textField.text as String! as NSString
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if textField == dImage {
            setBackground(length: 4,newLength: newLength,textStr: textStr as String as String as NSString, string: string)
            return newLength <= 4
        } else if textField == dRow {
            setBackground(length: 4,newLength: newLength,textStr: textStr as String as String as NSString, string: string)
            return newLength <= 4
        } else if textField == threshold{
            setBackground(length: 3,newLength: newLength,textStr: textStr as String as String as NSString, string: string)
            return newLength <= 3
        } else if textField == ip{
            setBackground(length: 15,newLength: newLength,textStr: textStr as String as String as NSString, string: string)
            return newLength <= 15
        } else {
            setBackground(length: 5,newLength: newLength,textStr: textStr as String as String as NSString, string: string)
            return newLength <= 5
        }
    }

    func setBackground(length: Int, newLength: Int, textStr: NSString, string: String) {
        if newLength <= length {
            textStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            let textStrMutable:NSMutableString = NSMutableString(string:textStr)
            if string == "" {
                if textStr.length > 0 {
                    textStrMutable.deleteCharacters(in: NSMakeRange(textStrMutable.length - 1, 1))
                }
                
            }else{
                if string != " " {
                    textStrMutable.appending(string)
                }
            }
            let trimmedString:NSString = textStrMutable.trimmingCharacters(
                in: NSCharacterSet.whitespacesAndNewlines
            ) as NSString
            print("|",trimmedString,"|")
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.pickerView.isHidden = true
        switch textField {
        case dImage:
            dRow.becomeFirstResponder()
        case dRow:
            threshold.becomeFirstResponder()
        case threshold:
            ip.becomeFirstResponder()
        case ip:
            port.becomeFirstResponder()
        case port:
            textField.resignFirstResponder()
        // TODO: handle login here
        default:
            textField.resignFirstResponder()
        }
        return true;
    }
}

extension SettingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        vans.text = pickerData[row]
        print(pickerData[row])
        pickerView.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 120
    }
}

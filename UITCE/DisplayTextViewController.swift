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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let fontGesture = UITapGestureRecognizer(target: self, action: #selector(DisplayTextViewController.viewTapped(sender:)))
        self.view.addGestureRecognizer(fontGesture)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        
    }
    
    @IBAction func send(_ sender: Any) {
        
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
    
}


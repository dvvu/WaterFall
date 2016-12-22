//
//  SocketManager.swift
//  UIT-CE
//
//  Created by Lee Hoa on 11/14/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import Foundation

class SocketManager {
    let socket : TCPClient

    class var sharedInstance: SocketManager {
        struct Singleton {
            static let instance = SocketManager()
        }
        return Singleton.instance
    }
    
    init() {
        // Create the socket
        self.socket = TCPClient(addr: "192.168.0.125", port: 4000)
        // Connect the socket
        let (success, msg )=self.socket.connect(timeout: 1)
        print("\(msg) : \(success)")
        
    }
    
    /*
     DispatchQueue.global(qos: .background).async {
     self.conditionSQLite()
     self.RepareData()
     
     DispatchQueue.main.async {
     self.imagePicker.allowsEditing = false
     self.imagePicker.delegate = self
     self.imagePicker.sourceType = .photoLibrary
     self.layoutCollectiobView()
     }
     }
     
     */
    
    internal func sendMessage(data: String){
//        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        
        DispatchQueue.global(qos: .background).async {
            
            let request = self.sendRequest(data: data, client: self.socket)
            print("received message: \(request)")
            DispatchQueue.main.async {
                 print("This is run on the main queue, after the previous code in outer block")
            }
        }
        
        
        
        
//        let backgroundQueue = DispatchQueue.global(Int(qualityOfServiceClass.rawValue), 0)
//       
//        dispatch_async(backgroundQueue, {
//            let request = self.sendRequest(data, client: self.socket)
//            print("received message: \(request)")
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                print("This is run on the main queue, after the previous code in outer block")
//            })
//            
//        })
        
    }
    
    private func sendRequest(data: String, client: TCPClient?) -> (String?) {
        // It use ufter connection
        if client != nil {
            // Send data  (WE MUST ADD SENDING MESSAGE '\n' )
            let (isSuccess, errorMessage) = client!.send(str: "\(data)\n")
            if isSuccess {
                // Read response data
                let data = client!.read(expectlen: 1024*10)
                if let d = data {
                    // Create String from response data
                    if let str = NSString(bytes: d, length: d.count, encoding: String.Encoding.utf8.rawValue) as? String {
                        return (data: str)
                    } else {
                        return (data: nil)
                    }
                } else {
                    return (data: nil)
                }
            } else {
                print(errorMessage)
                return (data: nil)
            }
        } else {
            return (data: nil)
        }
    }

}

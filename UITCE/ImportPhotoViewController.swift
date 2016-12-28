//
//  ImortPhotoViewController.swift
//  UITCE
//
//  Created by Lee Hoa on 12/19/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class ImportPhotoViewController: UIViewController {

    @IBOutlet weak var signal: UIButton!
    var imagesDirectoryPath:String!
    var imagePicker = UIImagePickerController()
    var images: [UIImage]?
    var number: Int = 0
    var TYPE: Int = 0 /*0-> None; 1-> delete; 2 ->select;3->send*/
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    var ischecked: [Bool] = [false]
    var Array: [[UInt8]] = [[]]
    var indexSend: [Int] = []
    
    @IBOutlet weak var importPhotoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isConnected == true {
            signal.setImage(UIImage(named: "on"), for: .normal)
        } else {
            signal.setImage(UIImage(named: "off"), for: .normal)
        }
        
        importPhotoCollectionView!.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
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
    }

    func layoutCollectiobView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width-1)/2, height: (self.view.frame.size.width-1)/2)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        importPhotoCollectionView!.setCollectionViewLayout(flowLayout, animated: true)
    }

    @IBAction func insertButton(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func deleteButton(_ sender: Any) {
       
        if TYPE == 0 {
            /*None*/
            TYPE = 1
            self.importPhotoCollectionView.backgroundColor = UIColor.red
        } else if TYPE == 1 {
            TYPE = 0
            self.importPhotoCollectionView.backgroundColor = UIColor.white
            /*Delete*/
        } else if TYPE == 2{
            /*Choice*/
            TYPE = 1
            self.importPhotoCollectionView.backgroundColor = UIColor.red
        }else {
            /*Send*/
            TYPE = 1
            self.importPhotoCollectionView.backgroundColor = UIColor.red
        }
        self.importPhotoCollectionView.reloadData()
    }
    
    @IBAction func selected(_ sender: Any) {
        if TYPE == 0 {
            /*None*/
            TYPE = 2
            self.importPhotoCollectionView.backgroundColor = UIColor.blue
        } else if TYPE == 1 {
            TYPE = 2
            self.importPhotoCollectionView.backgroundColor = UIColor.blue
            /*Delete*/
        } else if TYPE == 2{
            /*Choice*/
            TYPE = 0
            self.importPhotoCollectionView.backgroundColor = UIColor.white
        } else {
            /*Send*/
            TYPE = 2
            self.importPhotoCollectionView.backgroundColor = UIColor.blue
        }
        self.importPhotoCollectionView.reloadData()
    }
    
    @IBAction func send(_ sender: Any) {
        TYPE = 3
        self.importPhotoCollectionView.backgroundColor = UIColor.white
        
        for i in 0..<indexSend.count {
            
            if isConnected == true {
                /*Send Bytes*/
                let height = (Array[indexSend[i]].count)/(valueVanNumber/8)
              
                for j in 0..<height {
                    var dataArray: [UInt8] = []
                    dataArray = [UInt8](repeating: 0, count: (valueVanNumber/8))
                    for i in 0...7 {
                        dataArray[i] = Array[indexSend[i]][i + (height - 1 - j)*(valueVanNumber/8)]
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
                
//                for a in Array1 {
//                    if DataProviding.sendData(foo: a) == true {
//                        DataProviding.SendSuccess(viewController: self)
//                        signal.setImage(UIImage(named: "on"), for: .normal)
//                        isConnected = true
//                    } else {
//                        DataProviding.SendFail(viewController: self)
//                        signal.setImage(UIImage(named: "off"), for: .normal)
//                        isConnected = false
//                    }
//                    usleep(valueRowDelay*1000)
//                }
                
                /*Test for Eclipse*/
//                let newString = (Array[indexSend[i]].description)
//                let newString2 = newString.replacingOccurrences(of: ", ", with: "", options: .literal, range: nil)
//                let newString3 = newString2.replacingOccurrences(of: "[", with: "", options: .literal, range: nil)
//                let data = newString3.replacingOccurrences(of: "]", with: "", options: .literal, range: nil)
//    
//                if socketTCP?.send(str: data + "\n").0 == true {
//                    DataProviding.SendSuccess(viewController: self)
//                    signal.setImage(UIImage(named: "on"), for: .normal)
//                    isConnected = true
//                } else {
//                    DataProviding.SendFail(viewController: self)
//                    signal.setImage(UIImage(named: "off"), for: .normal)
//                    isConnected = false
//                }
                
            } else {
                DataProviding.SendFail(viewController: self)
            }

        }
    }
    
    func RepareData() {
        images?.removeAll()
        images = []
        Array = []
        let (resultSet, err) = SD.executeQuery(sqlStr: "SELECT * FROM ImageData")
        if err != nil {
            
        } else {
            for row in resultSet {
                if let image = row["Path"]?.asString() {
                    let data = FileManager.default.contents(atPath: imagesDirectoryPath+image)
                    let image1 = UIImage(data: data!)
                    let image2 = DataProviding.resizeImage(image: image1!, newWidth: CGFloat(valueVanNumber))
                    let result = DataProviding.intensityValuesFromImage2(image: image2, value: UInt8(valueThreshold))
                    Array.append(result.pixelValues!) //pixelValues-> String text, data-> bytes board
                    pixels = []
                    for i in 0..<Int((result.pixelValues?.count)!) {
                        if result.pixelValues![i] == 1 {
                            pixels.append(white)
                        } else {
                            pixels.append(black)
                        }
                    }
                    
                    let image3 = DataProviding.imageFromBitmap(pixels: pixels, width: valueVanNumber, height: result.height)
                    images?.append(image3!)
                    
                }
            }
        }
        if let number = images?.count {
            self.number = number
        }
        
        if number>0 {
            for _ in 0..<number {
                ischecked += [false]
            }
        }
        
        self.importPhotoCollectionView.reloadData()
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
    
    func deleteImage(index: Int) {
        //Delete image
        let (resultSet, err) = SD.executeQuery(sqlStr: "SELECT * FROM ImageData")
        if err != nil {
        } else {
            if let name = resultSet[index]["Path"]!.asString() {
                SD.executeQuery(sqlStr: "DELETE FROM ImageData WHERE Path='\(name)'")
                do {
                    print(name)
                    try FileManager.default.removeItem(atPath: imagesDirectoryPath + name)
                    print("old image has been removed")
                } catch {
                    print("an error during a removing")
                }
                
            }
        }
        self.RepareData()
        self.importPhotoCollectionView.reloadData()
    }
}

extension ImportPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.image.image = self.images![indexPath.row]
        
        if ischecked[(indexPath as NSIndexPath).row] == true {
            cell.ischecked.setImage(UIImage(named: "ic_checked"), for: .normal)
        } else {
            cell.ischecked.setImage(UIImage(named: "ic_unchecked"), for: .normal)
        }
        if TYPE == 2 || TYPE == 3 {
            cell.ischecked.isHidden = false
        } else {
            cell.ischecked.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if TYPE == 1 {
            let refreshAlert = UIAlertController(title: "Delete", message: "Do you want to delete this immage?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.deleteImage(index: indexPath.row)
                self.TYPE = 0
                self.importPhotoCollectionView.backgroundColor = UIColor.white
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        } else if TYPE == 2 {
            let currentCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            
            if ischecked[(indexPath as NSIndexPath).row] == false {
                currentCell.ischecked.setImage(UIImage(named: "ic_checked"), for: .normal)
                ischecked[(indexPath as NSIndexPath).row] = true
                indexSend += [indexPath.row]
            } else {
                currentCell.ischecked.setImage(UIImage(named: "ic_unchecked"), for: .normal)
                ischecked[(indexPath as NSIndexPath).row] = false
                indexSend.removeObject(object: indexPath.row)
            }
        }
    }
}

extension ImportPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var imagePath = NSDate().description
            imagePath = imagePath.replacingOccurrences(of: " ", with: "")
            imagePath = imagesDirectoryPath.appending("/\(imagePath).png")
            let data = UIImagePNGRepresentation(image)
            let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
            dismiss(animated: true) { () -> Void in
                self.insertData()
                self.RepareData()
            }
        } else{
            print("Something went wrong")
        }
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
}

extension String {
    mutating func addString(str: String) {
        self = self + str
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


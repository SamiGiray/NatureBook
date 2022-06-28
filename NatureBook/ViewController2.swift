//
//  ViewController2.swift
//  NatureBook
//
//  Created by Sami Giray Doğrultucu on 6/27/22.
//

import UIKit
import CoreData

class ViewController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPrinterPickerControllerDelegate {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nametextfield: UITextField!
    @IBOutlet weak var locationtextfield: UITextField!
    @IBOutlet weak var yeartextfield: UITextField!
    var targetName = ""
    var targetId: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if targetName != ""{
            
            //Core data verileri buraya geleek
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
           // Filtreleme
            let idstring = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idstring!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject]{
                    
                    if let name = result.value(forKey: "name") as? String {
                        
                        nametextfield.text = name
                        
                    }
                    
                    if let location = result.value(forKey: "location") as? String{
                        
                       locationtextfield.text = location
                    }
                                
                    if let year = result.value(forKey: "year") as? Int{
                        yeartextfield.text = String (year)
                    }
                    
                    if let image = result.value(forKey: "image") as? Data{
                        
                        let image = UIImage(data: image)
                        imageview.image = image
                        
                    }
                }
                
            }catch {
                
                print("error")
                
                
            }
            
            
        }
        
        
        
        imageview.isUserInteractionEnabled = true
        let gesturereg = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageview.addGestureRecognizer(gesturereg)
        
        
        
    }
    
    @objc func imageTap(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageview.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func savebutton(_ sender: Any) {
        
        
        //VERİ KAYDETME İŞLEMİ
        
        let appDelege = UIApplication.shared.delegate as! AppDelegate
        let context = appDelege.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Gallery", into: context)
        
        saveData.setValue(nametextfield.text!, forKey: "name")
        saveData.setValue(locationtextfield.text!, forKey: "location")
        if let year = Int(yeartextfield.text!){
            saveData.setValue(year, forKey: "year")
            
        }
        
        let imagePress = imageview.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        
        do
        { try context.save()
            print("Succes")
            }
        
        catch
        {
            print("Error")
    
        
        
        }
   
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    
    }
    
    
    
}



//
//  PostMealViewController.swift
//  homecooked
//
//  Created by Max Rattray on 10/20/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

class PostMealViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var numPortions: UITextField!
    @IBOutlet weak var portionPrice: UITextField!
    @IBOutlet weak var ingredients: UITextField!
    @IBOutlet weak var availableFrom: UIDatePicker!
    @IBOutlet weak var availableUntil: UIDatePicker!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func imageSelect(_ sender: Any) {
        let photoMenu = UIAlertController(title: "Choose your photo", message: "", preferredStyle: .actionSheet)
        
        let cameraOption = UIAlertAction(title: "Take Photo", style: .default) {
            (action) in
            self.getPhoto(source: .camera)
        }
        let photoLibOption = UIAlertAction(title: "Choose Photo", style: .default) {
            (action) in
            self.getPhoto(source: .photoLibrary)
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel)
        
        photoMenu.addAction(cameraOption)
        photoMenu.addAction(photoLibOption)
        photoMenu.addAction(cancelOption)
        
        self.present(photoMenu, animated: true, completion: nil)
    }
    
    func getPhoto(source:UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageDisplay.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    func parseIngredients(ingredients: String) -> [String] {
        return ingredients.split{$0 == " " || $0 == ","}.map(String.init)
    }
    
    @IBAction func postMeal(_ sender: Any) {
        
        // Add meal data to firestore
        let uuid = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let availableFromString = dateFormatter.string(from: availableFrom.date)
        let availableUntilString = dateFormatter.string(from: availableUntil.date)
        
        Firestore.firestore().collection("meals").document(uuid).setData([
            "title": mealName?.text ?? "",
            "portions": Int(numPortions?.text ?? "0"),
            "price": Float(portionPrice.text ?? "0.0") ?? 0.0,
            "ingredients": parseIngredients(ingredients: ingredients.text ?? ""),
            "available_from": availableFromString,
            "available_until": availableUntilString,
            "chef_id": Auth.auth().currentUser?.uid ?? "unknown_chef_id"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
            }
            
        }
        
        // Upload image to firebase storage
        let image = imageDisplay.image
        guard let imageData = image?.jpegData(compressionQuality: 1.0) else { return  }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = "\(uuid).jpg"
        storageRef.child(imageName).putData(imageData)
        
        self.dismiss(animated: false, completion: nil)
    }
}

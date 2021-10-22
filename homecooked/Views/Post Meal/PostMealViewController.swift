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

class PostMealViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var numPortions: UITextField!
    @IBOutlet weak var portionPrice: UITextField!
    @IBOutlet weak var ingredients: UITextField!
    @IBOutlet weak var nutrientInfo: UITextField!
    @IBOutlet weak var dateSelect: UIDatePicker!
    
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
    
    @IBAction func postMeal(_ sender: Any) {
        // Add meal data to firestore
        let uuid = UUID().uuidString
        Firestore.firestore().collection("meals").document(uuid).setData([
            "mealName": mealName.text!,
            "numPortions": numPortions.text!,
            "portionPrice": portionPrice.text!,
            "ingredients": ingredients.text!,
            "nutrientInfo": nutrientInfo.text!,
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

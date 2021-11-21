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
import CoreLocation

// test for new branch
class PostMealViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var numPortions: UITextField!
    @IBOutlet weak var portionPrice: UITextField!
    @IBOutlet weak var ingredients: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var availableFrom: UIDatePicker!
    @IBOutlet weak var availableUntil: UIDatePicker!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var postMealButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMealButton.layer.cornerRadius = 10
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
    
    func parseIngredients(_ ingredients: String) -> [String] {
        return ingredients.split{$0 == " " || $0 == ","}.map(String.init)
    }
    
    func postMealToFirebase(title: String, portions: Int, price: Float, ingredients: [String], from: Date, until: Date, lat: Double, long: Double, uuid: String) {
        
        Firestore.firestore().collection("meals").document(uuid).setData([
            "title": title,
            "portions": portions,
            "price": price,
            "ingredients": ingredients,
            "available_from": from,
            "available_until": until,
            "chef_id": Auth.auth().currentUser?.uid ?? "unknown_chef_id",
            "location": FirebaseFirestore.GeoPoint(latitude: lat, longitude: long)
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
                // Upload image to firebase storage
                let image = self.imageDisplay.image
                guard let imageData = image?.jpegData(compressionQuality: 1.0) else { return }
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let imageName = "\(uuid).jpg"
                storageRef.child(imageName).putData(imageData)
            }

        }
    }
    
    @IBAction func postMeal(_ sender: Any) {
        // get location
        guard
            let address = locationField.text, !address.isEmpty,
            let title = mealName.text, !title.isEmpty,
            let portions = numPortions.text, !portions.isEmpty,
            let price = portionPrice.text, !price.isEmpty,
            let ingredientsString = ingredients.text, !ingredientsString.isEmpty
        else {
            let alert = UIAlertController(title: "Missing Input", message: "Please fill out all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let valid = validateInput(portions: portions, price: price, start: self.availableFrom.date, end: self.availableUntil.date)
        
        if (!valid) {return}
        
        let uuid = UUID().uuidString
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let long = placemark?.location?.coordinate.longitude
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd/MM/yy"
//            let availableFromString = dateFormatter.string(from: self.availableFrom.date)
//            let availableUntilString = dateFormatter.string(from: self.availableUntil.date)
            print(self.availableFrom.date)
            print(self.availableUntil.date)
            
            self.postMealToFirebase(title: title, portions: Int(portions) ?? 0, price: Float(price) ?? 0.0, ingredients: self.parseIngredients(ingredientsString), from: self.availableFrom.date, until: self.availableUntil.date, lat: lat ?? 0.0, long: long ?? 0.0, uuid: uuid)
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "save profile alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateInput(portions: String, price: String, start: Date, end: Date) -> Bool {
        let currentDateTime = Date()
        
        guard let portions = Int(portions), portions > 0 else {
            showAlert("Number of portions must be greater than 0")
            return false
        }
        guard let price = Float(price), price > 0 else {
            showAlert("Price must be greater than 0")
            return false
        }
        
        if (start < currentDateTime - (5 * 60)){
            showAlert("Availablility must start after the current time")
            return false
        }
        if (end < start){
            showAlert("Availablility must end after the start time")
            return false
        }
        return true
    }
}

//
//  SettingsViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/11/21.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        
        guard let user = Auth.auth().currentUser else {return} // should be on login screen
        emailTextField.text = user.email
        
        let reference = storageRef.child("\(user.uid).jpg")
        profileImage.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholderProfileImage.png"))
        
        let userDocRef = Firestore.firestore().collection("users").document(user.uid)
        
        userDocRef.getDocument { (doc, err) in
            if let doc = doc, doc.exists {
                let name = doc.data()?["name"] as? String
                
                var phoneString = ""
                if let phone = doc.data()?["phone"] as? Int {
                    phoneString = String(phone)
                }
                self.nameTextField.text = name
                self.phoneTextField.text = phoneString
            }
        }
        
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 6
        profileImage.contentMode = .scaleToFill
        
    }
    
    @IBAction func saveProfileClicked(_ sender: Any) {
        guard let updatedName = nameTextField.text, !updatedName.isEmpty else {
            showAlert(message: "enter your name")
            return
        }
        guard let updatedEmail = emailTextField.text, updatedEmail.isValidEmail() else {
            showAlert(message: "enter a valid email address")
            return
        }
        guard let phone = phoneTextField.text, phone.isNumeric else {
            showAlert(message: "enter a valid phone number")
            return
        }
        guard let user = Auth.auth().currentUser else {return}
        let data: [String: Any] = ["name": updatedName, "email": updatedEmail, "phone": Int(phone) as Any]
        
        Firestore.firestore().collection("users").document(user.uid).setData(data, merge: true) { err in
            if let err = err {
                self.showAlert(message: "error updating profile: \(err.localizedDescription)")
            } else {
                self.showAlert(message: "successfully updated profile")
            }
        }
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "save profile alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeProfileImage(_ sender: Any) {
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
        profileImage.image = image
        
        guard let imageData = image?.jpegData(compressionQuality: 1.0) else {return}
        guard let user = Auth.auth().currentUser else {return}
        storageRef.child("\(user.uid).jpg").putData(imageData)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }
    
}

//
//  SettingsViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/11/21.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var darkModeBtn: UIButton!
    
    let imagePicker = UIImagePickerController()
    let userDefaults = UserDefaults()
    var storageRef: StorageReference!
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        
        guard let user = Auth.auth().currentUser else {return} // should be on login screen
        emailTextField.text = user.email
        
        let reference = storageRef.child("\(user.uid).jpg")
        let placeholder = UIImage(named: "placeholderProfileImage.png")
        
        
        reference.downloadURL { url, error in
            if error != nil {
                print("couldn't get download url")
                self.profileImage.image = placeholder
              } else {
                self.imageURL = url
                self.profileImage.kf.indicatorType = .activity
                self.profileImage.kf.setImage(with: url, placeholder: placeholder)
              }
        }
        
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
        
        let appdelegate = UIApplication.shared.windows.first
        if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
            if (darkMode) {
                darkModeBtn.setTitle("Enable Light Mode", for: .normal)
                appdelegate?.overrideUserInterfaceStyle = .dark
            } else {
                darkModeBtn.setTitle("Enable Dark Mode", for: .normal)
                appdelegate?.overrideUserInterfaceStyle = .light
            }
        } else {
            darkModeBtn.setTitle("Enable Dark Mode", for: .normal)
            userDefaults.setValue(false, forKey: "darkMode")
        }
        
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
        
        if let cacheKey = imageURL?.absoluteString {
            ImageCache.default.removeImage(forKey: cacheKey)
        }
        
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
    
    @IBAction func darkModeClicked(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let appdelegate = UIApplication.shared.windows.first
            
            if let darkMode = userDefaults.value(forKey: "darkMode") as? Bool {
                if (!darkMode) {
                    appdelegate?.overrideUserInterfaceStyle = .dark
                    darkModeBtn.setTitle("Enable Light Mode", for: .normal)
                    userDefaults.setValue(true, forKey: "darkMode")
                } else {
                    appdelegate?.overrideUserInterfaceStyle = .light
                    darkModeBtn.setTitle("Enable Dark Mode", for: .normal)
                    userDefaults.setValue(false, forKey: "darkMode")
                }
            }
            

        }
    }
    
    
}

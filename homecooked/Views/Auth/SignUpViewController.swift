//
//  SignUpViewController.swift
//  homecooked
//
//  Created by Musab Abdullah on 10/20/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        errorMessageLabel.isHidden = true
        errorMessageLabel.textColor = .red
        errorMessageLabel.adjustsFontSizeToFitWidth = true
        errorMessageLabel.textAlignment = .center
    }
    

    @IBAction func clickedSignup(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let name = nameTextField.text ?? ""
        if (email == "" || password == "" || name == "") {
            errorMessageLabel.isHidden = false
            errorMessageLabel.text = "All fields must be completed"
        } else {
            // TODO: switch error checking
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("sign up error: \(error.localizedDescription)")
                    self!.errorMessageLabel.text = error.localizedDescription
                } else {
                    print("sign up success: \(String(describing: authResult))")
                    
                    Firestore.firestore().collection("users").document(authResult?.user.uid ?? "fakeuid").setData([
                        "name": self?.nameTextField?.text ?? "no name",
                        "email": email,
                    ]) { err in
                        if let err = err {
                            print("Error writing user: \(err)")
                        } else {
                            print("user doc succesfully written!")
                        }

                    }
                    
                    let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UIViewController
                    vc.modalPresentationStyle = .fullScreen
                    strongSelf.present(vc, animated: true)

                }
            }
        }
    }
}
